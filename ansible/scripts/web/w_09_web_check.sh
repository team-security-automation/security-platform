#!/bin/bash
source "$(dirname "$0")/../common/json_output.sh"
CHECK_ID="WEB-09"; CATEGORY="웹서비스"; RISK_LEVEL="상"; IS_AUTO_FIXABLE="true"

user=$(grep -iE "^\s*User\s" /etc/httpd/conf/httpd.conf 2>/dev/null | awk '{print $2}' | tail -1)
group=$(grep -iE "^\s*Group\s" /etc/httpd/conf/httpd.conf 2>/dev/null | awk '{print $2}' | tail -1)

if [ -n "$user" ] && [ "$user" != "root" ]; then
  STATUS="양호"
  EVIDENCE="Apache 프로세스가 '${user}' 계정(비root)으로 구동되도록 설정되어 있어, 웹 애플리케이션 취약점이 악용되더라도 root 권한 탈취로 곧바로 이어지지 않습니다."
else
  STATUS="취약"
  EVIDENCE="Apache 프로세스의 User 지시자가 '${user:-미설정(기본값 root일 수 있음)}'으로 되어 있습니다. root 권한으로 웹서버가 구동되면 웹 애플리케이션 취약점 하나로 시스템 전체가 탈취될 수 있습니다."
fi
CURRENT_VALUE="User ${user:-미설정}, Group ${group:-미설정}"
EXPECTED_VALUE="User apache(비root)"

print_json
