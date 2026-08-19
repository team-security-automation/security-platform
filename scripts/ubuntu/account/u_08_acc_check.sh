#!/bin/bash
source "$(dirname "$0")/../../common/json_output.sh"
CHECK_ID="U-08"; CATEGORY="계정관리"
EVIDENCE="관리자 그룹에 계정이 많을수록 권한 탈취 시 피해 범위가 커집니다."
members=$(getent group sudo | awk -F: '{print $4}')
count=$(echo "$members" | tr ',' '\n' | grep -c .)
[ "$count" -le 3 ] && status="양호" || status="수동확인"
print_json "$CHECK_ID" "$CATEGORY" "$status" "sudo 그룹원($count명): $members" "3명 이하 권장" "$EVIDENCE"