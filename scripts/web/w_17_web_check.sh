#!/bin/bash
source "$(dirname "$0")/../common/json_output.sh"
CHECK_ID="WEB-17"; CATEGORY="웹서비스"; RISK_LEVEL="중"; IS_AUTO_FIXABLE="true"

found=$(grep -iE "^\s*Alias\s+/(icons|manual)" /etc/httpd/conf/httpd.conf /etc/httpd/conf.d/*.conf 2>/dev/null | tr '\n' ',' | sed 's/,$//; s/,/, /g')

if [ -z "$found" ]; then
  STATUS="양호"; CURRENT_VALUE="없음"
  EVIDENCE="Apache 기본 제공 경로(/icons, /manual 등)로의 Alias 설정이 없어, 불필요한 기본 콘텐츠를 통한 정보 노출이나 버전 유추 위험이 없습니다."
else
  STATUS="취약"; CURRENT_VALUE="$found"
  EVIDENCE="다음과 같이 Apache 기본 제공 경로가 노출되고 있습니다: ${found}. /manual 등은 설치된 Apache 버전을 유추하는 단서가 될 수 있고, 불필요한 공격 표면을 늘립니다."
fi
EXPECTED_VALUE="/icons, /manual 등 기본 Alias 없음"

print_json
