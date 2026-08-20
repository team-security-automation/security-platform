#!/bin/bash
# ============================================================
# U-20 (상) /etc/(x)inetd.conf 파일 소유자 및 권한 설정
# 분류: 파일 및 디렉터리 관리 | 대상: Rocky Linux (rocky)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_20_file_check.sh
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
CHECK_ID="U-20"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="소유자 root, 권한 600 이하(미사용 시 해당없음)"
RISK_LEVEL="상"

# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
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
    STATUS="양호"; CURRENT_VALUE="(x)inetd 미사용"; EVIDENCE="inetd.conf/xinetd.conf/xinetd.d 모두 없음(슈퍼데몬 미사용)"
else
    BAD_COUNT=0; BAD_SAMPLES=""
    for f in $TARGETS; do
        OWNER=$(stat -c '%U' "$f" 2>/dev/null)
        PERM=$(stat -c '%a' "$f" 2>/dev/null)
        PERM_NUM=$((10#$PERM))
        if [ "$OWNER" != "root" ] || [ "$PERM_NUM" -gt 600 ]; then
            BAD_COUNT=$((BAD_COUNT + 1))
            [ $BAD_COUNT -le 5 ] && BAD_SAMPLES="${BAD_SAMPLES}${f}(${OWNER}:${PERM}) "
        fi
    done
    VALUE="bad_count=$BAD_COUNT"
    CMD_RC=0
    if [ "$BAD_COUNT" -eq 0 ]; then
        STATUS="양호"; CURRENT_VALUE="기준 충족"; EVIDENCE="(x)inetd 관련 파일이 소유자 root, 권한 600 이하 기준을 충족"
    else
        STATUS="취약"; CURRENT_VALUE="위반 ${BAD_COUNT}건"; EVIDENCE="예시: $BAD_SAMPLES"
    fi
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
