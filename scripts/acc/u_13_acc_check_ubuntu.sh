#!/bin/bash
source "$(dirname "$0")/../common/json_output.sh"
CHECK_ID="U-13"; CATEGORY="계정관리"
RISK_DESC="취약한 해시 알고리즘은 비밀번호 크래킹에 상대적으로 쉽게 노출됩니다."
method=$(grep -E "^ENCRYPT_METHOD" /etc/login.defs 2>/dev/null | awk '{print $2}')
[ "$method" == "SHA512" ] && status="양호" || status="취약"
print_json "$CHECK_ID" "$CATEGORY" "$status" "ENCRYPT_METHOD=${method:-미설정}" "SHA512" "$RISK_DESC"