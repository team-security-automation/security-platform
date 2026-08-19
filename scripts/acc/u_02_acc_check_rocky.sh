#!/bin/bash
source "$(dirname "$0")/../common/json_output.sh"
CHECK_ID="U-02"; CATEGORY="계정관리"
RISK_DESC="비밀번호 복잡도 정책이 없으면 무차별 대입 공격에 취약해집니다."
minlen=$(grep -E "^minlen" /etc/security/pwquality.conf 2>/dev/null | awk -F= '{print $2}' | tr -d ' ')
if [ -n "$minlen" ] && [ "$minlen" -ge 8 ] 2>/dev/null; then
  status="양호"; current="minlen=$minlen"
else
  status="취약"; current="minlen 미설정 또는 8 미만"
fi
print_json "$CHECK_ID" "$CATEGORY" "$status" "$current" "minlen>=8" "$RISK_DESC"