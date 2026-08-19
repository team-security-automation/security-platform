#!/bin/bash
source "$(dirname "$0")/../../common/json_output.sh"
CHECK_ID="U-10"; CATEGORY="계정관리"
EVIDENCE="동일한 UID를 가진 계정이 여러 개면 로그 추적 시 행위자 구분이 불가능해집니다."
dup=$(awk -F: '{print $3}' /etc/passwd | sort | uniq -d)
if [ -z "$dup" ]; then status="양호"; current="중복 없음"; else status="취약"; current="중복 UID: $dup"; fi
print_json "$CHECK_ID" "$CATEGORY" "$status" "$current" "UID 중복 없음" "$EVIDENCE"