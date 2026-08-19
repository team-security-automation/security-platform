#!/bin/bash
source "$(dirname "$0")/../../common/json_output.sh"
CHECK_ID="U-01"; CATEGORY="계정관리"
EVIDENCE="root 계정으로 원격 접속이 허용되면 공격자가 관리자 권한을 직접 탈취할 수 있습니다."
current=$(grep -E "^PermitRootLogin" /etc/ssh/sshd_config | awk '{print $2}')
[ "$current" == "no" ] && status="양호" || status="취약"
print_json "$CHECK_ID" "$CATEGORY" "$status" "PermitRootLogin ${current:-미설정}" "PermitRootLogin no" "$EVIDENCE"