#!/bin/bash
source "$(dirname "$0")/../common/json_output.sh"
CHECK_ID="U-12"; CATEGORY="계정관리"
RISK_DESC="세션 자동 종료가 없으면 자리 비운 사이 미인가 접근에 노출됩니다."
tmout=$(grep -E "^\s*TMOUT" /etc/profile 2>/dev/null | awk -F= '{print $2}')
if [ -n "$tmout" ] && [ "$tmout" -le 600 ] 2>/dev/null; then
  status="양호"; current="TMOUT=$tmout"
else
  status="취약"; current="TMOUT 미설정"
fi
print_json "$CHECK_ID" "$CATEGORY" "$status" "$current" "TMOUT<=600" "$RISK_DESC"