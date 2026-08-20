#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
# ============================================================
# U-17 (상) 시스템 시작 스크립트 권한 설정
# 분류: 파일 및 디렉터리 관리 | 대상: Ubuntu (ubuntu)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_17_file_check.sh
# ============================================================

# ============================================================
# 1. 기본 정보
# ============================================================
CHECK_ID="U-17"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="소유자 root, 일반 사용자 쓰기 권한 제거"
RISK_LEVEL="상"
IS_AUTO_FIXABLE="true"
# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
TARGET_DIR="/etc/systemd/system"
if [ ! -d "$TARGET_DIR" ]; then
    STATUS="수동확인 필요"; CURRENT_VALUE="디렉터리 없음"; EVIDENCE="$TARGET_DIR 없음"
else
    BAD_COUNT=0; BAD_SAMPLES=""
    while IFS= read -r -d '' f; do
        [ -L "$f" ] && continue
        OWNER=$(stat -c '%U' "$f" 2>/dev/null)
        PERM=$(stat -c '%a' "$f" 2>/dev/null)
        OTHER_W=$(( (10#$PERM) % 10 ))
        if [ "$OWNER" != "root" ] || [ $(( OTHER_W & 2 )) -ne 0 ]; then
            BAD_COUNT=$((BAD_COUNT + 1))
            [ $BAD_COUNT -le 5 ] && BAD_SAMPLES="${BAD_SAMPLES}${f}(${OWNER}:${PERM}) "
        fi
    done < <(find "$TARGET_DIR" -maxdepth 1 -type f \( -name '*.service' -o -name '*.socket' -o -name '*.timer' -o -name '*.target' -o -name '*.mount' \) -print0 2>/dev/null)
    VALUE="bad_count=$BAD_COUNT"
    CMD_RC=0
    if [ "$BAD_COUNT" -eq 0 ]; then
        STATUS="양호"; CURRENT_VALUE="기준 충족"; EVIDENCE="$TARGET_DIR 내 유닛 파일이 소유자 root, 일반사용자 쓰기 권한 없음 기준을 충족"
    else
        STATUS="취약"; CURRENT_VALUE="위반 ${BAD_COUNT}건"; EVIDENCE="예시: $BAD_SAMPLES"
    fi
fi

print_json

# ============================================================
# 6. 정상 종료
# ============================================================
exit 0
