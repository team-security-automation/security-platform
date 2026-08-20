#!/bin/bash
# ============================================================
# U-30 (중) UMASK 설정 관리 - 조치 스크립트
# 분류: 파일 및 디렉터리 관리 | 대상: Ubuntu (ubuntu)
# 주의: 설정 파일을 변경하는 경우 원본을 .bak_<시각> 으로 백업합니다.
#       운영 서버 적용 전 반드시 테스트 서버에서 먼저 검증하세요.
# 실행: sudo bash u_30_file_fix.sh
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
FIX_ID="U-30"
CATEGORY="파일 및 디렉터리 관리"
RISK_LEVEL="중"

# ============================================================
# 2~4. 현재 상태 확인 후 필요 시 조치 실행
#   STATUS 값: 조치완료 | 조치불필요 | 조치실패 | 수동조치필요
# ============================================================
FIXED=0
for f in /etc/profile /etc/login.defs; do
    [ -f "$f" ] || continue
    VAL=$(grep -iE '^\s*umask[[:space:]]+[0-9]+' "$f" 2>/dev/null | tail -1 | grep -oE '[0-9]+' | tail -1)
    if [ -n "$VAL" ]; then
        VAL_NUM=$((10#$VAL))
        if [ "$VAL_NUM" -lt 22 ]; then
            cp -p "$f" "${f}.bak_$(date +%Y%m%d%H%M%S)"
            sed -i -E 's/^([[:space:]]*[Uu][Mm][Aa][Ss][Kk][[:space:]]+)[0-9]+/\1022/' "$f"
            FIXED=1
        fi
    else
        cp -p "$f" "${f}.bak_$(date +%Y%m%d%H%M%S)"
        if [ "$f" = "/etc/login.defs" ]; then
            printf '\nUMASK           022\n' >> "$f"
        else
            printf '\numask 022\nexport umask\n' >> "$f"
        fi
        FIXED=1
    fi
done

if [ $FIXED -eq 1 ]; then
    STATUS="조치완료"; ACTION="/etc/profile, /etc/login.defs 의 UMASK 값을 022로 설정함(원본은 .bak_* 로 백업)"
else
    STATUS="조치불필요"; ACTION="이미 UMASK 값이 022 이상으로 설정되어 있음"
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
