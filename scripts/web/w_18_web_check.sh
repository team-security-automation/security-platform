#!/bin/bash
source "$(dirname "$0")/../common/json_output.sh"
CHECK_ID="WEB-18"; CATEGORY="웹서비스"; RISK_LEVEL="상"; IS_AUTO_FIXABLE="true"

loaded=$(httpd -M 2>/dev/null | grep -i "dav_module")
davdir=$(grep -iE "^\s*Dav\s" /etc/httpd/conf/httpd.conf /etc/httpd/conf.d/*.conf 2>/dev/null | grep -viw "off")

if [ -z "$loaded" ] && [ -z "$davdir" ]; then
  STATUS="양호"; CURRENT_VALUE="mod_dav 미사용"
  EVIDENCE="mod_dav가 로드되어 있지 않고 Dav 지시자도 활성화되어 있지 않아, WebDAV를 통한 임의 파일 업로드·삭제 위험이 없습니다."
else
  STATUS="취약"; CURRENT_VALUE="mod_dav 로드 또는 Dav 활성화: ${davdir:-$loaded}"
  EVIDENCE="mod_dav가 로드되어 있거나 Dav 지시자가 활성화되어 있습니다. WebDAV가 활성화되면 인증 우회나 설정 미흡 시 임의 파일 업로드를 통한 웹셸 업로드로 이어질 수 있습니다."
fi
EXPECTED_VALUE="mod_dav 미사용/Dav Off"

print_json
