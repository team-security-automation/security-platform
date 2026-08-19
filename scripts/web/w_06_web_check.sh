#!/bin/bash
source "$(dirname "$0")/../common/json_output.sh"
CHECK_ID="WEB-06"; CATEGORY="웹서비스"; RISK_LEVEL="상"; IS_AUTO_FIXABLE="true"

value=$(grep -iE "^\s*AllowOverride" /etc/httpd/conf/httpd.conf 2>/dev/null | awk '{print $2}' | tail -1)

if [ -n "$value" ] && [ "$value" != "None" ]; then
  STATUS="양호"
  EVIDENCE="AllowOverride가 '${value}'로 설정되어 있어 .htaccess를 통한 디렉터리별 접근 제어 정책 적용이 가능합니다."
else
  STATUS="취약"
  EVIDENCE="AllowOverride가 'None'(또는 미설정)으로 되어 있어 .htaccess를 통한 세부 접근 제어를 적용할 수 없습니다. 디렉터리별 보안 정책을 유연하게 적용하기 어려워 관리 사각지대가 발생할 수 있습니다."
fi
CURRENT_VALUE="AllowOverride ${value:-None}"
EXPECTED_VALUE="AllowOverride None이 아님(AuthConfig 등)"

print_json
