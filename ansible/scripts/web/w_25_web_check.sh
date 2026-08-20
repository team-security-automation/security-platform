#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
CHECK_ID="WEB-25"; CATEGORY="웹서비스"; RISK_LEVEL="상"; IS_AUTO_FIXABLE="true"

pending=$(dnf check-update httpd\* 2>/dev/null | grep -cE "^httpd")

if [ "$pending" -eq 0 ] 2>/dev/null; then
  STATUS="양호"; CURRENT_VALUE="대기 업데이트 0개"
  EVIDENCE="httpd 관련 패키지에 대기 중인 업데이트가 없어, 알려진 취약점에 대한 패치가 최신 상태로 유지되고 있습니다."
else
  STATUS="취약"; CURRENT_VALUE="대기 업데이트 ${pending}개"
  EVIDENCE="httpd 관련 패키지에 대기 중인 업데이트가 ${pending}개 있습니다. 패치가 지연되면 공개된 취약점(CVE)이 그대로 노출된 상태로 운영될 위험이 있습니다."
fi
EXPECTED_VALUE="대기 업데이트 0개"

print_json
