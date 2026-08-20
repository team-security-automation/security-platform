#!/bin/bash
# ============================================================
# U-27 (상) $HOME/.rhosts, hosts.equiv 사용 금지 - 조치 스크립트
# 분류: 파일 및 디렉터리 관리 | 대상: Rocky Linux (rocky)
# 주의: 설정 파일을 변경하는 경우 원본을 .bak_<시각> 으로 백업합니다.
#       운영 서버 적용 전 반드시 테스트 서버에서 먼저 검증하세요.
# 실행: sudo bash u_27_file_fix.sh
# ============================================================

# JSON 이스케이프 유틸 (따옴표/개행 처리)
json_esc() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="$(printf '%s' "$s" | tr '\n' ' ')"
    printf '%s' "$s"
}

# ============================================================
# 1. 기본 정보
# ============================================================
FIX_ID="U-27"
CATEGORY="파일 및 디렉터리 관리"
RISK_LEVEL="상"

# ============================================================
# 2~4. 현재 상태 확인 후 필요 시 조치 실행
#   STATUS 값: 조치완료 | 조치불필요 | 조치실패 | 수동조치필요
# ============================================================
RSVC_ACTIVE="no"
for svc in rlogin rsh rexec rlogin.socket rsh.socket; do
    systemctl is-active --quiet "$svc" 2>/dev/null && RSVC_ACTIVE="yes"
done

if [ "$RSVC_ACTIVE" = "no" ] && [ ! -f /etc/hosts.equiv ]; then
    STATUS="조치불필요"; ACTION="r-command 서비스 미사용이며 /etc/hosts.equiv 도 없음"
else
    FIXED=0
    if [ -f /etc/hosts.equiv ]; then
        cp -p /etc/hosts.equiv /etc/hosts.equiv.bak_$(date +%Y%m%d%H%M%S)
        sed -i '/^\+/d' /etc/hosts.equiv
        chown root /etc/hosts.equiv
        chmod 600 /etc/hosts.equiv
        FIXED=1
    fi
    while IFS=: read -r uname _ uid _ _ home _; do
        [ "$uid" -lt 1000 ] && [ "$uname" != "root" ] && continue
        f="$home/.rhosts"
        [ -f "$f" ] || continue
        cp -p "$f" "${f}.bak_$(date +%Y%m%d%H%M%S)"
        sed -i '/^\+/d' "$f"
        chown "$uname" "$f" 2>/dev/null
        chmod 600 "$f"
        FIXED=1
    done < /etc/passwd

    if [ $FIXED -eq 1 ]; then
        STATUS="조치완료"; ACTION="hosts.equiv/.rhosts 파일의 '+' 설정 제거 및 소유자/권한(600)을 조정함(원본은 .bak_* 로 백업)"
    else
        STATUS="조치불필요"; ACTION="r-command 서비스가 비활성이며 관련 파일도 없음"
    fi
fi

# ============================================================
# 5. JSON 출력
# ============================================================
cat <<EOF
{
  "fix_id": "$(json_esc "$FIX_ID")",
  "category": "$(json_esc "$CATEGORY")",
  "status": "$(json_esc "$STATUS")",
  "action": "$(json_esc "$ACTION")",
  "hostname": "$(hostname)",
  "risk_level": "$(json_esc "$RISK_LEVEL")"
}
EOF

# ============================================================
# 6. 정상 종료
# ============================================================
exit 0
