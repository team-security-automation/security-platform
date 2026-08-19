#!/bin/bash
source "$(dirname "$0")/../../common/json_output.sh"
CHECK_ID="U-04"; CATEGORY="계정관리"
EVIDENCE="비밀번호 파일 권한이 과다하면 해시값이 유출되어 크래킹에 악용될 수 있습니다."
perm=$(stat -c "%a" /etc/shadow)
[ "$perm" -le 400 ] 2>/dev/null && status="양호" || status="취약"
print_json "$CHECK_ID" "$CATEGORY" "$status" "/etc/shadow 권한:$perm" "400 이하" "$EVIDENCE"