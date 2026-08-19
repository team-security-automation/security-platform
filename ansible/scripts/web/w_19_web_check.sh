#!/bin/bash
source "$(dirname "$0")/../common/json_output.sh"
CHECK_ID="WEB-19"; CATEGORY="웹서비스"; RISK_LEVEL="중"; IS_AUTO_FIXABLE="true"

options=$(grep -iE "^\s*Options" /etc/httpd/conf/httpd.conf 2>/dev/null | tr '\n' ' ')

if echo "$options" | grep -qiwE "Includes|IncludesNOEXEC"; then
  STATUS="취약"
  EVIDENCE="Options 지시자에 Includes(또는 IncludesNOEXEC)가 포함되어 있습니다. SSI(Server Side Includes)가 활성화되면 사용자 입력이 반영되는 페이지에서 서버 측 명령 실행으로 이어질 수 있습니다."
else
  STATUS="양호"
  EVIDENCE="Options 지시자에 Includes가 없어, SSI를 통한 서버 측 명령 실행 위험이 없습니다."
fi
CURRENT_VALUE="Options ${options:-미확인}"
EXPECTED_VALUE="Options 지시자에 Includes 미포함"

print_json
