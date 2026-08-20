#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
CHECK_ID="WEB-05"; CATEGORY="웹서비스"; RISK_LEVEL="상"; IS_AUTO_FIXABLE="true"

loaded=$(httpd -M 2>/dev/null | grep -i "cgi_module")

if [ -z "$loaded" ]; then
  STATUS="양호"; CURRENT_VALUE="mod_cgi 미사용"
  EVIDENCE="mod_cgi(cgi_module)가 로드되어 있지 않아 CGI 스크립트 실행 경로를 통한 임의 명령 실행 위험이 없습니다."
else
  STATUS="취약"; CURRENT_VALUE="$loaded"
  EVIDENCE="cgi_module이 로드되어 있습니다: ${loaded}. 불필요한 CGI 실행 기능이 활성화되어 있으면 취약한 CGI 스크립트를 통해 임의 명령 실행(RCE)으로 이어질 수 있습니다."
fi
EXPECTED_VALUE="mod_cgi 미사용"

print_json
