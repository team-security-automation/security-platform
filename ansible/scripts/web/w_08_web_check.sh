#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
CHECK_ID="WEB-08"; CATEGORY="웹서비스"; RISK_LEVEL="하"; IS_AUTO_FIXABLE="true"

value=$(grep -iE "^\s*LimitRequestBody" /etc/httpd/conf/httpd.conf 2>/dev/null | awk '{print $2}' | tail -1)

if [ -n "$value" ]; then
  STATUS="양호"
  EVIDENCE="LimitRequestBody가 ${value}로 설정되어 있어, 비정상적으로 큰 요청 본문을 통한 서비스 거부(DoS) 공격을 제한할 수 있습니다."
else
  STATUS="취약"
  EVIDENCE="LimitRequestBody가 설정되어 있지 않습니다. 요청 본문 크기 제한이 없으면 대용량 요청을 반복 전송하는 방식의 서비스 거부(DoS) 공격에 취약해질 수 있습니다."
fi
CURRENT_VALUE="LimitRequestBody ${value:-미설정}"
EXPECTED_VALUE="LimitRequestBody 설정됨"

print_json
