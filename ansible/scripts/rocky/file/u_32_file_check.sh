#!/bin/bash
# ============================================================
# U-32 (중) 홈 디렉토리로 지정한 디렉토리의 존재 관리
# 분류: 파일 및 디렉터리 관리 | 대상: Rocky Linux (rocky)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_32_file_check.sh
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
CHECK_ID="U-32"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="계정에 지정된 홈 디렉터리가 실제로 존재"
RISK_LEVEL="중"

# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
MISSING_COUNT=0; MISSING_SAMPLES=""; CHECKED=0
while IFS=: read -r uname _ uid _ _ home shell; do
    [ "$uid" -lt 1000 ] && [ "$uname" != "root" ] && continue
    echo "$shell" | grep -qE '(nologin|false)$' && continue
    CHECKED=$((CHECKED+1))
    if [ ! -d "$home" ]; then
        MISSING_COUNT=$((MISSING_COUNT + 1))
        [ $MISSING_COUNT -le 5 ] && MISSING_SAMPLES="${MISSING_SAMPLES}${uname}(${home}) "
    fi
done < /etc/passwd
VALUE="checked=$CHECKED missing=$MISSING_COUNT"
CMD_RC=0

if [ "$MISSING_COUNT" -eq 0 ]; then
    STATUS="양호"; CURRENT_VALUE="홈 디렉터리 없는 계정 없음(${CHECKED}건 점검)"; EVIDENCE="로그인 가능한 모든 계정의 홈 디렉터리가 존재함"
else
    STATUS="취약"; CURRENT_VALUE="홈 디렉터리 없음 ${MISSING_COUNT}건"; EVIDENCE="예시: $MISSING_SAMPLES"
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
