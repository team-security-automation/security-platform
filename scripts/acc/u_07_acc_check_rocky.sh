#!/bin/bash
source "$(dirname "$0")/../common/json_output.sh"
CHECK_ID="U-07"; CATEGORY="계정관리"
RISK_DESC="장기 미사용 계정은 관리 사각지대가 되어 공격 경로로 악용될 수 있습니다."
result=""
while IFS=: read -r username _ uid _ _ _ shell; do
  if [ "$uid" -ge 1000 ] && [ "$shell" != "/sbin/nologin" ]; then
    last=$(lastlog -u "$username" 2>/dev/null | tail -1 | awk '{print $4,$5,$6,$7,$8}')
    result="${result}${username}(마지막로그인:${last:-없음}); "
  fi
done < /etc/passwd
print_json "$CHECK_ID" "$CATEGORY" "수동확인" "$result" "장기 미사용 계정 없음" "$RISK_DESC"