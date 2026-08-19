#!/bin/bash
source "$(dirname "$0")/../common/json_output.sh"
CHECK_ID="U-03"; CATEGORY="계정관리"
RISK_DESC="계정 잠금 정책이 없으면 무차별 대입 공격을 무제한 시도할 수 있습니다."
if grep -q "pam_faillock" /etc/pam.d/common-auth 2>/dev/null; then
  status="양호"; current="pam_faillock 적용됨"
else
  status="취약"; current="pam_faillock 미적용"
fi
print_json "$CHECK_ID" "$CATEGORY" "$status" "$current" "pam_faillock 적용" "$RISK_DESC"