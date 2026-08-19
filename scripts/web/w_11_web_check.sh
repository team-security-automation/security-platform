#!/bin/bash
source "$(dirname "$0")/../common/json_output.sh"
CHECK_ID="WEB-11"; CATEGORY="웹서비스"; RISK_LEVEL="상"; IS_AUTO_FIXABLE="false"

docroot=$(httpd -S 2>/dev/null | grep -i "DocumentRoot" | head -1 | sed -E 's/.*DocumentRoot="?([^"]*)"?.*/\1/')
if [ -z "$docroot" ]; then
  docroot=$(grep -iE "^\s*DocumentRoot" /etc/httpd/conf/httpd.conf 2>/dev/null | awk '{print $2}' | tr -d '"' | tail -1)
fi

if [ -n "$docroot" ] && [ "$docroot" != "/var/www/html" ]; then
  STATUS="양호"
  EVIDENCE="DocumentRoot가 시스템 기본 경로(/var/www/html)가 아닌 '${docroot}'로 분리되어 있어, 패키지 기본 경로를 노린 자동화된 공격 스캔의 성공률을 낮춥니다."
else
  STATUS="수동확인"
  EVIDENCE="DocumentRoot가 시스템 기본 경로(/var/www/html)를 그대로 사용하고 있습니다. 별도 경로로 분리하는 것이 권장되나, 실제 운영 구조(심볼릭 링크 구성, 배포 파이프라인 등)에 따라 영향 범위가 다를 수 있어 담당자의 판단이 필요합니다."
fi
CURRENT_VALUE="DocumentRoot ${docroot:-/var/www/html}"
EXPECTED_VALUE="DocumentRoot가 기본 경로(/var/www/html)와 다름"

print_json
