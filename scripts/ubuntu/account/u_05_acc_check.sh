#!/bin/bash
source "$(dirname "$0")/../../common/json_output.sh"
CHECK_ID="U-05"; CATEGORY="계정관리"
EVIDENCE="root 외 UID 0 계정은 은밀한 백도어 관리자 계정으로 악용될 수 있습니다."
extra_root=$(awk -F: '$3==0 && $1!="root" {print $1}' /etc/passwd)
if [ -z "$extra_root" ]; then status="양호"; current="없음"; else status="취약"; current="$extra_root"; fi
print_json "$CHECK_ID" "$CATEGORY" "$status" "$current" "root만 UID 0" "$EVIDENCE"