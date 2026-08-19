#!/bin/bash
source "$(dirname "$0")/../common/json_output.sh"
CHECK_ID="WEB-10"; CATEGORY="웹서비스"; RISK_LEVEL="상"; IS_AUTO_FIXABLE="true"

loaded=$(httpd -M 2>/dev/null | grep -i "proxy_module")
proxyreq=$(grep -iE "^\s*ProxyRequests" /etc/httpd/conf/httpd.conf 2>/dev/null | awk '{print $2}' | tail -1)

if [ -z "$loaded" ] || [ "$proxyreq" == "Off" ] || [ "$proxyreq" == "off" ]; then
  STATUS="양호"
  EVIDENCE="mod_proxy가 비활성화되어 있거나 ProxyRequests가 Off로 설정되어 있어, 서버가 오픈 프록시로 악용되어 내부망 스캔이나 익명 우회 경유지로 사용될 위험이 없습니다."
else
  STATUS="취약"
  EVIDENCE="mod_proxy가 로드되어 있고 ProxyRequests가 꺼져있지 않습니다. 정방향 프록시 기능이 활성화되면 서버가 오픈 프록시로 악용되어 공격자의 익명화 경유지나 내부망 스캔 통로로 쓰일 수 있습니다."
fi
CURRENT_VALUE="mod_proxy $( [ -z "$loaded" ] && echo "미사용" || echo "로드됨" ), ProxyRequests ${proxyreq:-미설정}"
EXPECTED_VALUE="mod_proxy 미사용 또는 ProxyRequests Off"

print_json
