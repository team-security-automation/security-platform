#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
# ============================================================
# U-52 (중) Telnet 서비스 비활성화
# 분류: 서비스관리 | 대상: Ubuntu (ubuntu)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_52_ser_check.sh
# ============================================================

# ============================================================
# 1. 기본 정보
# ============================================================
CHECK_ID="U-52"
CATEGORY="서비스관리"
EXPECTED_VALUE="Telnet 서비스 비활성화(SSH 사용)"
RISK_LEVEL="중"
IS_AUTO_FIXABLE="true"
# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
ACTIVE="no"
EVID=""
systemctl is-active --quiet telnet.socket 2>/dev/null && { ACTIVE="yes"; EVID="telnet.socket 활성; "; }
if [ -f /etc/xinetd.d/telnet ] && grep -qiE '^\s*disable\s*=\s*no' /etc/xinetd.d/telnet 2>/dev/null; then
    ACTIVE="yes"; EVID="${EVID}xinetd telnet disable=no; "
fi
if pgrep -x in.telnetd >/dev/null 2>&1 || pgrep -x telnetd >/dev/null 2>&1; then
    ACTIVE="yes"; EVID="${EVID}telnetd 프로세스 구동 중; "
fi
VALUE="active=$ACTIVE"
CMD_RC=0

if [ "$ACTIVE" = "yes" ]; then
    STATUS="취약"; CURRENT_VALUE="Telnet 활성"; EVIDENCE="$EVID"
else
    STATUS="양호"; CURRENT_VALUE="Telnet 비활성"; EVIDENCE="Telnet 서비스가 비활성 상태(SSH 사용 권장)"
fi

print_json

# ============================================================
# 6. 정상 종료
# ============================================================
exit 0
