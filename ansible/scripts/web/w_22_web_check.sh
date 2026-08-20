#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
CHECK_ID="WEB-22"; CATEGORY="웹서비스"; RISK_LEVEL="하"; IS_AUTO_FIXABLE="true"

codes="400 401 403 404 500"
missing=""
for c in $codes; do
  grep -riqE "^\s*ErrorDocument\s+$c\s" /etc/httpd/conf/httpd.conf /etc/httpd/conf.d/*.conf 2>/dev/null || missing="${missing}${c}, "
done
missing=$(echo "$missing" | sed 's/, $//')

if [ -z "$missing" ]; then
  STATUS="양호"; CURRENT_VALUE="전체 설정됨"
  EVIDENCE="주요 에러코드(400/401/403/404/500)에 대한 ErrorDocument가 모두 설정되어 있어, 기본 에러 페이지를 통한 서버 버전·경로 정보 노출 위험이 없습니다."
else
  STATUS="취약"; CURRENT_VALUE="미설정: $missing"
  EVIDENCE="다음 에러코드의 ErrorDocument가 설정되어 있지 않습니다: ${missing}. Apache 기본 에러 페이지가 노출되면 서버 버전 등 정보가 유출될 수 있습니다."
fi
EXPECTED_VALUE="400/401/403/404/500 ErrorDocument 설정"

print_json
