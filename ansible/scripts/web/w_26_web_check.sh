#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
CHECK_ID="WEB-26"; CATEGORY="웹서비스"; RISK_LEVEL="중"; IS_AUTO_FIXABLE="true"

dir="/var/log/httpd"
dir_perm=$(stat -c "%a" "$dir" 2>/dev/null)
bad_files=$(find "$dir" -type f 2>/dev/null -exec stat -c "%n:%a" {} \; | awk -F: '$2+0 > 640 {print $1"("$2")"}' | tr '\n' ',' | sed 's/,$//; s/,/, /g')

if [ -n "$dir_perm" ] && [ "$dir_perm" -le 750 ] 2>/dev/null && [ -z "$bad_files" ]; then
  STATUS="양호"; CURRENT_VALUE="${dir} 권한:${dir_perm}, 개별 파일 모두 640 이하"
  EVIDENCE="로그 디렉터리(${dir}) 권한이 ${dir_perm}, 내부 로그 파일도 모두 640 이하로 설정되어 있어 접근 로그·에러 로그를 통한 민감 정보(세션 값, 내부 경로 등) 노출 위험이 없습니다."
else
  STATUS="취약"; CURRENT_VALUE="${dir} 권한:${dir_perm:-확인불가}, 초과 파일: ${bad_files:-없음}"
  EVIDENCE="로그 디렉터리 또는 파일 권한이 과다합니다(디렉터리 ${dir_perm:-확인불가}, 초과 파일: ${bad_files:-없음}). 로그 파일이 노출되면 요청 파라미터에 포함된 민감 정보나 서버 내부 경로 등이 유출될 수 있습니다."
fi
EXPECTED_VALUE="디렉터리 750 이하, 파일 640 이하"

print_json
