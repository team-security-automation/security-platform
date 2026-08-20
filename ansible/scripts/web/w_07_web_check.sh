#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
CHECK_ID="WEB-07"; CATEGORY="웹서비스"; RISK_LEVEL="중"; IS_AUTO_FIXABLE="false"

found=$(find /var/www/html \( -iname "*manual*" -o -iname "*sample*" -o -iname "*.bak" -o -iname "*.old" \) 2>/dev/null | tr '\n' ',' | sed 's/,$//; s/,/, /g')

if [ -z "$found" ]; then
  STATUS="양호"; CURRENT_VALUE="없음"
  EVIDENCE="/var/www/html 하위에 manual/sample/.bak/.old 패턴의 불필요한 파일이 없습니다."
else
  STATUS="취약"; CURRENT_VALUE="$found"
  EVIDENCE="/var/www/html 하위에 다음 파일이 발견되었습니다: ${found}. 매뉴얼, 샘플, 백업 파일은 소스코드 유출이나 설정 정보 노출로 이어질 수 있어 삭제가 필요합니다."
fi
EXPECTED_VALUE="manual/sample/.bak/.old 패턴 파일 없음"

print_json
