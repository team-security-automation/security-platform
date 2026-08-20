#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/json_output.sh"
# ============================================================
# U-51 (중) DNS 서비스의 취약한 동적 업데이트 설정 금지
# 분류: 서비스관리 | 대상: Rocky Linux (rocky)
# 근거: 2026 주요정보통신기반시설 기술적 취약점 분석평가 방법 상세가이드(KISA)
# 실행: sudo bash u_51_ser_check.sh
# ============================================================

# ============================================================
# 1. 기본 정보
# ============================================================
CHECK_ID="U-51"
CATEGORY="서비스관리"
EXPECTED_VALUE="동적 업데이트 비활성 또는 제한된 대상에만 허용"
RISK_LEVEL="중"
IS_AUTO_FIXABLE="true"
# ============================================================
# 2. 진단 명령 실행 / 3. 결과 처리 / 4. 양호·취약 판단
# ============================================================
BIND_ACTIVE="no"
for svc in "named"; do
    systemctl is-active --quiet "$svc" 2>/dev/null && BIND_ACTIVE="yes"
done

CONF=""
for f in "/etc/named.conf"; do
    [ -f "$f" ] && { CONF="$f"; break; }
done

if [ "$BIND_ACTIVE" = "no" ]; then
    STATUS="양호"; CURRENT_VALUE="DNS 서비스 미사용"; EVIDENCE="BIND 비활성 상태로 해당 없음"
elif [ -z "$CONF" ]; then
    STATUS="수동확인 필요"; CURRENT_VALUE="설정파일 미탐지"; EVIDENCE="BIND는 활성이나 named.conf 위치를 찾지 못함"
else
    VALUE=$(grep -i 'allow-update' "$CONF" 2>/dev/null | head -1)
    CMD_RC=$?
    if [ -z "$VALUE" ] || echo "$VALUE" | grep -qE '\bnone\b'; then
        STATUS="양호"; CURRENT_VALUE="${VALUE:-설정없음(기본 비활성)}"; EVIDENCE="동적 업데이트가 비활성 또는 미설정 상태"
    elif echo "$VALUE" | grep -qE '\bany\b'; then
        STATUS="취약"; CURRENT_VALUE="$VALUE"; EVIDENCE="모든 호스트에 동적 업데이트가 허용됨"
    else
        STATUS="양호"; CURRENT_VALUE="$VALUE"; EVIDENCE="동적 업데이트가 특정 대상으로 제한됨"
    fi
fi

print_json

# ============================================================
# 6. 정상 종료
# ============================================================
exit 0
