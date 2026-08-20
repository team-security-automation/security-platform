#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
CHECK_ID="WEB-04"; CATEGORY="웹서비스"; RISK_LEVEL="상"; IS_AUTO_FIXABLE="true"

options=$(grep -iE "^\s*Options" /etc/httpd/conf/httpd.conf 2>/dev/null | tr '\n' ' ')

if echo "$options" | grep -qiw "Indexes"; then
  STATUS="취약"
  EVIDENCE="httpd.conf의 Options 지시자에 Indexes가 포함되어 있어, index 파일이 없는 디렉터리에 접근 시 전체 파일 목록이 노출됩니다. 공격자가 이를 통해 소스코드, 백업 파일, 설정 파일 등 민감한 파일의 존재를 파악할 수 있습니다."
else
  STATUS="양호"
  EVIDENCE="Options 지시자에 Indexes가 없어, 디렉터리 인덱싱을 통한 파일 목록 노출 위험이 없습니다."
fi
CURRENT_VALUE="Options ${options:-미확인}"
EXPECTED_VALUE="Options 지시자에 Indexes 미포함"

print_json
