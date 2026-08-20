#!/bin/bash
# ============================================================
# U-33 (하) 숨겨진 파일 및 디렉토리 검색 및 제거
# 분류: 파일 및 디렉터리 관리 | 대상: Ubuntu (ubuntu)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_33_file_check.sh
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
CHECK_ID="U-33"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="의심스러운 숨김 파일/디렉터리 없음(주요 경로 기준)"
RISK_LEVEL="하"

# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
TARGET_DIRS="/tmp /var/tmp /dev/shm"
FOUND_COUNT=0; SAMPLES=""
for d in $TARGET_DIRS; do
    [ -d "$d" ] || continue
    while IFS= read -r -d '' f; do
        FOUND_COUNT=$((FOUND_COUNT + 1))
        [ $FOUND_COUNT -le 8 ] && SAMPLES="${SAMPLES}${f} "
    done < <(find "$d" -mindepth 1 -maxdepth 3 -name '.*' ! -name '.' ! -name '..' -print0 2>/dev/null)
done
VALUE="found=$FOUND_COUNT"
CMD_RC=0

if [ "$FOUND_COUNT" -eq 0 ]; then
    STATUS="양호"; CURRENT_VALUE="점검 대상 경로 내 숨겨진 파일 없음"; EVIDENCE="/tmp, /var/tmp, /dev/shm 내 숨겨진 파일/디렉터리 미발견"
else
    STATUS="취약"; CURRENT_VALUE="숨겨진 파일/디렉터리 ${FOUND_COUNT}건"; EVIDENCE="예시(관리자 확인 필요): $SAMPLES"
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
