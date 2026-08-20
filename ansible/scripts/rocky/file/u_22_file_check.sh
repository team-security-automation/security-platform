#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
# ============================================================
# U-22 (상) /etc/services 파일 소유자 및 권한 설정
# 분류: 파일 및 디렉터리 관리 | 대상: Rocky Linux (rocky)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_22_file_check.sh
# ============================================================

# ============================================================
# 1. 기본 정보
# ============================================================
CHECK_ID="U-22"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="소유자 root(bin/sys), 권한 644 이하"
RISK_LEVEL="상"
IS_AUTO_FIXABLE="true"
# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
FILE="/etc/services"
if [ ! -f "$FILE" ]; then
    STATUS="수동확인 필요"; CURRENT_VALUE="파일 없음"; EVIDENCE="$FILE 이 존재하지 않음"
else
    OWNER=$(stat -c '%U' "$FILE" 2>/dev/null)
    PERM=$(stat -c '%a' "$FILE" 2>/dev/null)
    VALUE="owner=$OWNER perm=$PERM"
    CMD_RC=$?
    PERM_NUM=$((10#$PERM))
    if echo "$OWNER" | grep -qE '^(root|bin|sys)$' && [ "$PERM_NUM" -le 644 ]; then
        STATUS="양호"; CURRENT_VALUE="소유자:$OWNER 권한:$PERM"; EVIDENCE="기준(root/bin/sys 소유, 644 이하) 충족"
    else
        STATUS="취약"; CURRENT_VALUE="소유자:$OWNER 권한:$PERM"; EVIDENCE="기준(root/bin/sys 소유, 644 이하) 미충족"
    fi
fi

print_json

# ============================================================
# 6. 정상 종료
# ============================================================
exit 0
