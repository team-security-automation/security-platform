#!/bin/bash
# ============================================================
# U-30 (중) UMASK 설정 관리
# 분류: 파일 및 디렉터리 관리 | 대상: Rocky Linux (rocky)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_30_file_check.sh
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
CHECK_ID="U-30"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="UMASK 값 022 이상"
RISK_LEVEL="중"

# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
BAD=0; EVID=""
for f in /etc/profile /etc/login.defs /etc/bash.bashrc; do
    [ -f "$f" ] || continue
    VAL=$(grep -iE '^\s*umask[[:space:]]+[0-9]+' "$f" 2>/dev/null | tail -1 | grep -oE '[0-9]+' | tail -1)
    if [ -n "$VAL" ]; then
        VAL_NUM=$((10#$VAL))
        if [ "$VAL_NUM" -lt 22 ]; then
            BAD=1; EVID="${EVID}${f}(umask $VAL) "
        fi
    fi
done
CUR_UMASK=$(umask)
VALUE="umask=$CUR_UMASK"
CMD_RC=0

if [ $BAD -eq 0 ]; then
    STATUS="양호"; CURRENT_VALUE="umask ${CUR_UMASK} (설정파일 기준 022 이상)"; EVIDENCE="/etc/profile, /etc/login.defs 등에서 022 미만 umask 미발견"
else
    STATUS="취약"; CURRENT_VALUE="$CUR_UMASK"; EVIDENCE="022 미만 umask 발견: $EVID"
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
