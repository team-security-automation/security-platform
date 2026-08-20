#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
# ============================================================
# U-27 (상) $HOME/.rhosts, hosts.equiv 사용 금지
# 분류: 파일 및 디렉터리 관리 | 대상: Rocky Linux (rocky)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_27_file_check.sh
# ============================================================

# ============================================================
# 1. 기본 정보
# ============================================================
CHECK_ID="U-27"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="r-command 미사용 또는 소유자/권한(600)/'+' 미설정 기준 충족"
RISK_LEVEL="상"
IS_AUTO_FIXABLE="true"
# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
RSVC_ACTIVE="no"
for svc in rlogin rsh rexec rlogin.socket rsh.socket; do
    systemctl is-active --quiet "$svc" 2>/dev/null && RSVC_ACTIVE="yes"
done
VALUE="rsvc_active=$RSVC_ACTIVE"
CMD_RC=0

if [ "$RSVC_ACTIVE" = "no" ]; then
    STATUS="양호"; CURRENT_VALUE="r-command 서비스 미사용"; EVIDENCE="rlogin/rsh/rexec 서비스가 비활성 상태"
else
    BAD=0; EVID=""
    if [ -f /etc/hosts.equiv ]; then
        O=$(stat -c '%U' /etc/hosts.equiv 2>/dev/null); P=$(stat -c '%a' /etc/hosts.equiv 2>/dev/null); PN=$((10#$P))
        if [ "$O" != "root" ] || [ "$PN" -gt 600 ] || grep -qE '^\+' /etc/hosts.equiv 2>/dev/null; then
            BAD=1; EVID="${EVID}/etc/hosts.equiv(소유자:$O,권한:$P) "
        fi
    fi
    while IFS=: read -r uname _ uid _ _ home _; do
        [ "$uid" -lt 1000 ] && [ "$uname" != "root" ] && continue
        f="$home/.rhosts"
        [ -f "$f" ] || continue
        O=$(stat -c '%U' "$f" 2>/dev/null); P=$(stat -c '%a' "$f" 2>/dev/null); PN=$((10#$P))
        if { [ "$O" != "root" ] && [ "$O" != "$uname" ]; } || [ "$PN" -gt 600 ] || grep -qE '^\+' "$f" 2>/dev/null; then
            BAD=1; EVID="${EVID}${f}(소유자:$O,권한:$P) "
        fi
    done < /etc/passwd
    VALUE="bad=$BAD"
    if [ $BAD -eq 0 ]; then
        STATUS="양호"; CURRENT_VALUE="r-command 사용 중이나 설정 안전"; EVIDENCE="hosts.equiv/.rhosts 소유자·권한·'+' 설정 기준 충족"
    else
        STATUS="취약"; CURRENT_VALUE="설정 미흡"; EVIDENCE="$EVID"
    fi
fi

print_json

# ============================================================
# 6. 정상 종료
# ============================================================
exit 0
