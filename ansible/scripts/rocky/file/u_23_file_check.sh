#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
# ============================================================
# U-23 (상) SUID, SGID, Sticky bit 설정 파일 점검
# 분류: 파일 및 디렉터리 관리 | 대상: Rocky Linux (rocky)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_23_file_check.sh
# ============================================================

# ============================================================
# 1. 기본 정보
# ============================================================
CHECK_ID="U-23"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="표준 목록 외 SUID/SGID 설정 파일 없음"
RISK_LEVEL="상"
IS_AUTO_FIXABLE="false"
# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
WHITELIST_REGEX='/(usr/bin/passwd|usr/bin/su|usr/bin/sudo|usr/bin/sudoedit|usr/bin/chsh|usr/bin/chfn|usr/bin/chage|usr/bin/gpasswd|usr/bin/newgrp|usr/bin/mount|usr/bin/umount|usr/bin/pkexec|usr/bin/crontab|usr/bin/at|usr/lib/polkit-1/polkit-agent-helper-1|usr/libexec/.*|usr/bin/fusermount3?|usr/bin/ping|usr/sbin/pam_timestamp_check|usr/sbin/unix_chkpwd)$'
FOUND_COUNT=0; SUSPECT_COUNT=0; SUSPECT_SAMPLES=""
while IFS= read -r -d '' f; do
    FOUND_COUNT=$((FOUND_COUNT+1))
    if ! echo "$f" | grep -qE "$WHITELIST_REGEX"; then
        SUSPECT_COUNT=$((SUSPECT_COUNT+1))
        [ $SUSPECT_COUNT -le 8 ] && SUSPECT_SAMPLES="${SUSPECT_SAMPLES}${f} "
    fi
done < <(find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -print0 2>/dev/null)
VALUE="found=$FOUND_COUNT suspect=$SUSPECT_COUNT"
CMD_RC=0

if [ "$SUSPECT_COUNT" -eq 0 ]; then
    STATUS="양호"; CURRENT_VALUE="표준 목록 외 SUID/SGID 파일 없음(전체 ${FOUND_COUNT}건)"; EVIDENCE="발견된 SUID/SGID 파일이 모두 표준 화이트리스트에 해당"
else
    STATUS="취약"; CURRENT_VALUE="표준 목록 외 SUID/SGID 파일 ${SUSPECT_COUNT}건(전체 ${FOUND_COUNT}건)"; EVIDENCE="예시: $SUSPECT_SAMPLES"
fi

print_json

# ============================================================
# 6. 정상 종료
# ============================================================
exit 0
