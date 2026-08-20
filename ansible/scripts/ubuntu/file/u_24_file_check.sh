#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
# ============================================================
# U-24 (상) 사용자, 시스템 환경변수 파일 소유자 및 권한 설정
# 분류: 파일 및 디렉터리 관리 | 대상: Ubuntu (ubuntu)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_24_file_check.sh
# ============================================================

# ============================================================
# 1. 기본 정보
# ============================================================
CHECK_ID="U-24"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="환경변수 파일 소유자가 root/해당 계정, 타 사용자 쓰기 권한 제거"
RISK_LEVEL="상"
IS_AUTO_FIXABLE="true"
# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
ENV_FILES=".profile .bashrc .bash_profile .kshrc .cshrc .login .exrc .netrc"
BAD_COUNT=0; BAD_SAMPLES=""; CHECKED=0
while IFS=: read -r uname _ uid _ _ home shell; do
    [ "$uid" -lt 1000 ] && [ "$uname" != "root" ] && continue
    [ -d "$home" ] || continue
    for ef in $ENV_FILES; do
        f="$home/$ef"
        [ -f "$f" ] || continue
        CHECKED=$((CHECKED+1))
        OWNER=$(stat -c '%U' "$f" 2>/dev/null)
        PERM=$(stat -c '%a' "$f" 2>/dev/null)
        OTHER_W=$(( (10#$PERM) % 10 ))
        if { [ "$OWNER" != "root" ] && [ "$OWNER" != "$uname" ]; } || [ $(( OTHER_W & 2 )) -ne 0 ]; then
            BAD_COUNT=$((BAD_COUNT + 1))
            [ $BAD_COUNT -le 5 ] && BAD_SAMPLES="${BAD_SAMPLES}${f}(${OWNER}:${PERM}) "
        fi
    done
done < /etc/passwd
VALUE="checked=$CHECKED bad=$BAD_COUNT"
CMD_RC=0

if [ "$CHECKED" -eq 0 ]; then
    STATUS="양호"; CURRENT_VALUE="점검 대상 환경변수 파일 없음"; EVIDENCE="홈 디렉터리 내 환경변수 파일이 존재하지 않음"
elif [ "$BAD_COUNT" -eq 0 ]; then
    STATUS="양호"; CURRENT_VALUE="기준 충족(${CHECKED}건 점검)"; EVIDENCE="모든 환경변수 파일이 소유자/타사용자 쓰기권한 기준을 충족"
else
    STATUS="취약"; CURRENT_VALUE="위반 ${BAD_COUNT}/${CHECKED}건"; EVIDENCE="예시: $BAD_SAMPLES"
fi

print_json

# ============================================================
# 6. 정상 종료
# ============================================================
exit 0
