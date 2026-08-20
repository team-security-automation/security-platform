#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
CHECK_ID="WEB-16"; CATEGORY="웹서비스"; RISK_LEVEL="중"; IS_AUTO_FIXABLE="true"

tokens=$(grep -iE "^\s*ServerTokens" /etc/httpd/conf/httpd.conf 2>/dev/null | awk '{print $2}' | tail -1)
signature=$(grep -iE "^\s*ServerSignature" /etc/httpd/conf/httpd.conf 2>/dev/null | awk '{print $2}' | tail -1)

if [ "$tokens" == "Prod" ] && [ "$signature" == "Off" ]; then
  STATUS="양호"
  EVIDENCE="ServerTokens Prod, ServerSignature Off로 설정되어 있어 에러 페이지나 응답 헤더에 Apache 버전, OS 등 상세 정보가 노출되지 않습니다."
else
  STATUS="취약"
  EVIDENCE="ServerTokens가 '${tokens:-미설정}', ServerSignature가 '${signature:-미설정}'입니다. 서버 버전 정보가 노출되면 공격자가 해당 버전에 특화된 알려진 취약점을 골라 공격할 수 있습니다."
fi
CURRENT_VALUE="ServerTokens ${tokens:-미설정}, ServerSignature ${signature:-미설정}"
EXPECTED_VALUE="ServerTokens Prod, ServerSignature Off"

print_json
