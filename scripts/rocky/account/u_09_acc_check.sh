#!/bin/bash
source "$(dirname "$0")/../../common/json_output.sh"
CHECK_ID="U-09"; CATEGORY="계정관리"
EVIDENCE="존재하지 않는 GID를 사용하는 계정은 관리 오류의 흔적으로 점검이 필요합니다."
invalid=""
while IFS=: read -r username _ _ gid _ _ _; do
  getent group "$gid" > /dev/null 2>&1 || invalid="${invalid}${username}(GID:${gid}); "
done < /etc/passwd
if [ -z "$invalid" ]; then status="양호"; current="없음"; else status="취약"; current="$invalid"; fi
print_json "$CHECK_ID" "$CATEGORY" "$status" "$current" "모든 GID 유효" "$EVIDENCE"