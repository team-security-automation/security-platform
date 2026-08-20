#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
CHECK_ID="WEB-20"; CATEGORY="웹서비스"; RISK_LEVEL="상"; IS_AUTO_FIXABLE="false"

loaded=$(httpd -M 2>/dev/null | grep -i "ssl_module")
sslon=$(grep -riE "^\s*SSLEngine\s+on" /etc/httpd/conf /etc/httpd/conf.d 2>/dev/null | head -1)

if [ -n "$loaded" ] && [ -n "$sslon" ]; then
  STATUS="양호"; CURRENT_VALUE="mod_ssl 로드됨, SSLEngine on 확인"
  EVIDENCE="mod_ssl이 로드되어 있고 SSLEngine on이 설정되어 있어, 전송 구간 암호화(HTTPS)가 적용되고 있습니다."
else
  STATUS="취약"; CURRENT_VALUE="mod_ssl $( [ -n "$loaded" ] && echo "로드됨" || echo "미로드" ), SSLEngine on 미확인"
  EVIDENCE="mod_ssl 로드 여부 또는 SSLEngine on 설정이 확인되지 않습니다. HTTPS가 적용되지 않으면 로그인 정보 등 전송 구간의 데이터가 평문으로 노출되어 스니핑 공격에 취약합니다."
fi
EXPECTED_VALUE="mod_ssl 로드 + SSLEngine on"

print_json
