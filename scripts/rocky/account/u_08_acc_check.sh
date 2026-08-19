#!/bin/bash
source "$(dirname "$0")/../../common/json_output.sh"
CHECK_ID="U-08"; CATEGORY="계정관리"; RISK_LEVEL="중"; IS_AUTO_FIXABLE="false"
GROUP_NAME="wheel"

members=$(getent group "$GROUP_NAME" | awk -F: '{print $4}')
count=$(echo "$members" | tr ',' '\n' | grep -c .)

if [ "$count" -le 3 ]; then
  STATUS="양호"
  EVIDENCE="관리자 권한 그룹 '${GROUP_NAME}'의 구성원이 ${count}명(${members})으로 소수의 담당자만 관리자 권한을 보유하고 있어, 계정 하나가 탈취돼도 피해 범위가 제한적입니다."
else
  STATUS="취약"
  EVIDENCE="관리자 권한 그룹인 '${GROUP_NAME}'에 ${count}명(${members})이 등록되어 있습니다. 관리자 권한 보유 계정이 많을수록 계정 하나만 탈취돼도 시스템 전체가 위험해지는 공격 표면이 넓어집니다."
fi
CURRENT_VALUE="${GROUP_NAME} 그룹원(${count}명): ${members}"
EXPECTED_VALUE="3명 이하"

print_json
