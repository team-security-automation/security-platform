#!/bin/bash
source "$(dirname "$0")/../../common/json_output.sh"
CHECK_ID="U-06"; CATEGORY="계정관리"
EVIDENCE="su 명령어 사용 제한이 없으면 일반 계정에서 root 권한 탈취가 쉬워집니다."
if grep -q "pam_wheel.so" /etc/pam.d/su 2>/dev/null; then
  status="양호"; current="pam_wheel 적용됨"
else
  status="취약"; current="pam_wheel 미적용"
fi
print_json "$CHECK_ID" "$CATEGORY" "$status" "$current" "pam_wheel 적용" "$EVIDENCE"