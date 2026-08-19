#!/bin/bash
source "$(dirname "$0")/../../common/json_output.sh"
CHECK_ID="U-11"; CATEGORY="계정관리"
EVIDENCE="시스템 계정에 로그인 쉘이 부여되면 불필요한 로그인 경로로 악용될 수 있습니다."
bad=$(awk -F: '$3<1000 && $1!="root" && ($7=="/bin/bash"||$7=="/bin/sh") {print $1}' /etc/passwd)
if [ -z "$bad" ]; then status="양호"; current="없음"; else status="취약"; current="$bad"; fi
print_json "$CHECK_ID" "$CATEGORY" "$status" "$current" "시스템계정은 nologin" "$EVIDENCE"