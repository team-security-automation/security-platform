#!/bin/bash
# ============================================================
# U-26 (상) /dev에 존재하지 않는 device 파일 점검
# 분류: 파일 및 디렉터리 관리 | 대상: Rocky Linux (rocky)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_26_file_check.sh
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
CHECK_ID="U-26"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="/dev 내 major/minor 없는 일반 파일 없음"
RISK_LEVEL="상"

# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
BAD_COUNT=0; BAD_SAMPLES=""
while IFS= read -r -d '' f; do
    case "$f" in
        /dev/shm/*|/dev/mqueue/*) continue ;;
    esac
    BAD_COUNT=$((BAD_COUNT + 1))
    [ $BAD_COUNT -le 5 ] && BAD_SAMPLES="${BAD_SAMPLES}${f} "
done < <(find /dev -xdev -type f -print0 2>/dev/null)
VALUE="bad_count=$BAD_COUNT"
CMD_RC=0

if [ "$BAD_COUNT" -eq 0 ]; then
    STATUS="양호"; CURRENT_VALUE="비정상 파일 없음"; EVIDENCE="/dev 디렉터리 내 major/minor가 없는 일반 파일(위장 파일) 미발견(/dev/shm, /dev/mqueue 제외)"
else
    STATUS="취약"; CURRENT_VALUE="비정상 파일 ${BAD_COUNT}건"; EVIDENCE="예시: $BAD_SAMPLES"
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
