#!/bin/bash
source "$(dirname "$0")/../common/json_output.sh"
CHECK_ID="WEB-14"; CATEGORY="웹서비스"; RISK_LEVEL="상"; IS_AUTO_FIXABLE="true"

conf="/etc/httpd/conf/httpd.conf"
perm=$(stat -c "%a" "$conf" 2>/dev/null)

if [ -n "$perm" ] && [ "$perm" -le 750 ] 2>/dev/null; then
  STATUS="양호"
  EVIDENCE="httpd.conf 파일 권한이 ${perm}로 설정되어 있어, 인가되지 않은 사용자가 웹서버 설정을 열람하거나 변조할 수 없습니다."
else
  STATUS="취약"
  EVIDENCE="httpd.conf 파일 권한이 '${perm:-확인불가}'로 과다하게 열려 있습니다. 설정 파일이 노출되면 내부 구조 정보 유출이나 악의적인 설정 변경으로 이어질 수 있습니다."
fi
CURRENT_VALUE="${conf} 권한:${perm:-확인불가}"
EXPECTED_VALUE="750 이하"

print_json
