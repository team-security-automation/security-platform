#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
# ============================================================
# U-15 (상) 파일 및 디렉터리 소유자 설정
# 분류: 파일 및 디렉터리 관리 | 대상: Ubuntu (ubuntu)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_15_file_check.sh
# ============================================================

# ============================================================
# 1. 기본 정보
# ============================================================
CHECK_ID="U-15"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="소유자/그룹이 존재하지 않는 파일 및 디렉터리 없음"
RISK_LEVEL="상"
IS_AUTO_FIXABLE="false"
# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
UNOWNED_COUNT=$(find / -xdev \( -nouser -o -nogroup \) 2>/dev/null | grep -v '^/proc' | wc -l)
VALUE="unowned_count=$UNOWNED_COUNT"
CMD_RC=0

if [ "$UNOWNED_COUNT" -eq 0 ]; then
    STATUS="양호"
    CURRENT_VALUE="소유자/그룹 없는 파일 없음"
    EVIDENCE="find / -xdev -nouser -o -nogroup 결과 없음"
else
    SAMPLE=$(find / -xdev \( -nouser -o -nogroup \) 2>/dev/null | grep -v '^/proc' | head -5 | tr '\n' ' ')
    STATUS="취약"
    CURRENT_VALUE="소유자/그룹 없는 파일 ${UNOWNED_COUNT}건"
    EVIDENCE="예시: $SAMPLE"
fi

print_json

# ============================================================
# 6. 정상 종료
# ============================================================
exit 0
