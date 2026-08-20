#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
# ============================================================
# U-14 (상) root 홈, 패스 디렉터리 권한 및 패스 설정
# 분류: 파일 및 디렉터리 관리 | 대상: Rocky Linux (rocky)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_14_file_check.sh
# ============================================================

# ============================================================
# 1. 기본 정보
# ============================================================
CHECK_ID="U-14"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="PATH 환경변수에 현재 디렉터리(.)가 맨 앞/중간에 미포함"
RISK_LEVEL="상"
IS_AUTO_FIXABLE="false"
# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
CUR_PATH="$PATH"
BAD=0
DOT_FILES=""
if echo ":${CUR_PATH}:" | grep -qE ':\.:'; then
    BAD=1
fi
for f in /etc/profile /root/.bash_profile /root/.bashrc /root/.profile /root/.cshrc /root/.login; do
    if [ -f "$f" ] && grep -E '(PATH=|^[[:space:]]*path[[:space:]])' "$f" 2>/dev/null | grep -qE '(^|[:[:space:]])\.([:[:space:]]|$)'; then
        BAD=1
        DOT_FILES="${DOT_FILES}${f} "
    fi
done
VALUE="path=$CUR_PATH"
CMD_RC=0

if [ $BAD -eq 0 ]; then
    STATUS="양호"
    CURRENT_VALUE="PATH에 '.' 미포함"
    EVIDENCE="현재 PATH 및 root 프로파일 파일에서 '.' 항목을 발견하지 못함: $CUR_PATH"
else
    STATUS="취약"
    CURRENT_VALUE="$CUR_PATH"
    EVIDENCE="PATH 또는 프로파일 파일(${DOT_FILES:-현재 세션 PATH})에 '.' 항목 포함 확인됨"
fi

print_json

# ============================================================
# 6. 정상 종료
# ============================================================
exit 0
