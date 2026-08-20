#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
CHECK_ID="WEB-21"; CATEGORY="웹서비스"; RISK_LEVEL="중"; IS_AUTO_FIXABLE="false"

redirect=$(grep -riE "Redirect(Permanent)?\s+/|RewriteRule.*https" /etc/httpd/conf/httpd.conf /etc/httpd/conf.d/*.conf 2>/dev/null | head -1)

if [ -n "$redirect" ]; then
  STATUS="양호"; CURRENT_VALUE="리다이렉트 설정 발견"
  EVIDENCE="80번 포트로 들어온 요청을 HTTPS로 리다이렉트하는 설정이 확인되어, 사용자가 실수로 HTTP로 접속해도 자동으로 암호화된 채널로 전환됩니다."
else
  STATUS="취약"; CURRENT_VALUE="리다이렉트 설정 없음"
  EVIDENCE="80번 포트의 HTTP 요청을 HTTPS로 리다이렉트하는 Redirect/RewriteRule 설정이 확인되지 않습니다. 사용자가 HTTP로 접속할 경우 암호화 없이 평문 통신이 이루어질 수 있습니다."
fi
EXPECTED_VALUE="HTTP → HTTPS 리다이렉트 설정 존재"

print_json
