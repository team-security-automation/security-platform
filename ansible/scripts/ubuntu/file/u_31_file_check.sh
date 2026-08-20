#!/bin/bash
# ============================================================
# U-31 (중) 홈 디렉토리 소유자 및 권한 설정
# 분류: 파일 및 디렉터리 관리 | 대상: Ubuntu (ubuntu)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_31_file_check.sh
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
CHECK_ID="U-31"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="홈 디렉터리 소유자가 해당 계정, 타 사용자 쓰기 권한 제거"
RISK_LEVEL="중"

# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
BAD_COUNT=0; BAD_SAMPLES=""; CHECKED=0
while IFS=: read -r uname _ uid _ _ home shell; do
    [ "$uid" -lt 1000 ] && [ "$uname" != "root" ] && continue
    [ -d "$home" ] || continue
    CHECKED=$((CHECKED+1))
    OWNER=$(stat -c '%U' "$home" 2>/dev/null)
    PERM=$(stat -c '%a' "$home" 2>/dev/null)
    OTHER_W=$(( (10#$PERM) % 10 ))
    if [ "$OWNER" != "$uname" ] || [ $(( OTHER_W & 2 )) -ne 0 ]; then
        BAD_COUNT=$((BAD_COUNT + 1))
        [ $BAD_COUNT -le 5 ] && BAD_SAMPLES="${BAD_SAMPLES}${home}(${OWNER}:${PERM}) "
    fi
done < /etc/passwd
VALUE="checked=$CHECKED bad=$BAD_COUNT"
CMD_RC=0

if [ "$CHECKED" -eq 0 ]; then
    STATUS="양호"; CURRENT_VALUE="점검 대상 홈 디렉터리 없음"; EVIDENCE="점검 대상 계정의 홈 디렉터리가 없음"
elif [ "$BAD_COUNT" -eq 0 ]; then
    STATUS="양호"; CURRENT_VALUE="기준 충족(${CHECKED}건 점검)"; EVIDENCE="모든 홈 디렉터리가 소유자 일치 및 타사용자 쓰기권한 제거 기준을 충족"
else
    STATUS="취약"; CURRENT_VALUE="위반 ${BAD_COUNT}/${CHECKED}건"; EVIDENCE="예시: $BAD_SAMPLES"
fi

# ============================================================
# 5. JSON 출력
# ============================================================
cat <<EOF
{
  "check_id": "$(json_esc "$CHECK_ID")",
  "category": "$(json_esc "$CATEGORY")",
  "status": "$(json_esc "$STATUS")",
  "current_value": "$(json_esc "$CURRENT_VALUE")",
  "expected_value": "$(json_esc "$EXPECTED_VALUE")",
  "evidence": "$(json_esc "$EVIDENCE")",
  "hostname": "$(hostname)",
  "risk_level": "$(json_esc "$RISK_LEVEL")"
}
EOF

# ============================================================
# 6. 정상 종료
# ============================================================
exit 0
