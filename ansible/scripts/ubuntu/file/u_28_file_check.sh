#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
# ============================================================
# U-28 (상) 접속 IP 및 포트 제한
# 분류: 파일 및 디렉터리 관리 | 대상: Ubuntu (ubuntu)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_28_file_check.sh
# ============================================================

# ============================================================
# 1. 기본 정보
# ============================================================
CHECK_ID="U-28"
CATEGORY="파일 및 디렉터리 관리"
EXPECTED_VALUE="허용 호스트에 대한 IP·포트 제한 설정 존재"
RISK_LEVEL="상"
IS_AUTO_FIXABLE="false"
# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
CONTROL="no"; EVID=""
if [ -f /etc/hosts.allow ] && grep -qvE '^\s*#|^\s*$' /etc/hosts.allow 2>/dev/null; then
    CONTROL="yes"; EVID="${EVID}hosts.allow 규칙 존재; "
fi
if [ -f /etc/hosts.deny ] && grep -qE '^\s*ALL\s*:\s*ALL' /etc/hosts.deny 2>/dev/null; then
    CONTROL="yes"; EVID="${EVID}hosts.deny ALL:ALL 존재; "
fi
if command -v iptables >/dev/null 2>&1 && iptables -L INPUT 2>/dev/null | grep -qvE '^Chain|^target|^$'; then
    CONTROL="yes"; EVID="${EVID}iptables INPUT 규칙 존재; "
fi
if command -v firewall-cmd >/dev/null 2>&1 && systemctl is-active --quiet firewalld 2>/dev/null; then
    CONTROL="yes"; EVID="${EVID}firewalld 활성; "
fi
if command -v ufw >/dev/null 2>&1 && ufw status 2>/dev/null | grep -qi 'active'; then
    CONTROL="yes"; EVID="${EVID}ufw 활성; "
fi
VALUE="control=$CONTROL"
CMD_RC=0

if [ "$CONTROL" = "yes" ]; then
    STATUS="양호"; CURRENT_VALUE="접근제어 존재"; EVIDENCE="$EVID"
else
    STATUS="취약"; CURRENT_VALUE="접근제어 미탐지"; EVIDENCE="TCP Wrapper/iptables/firewalld/ufw 등 IP·포트 제한 설정을 찾지 못함"
fi

print_json

# ============================================================
# 6. 정상 종료
# ============================================================
exit 0
