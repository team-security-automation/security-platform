#!/bin/bash
# ============================================================
# U-20 (상) /etc/(x)inetd.conf 파일 소유자 및 권한 설정 - 조치 스크립트
# 분류: 파일 및 디렉터리 관리 | 대상: Ubuntu (ubuntu)
# 주의: 설정 파일을 변경하는 경우 원본을 .bak_<시각> 으로 백업합니다.
#       운영 서버 적용 전 반드시 테스트 서버에서 먼저 검증하세요.
# 실행: sudo bash u_20_file_fix.sh
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
FIX_ID="U-20"
CATEGORY="파일 및 디렉터리 관리"
RISK_LEVEL="상"

# ============================================================
# 2~4. 현재 상태 확인 후 필요 시 조치 실행
#   STATUS 값: 조치완료 | 조치불필요 | 조치실패 | 수동조치필요
# ============================================================
TARGETS=""
for cand in /etc/xinetd.conf /etc/inetd.conf; do
    [ -f "$cand" ] && TARGETS="${TARGETS}${cand} "
done
if [ -d /etc/xinetd.d ]; then
    for f in /etc/xinetd.d/*; do
        [ -f "$f" ] && TARGETS="${TARGETS}${f} "
    done
fi

if [ -z "$TARGETS" ]; then
    STATUS="조치불필요"; ACTION="(x)inetd 미사용"
else
    FIXED=0
    for f in $TARGETS; do
        OWNER=$(stat -c '%U' "$f" 2>/dev/null)
        PERM=$(stat -c '%a' "$f" 2>/dev/null)
        PERM_NUM=$((10#$PERM))
        if [ "$OWNER" != "root" ] || [ "$PERM_NUM" -gt 600 ]; then
            chown root "$f" 2>/dev/null
            chmod 600 "$f" 2>/dev/null
            FIXED=$((FIXED + 1))
        fi
    done
    if [ $FIXED -gt 0 ]; then
        STATUS="조치완료"; ACTION="${FIXED}개 (x)inetd 관련 파일의 소유자를 root, 권한을 600으로 변경함"
    else
        STATUS="조치불필요"; ACTION="이미 모든 (x)inetd 관련 파일이 기준을 충족함"
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
