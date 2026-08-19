#!/bin/bash
source "$(dirname "$0")/../common/json_output.sh"
CHECK_ID="WEB-24"; CATEGORY="웹서비스"; RISK_LEVEL="중"; IS_AUTO_FIXABLE="false"

STATUS="해당없음"
CURRENT_VALUE="파일 업로드 기능 미구현"
EXPECTED_VALUE="N/A"
EVIDENCE="현재 업로드 기능 미구현으로 해당사항 없음, 향후 기능 추가 시 점검 필요"

print_json
