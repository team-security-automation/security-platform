#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
CHECK_ID="WEB-03"; CATEGORY="웹서비스"; RISK_LEVEL="상"; IS_AUTO_FIXABLE="false"

STATUS="해당없음"
CURRENT_VALUE="N/A"
EXPECTED_VALUE="N/A"
EVIDENCE="KISA 기준상 Tomcat/IIS/JEUS 대상 항목으로, 본 서버(Apache)에는 해당사항 없음"

print_json
