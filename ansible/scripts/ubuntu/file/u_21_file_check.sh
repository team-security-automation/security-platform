#!/bin/bash
# ============================================================
# U-21 (상) /etc/(r)syslog.conf 파일 소유자 및 권한 설정
# 분류: 파일 및 디렉터리 관리 | 대상: Ubuntu (ubuntu)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_21_file_check.sh
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
CHECK_ID="U-21"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="소유자 root(bin/sys), 권한 640 이하"
RISK_LEVEL="상"

# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
FILE=""
for cand in /etc/rsyslog.conf /etc/syslog.conf; do
    [ -f "$cand" ] && { FILE="$cand"; break; }
done
if [ -z "$FILE" ]; then
    STATUS="수동확인 필요"; CURRENT_VALUE="설정파일 없음"; EVIDENCE="/etc/rsyslog.conf, /etc/syslog.conf 를 찾지 못함"
else
    OWNER=$(stat -c '%U' "$FILE" 2>/dev/null)
    PERM=$(stat -c '%a' "$FILE" 2>/dev/null)
    VALUE="file=$FILE owner=$OWNER perm=$PERM"
    CMD_RC=0
    PERM_NUM=$((10#$PERM))
    if echo "$OWNER" | grep -qE '^(root|bin|sys)$' && [ "$PERM_NUM" -le 640 ]; then
        STATUS="양호"; CURRENT_VALUE="$FILE 소유자:$OWNER 권한:$PERM"; EVIDENCE="기준(root/bin/sys 소유, 640 이하) 충족"
    else
        STATUS="취약"; CURRENT_VALUE="$FILE 소유자:$OWNER 권한:$PERM"; EVIDENCE="기준(root/bin/sys 소유, 640 이하) 미충족"
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
