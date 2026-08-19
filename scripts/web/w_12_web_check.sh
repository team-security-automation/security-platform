#!/bin/bash
source "$(dirname "$0")/../common/json_output.sh"
CHECK_ID="WEB-12"; CATEGORY="웹서비스"; RISK_LEVEL="중"; IS_AUTO_FIXABLE="true"

options=$(grep -iE "^\s*Options" /etc/httpd/conf/httpd.conf 2>/dev/null | tr '\n' ' ')

if echo "$options" | grep -qiw "FollowSymLinks"; then
  STATUS="취약"
  EVIDENCE="Options 지시자에 FollowSymLinks가 포함되어 있습니다. 심볼릭 링크 추적이 허용되면 문서 루트 밖의 파일(예: /etc/passwd)로 연결된 심볼릭 링크를 통해 접근 범위 밖의 파일이 노출될 수 있습니다."
else
  STATUS="양호"
  EVIDENCE="Options 지시자에 FollowSymLinks가 없어, 심볼릭 링크를 통한 문서 루트 밖 파일 접근 위험이 없습니다."
fi
CURRENT_VALUE="Options ${options:-미확인}"
EXPECTED_VALUE="Options 지시자에 FollowSymLinks 미포함"

print_json
