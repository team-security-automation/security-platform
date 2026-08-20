#!/bin/bash
# ============================================================
# U-25 (상) world writable 파일 점검
# 분류: 파일 및 디렉터리 관리 | 대상: Rocky Linux (rocky)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_25_file_check.sh
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
CHECK_ID="U-25"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="world writable 파일 없음(예외 경로 제외)"
RISK_LEVEL="상"

# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
EXCLUDE_RE='^/(proc|sys|dev|tmp|var/tmp|var/spool/mail|var/spool/postfix|run)(/|$)'
BAD_COUNT=0; BAD_SAMPLES=""
while IFS= read -r -d '' f; do
    echo "$f" | grep -qE "$EXCLUDE_RE" && continue
    BAD_COUNT=$((BAD_COUNT + 1))
    [ $BAD_COUNT -le 5 ] && BAD_SAMPLES="${BAD_SAMPLES}${f} "
done < <(find / -xdev -type f -perm -0002 -print0 2>/dev/null)
VALUE="bad_count=$BAD_COUNT"
CMD_RC=0

if [ "$BAD_COUNT" -eq 0 ]; then
    STATUS="양호"; CURRENT_VALUE="world writable 파일 없음"; EVIDENCE="(/tmp 등 예외 경로 제외) world writable 파일 미발견"
else
    STATUS="취약"; CURRENT_VALUE="world writable 파일 ${BAD_COUNT}건"; EVIDENCE="예시: $BAD_SAMPLES"
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
