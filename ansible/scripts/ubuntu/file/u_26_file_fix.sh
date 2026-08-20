#!/bin/bash
# ============================================================
# U-26 (상) /dev에 존재하지 않는 device 파일 점검 - 조치 스크립트
# 분류: 파일 및 디렉터리 관리 | 대상: Ubuntu (ubuntu)
# 주의: 설정 파일을 변경하는 경우 원본을 .bak_<시각> 으로 백업합니다.
#       운영 서버 적용 전 반드시 테스트 서버에서 먼저 검증하세요.
# 실행: sudo bash u_26_file_fix.sh
# ============================================================

# JSON 이스케이프 유틸 (따옴표/개행 처리)
json_esc() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="$(printf '%s' "$s" | tr '\n' ' ')"
    printf '%s' "$s"
}

# ============================================================
# 1. 기본 정보
# ============================================================
FIX_ID="U-26"
CATEGORY="파일 및 디렉터리 관리"
RISK_LEVEL="상"

# ============================================================
# 2~4. 현재 상태 확인 후 필요 시 조치 실행
#   STATUS 값: 조치완료 | 조치불필요 | 조치실패 | 수동조치필요
# ============================================================
QDIR="/root/kisa_u26_quarantine_$(date +%Y%m%d%H%M%S)"
FIXED=0
while IFS= read -r -d '' f; do
    case "$f" in
        /dev/shm/*|/dev/mqueue/*) continue ;;
    esac
    mkdir -p "$QDIR"
    mv "$f" "$QDIR/" 2>/dev/null && FIXED=$((FIXED + 1))
done < <(find /dev -xdev -type f -print0 2>/dev/null)

if [ $FIXED -gt 0 ]; then
    STATUS="조치완료"; ACTION="${FIXED}개의 비정상(major/minor 없는) /dev 내 파일을 ${QDIR} 로 격리 이동함(즉시 삭제 대신 검토 후 삭제 권고)"
else
    STATUS="조치불필요"; ACTION="/dev 내 비정상 파일이 없음(/dev/shm, /dev/mqueue 제외)"
fi

# ============================================================
# 5. JSON 출력
# ============================================================
cat <<EOF
{
  "fix_id": "$(json_esc "$FIX_ID")",
  "category": "$(json_esc "$CATEGORY")",
  "status": "$(json_esc "$STATUS")",
  "action": "$(json_esc "$ACTION")",
  "hostname": "$(hostname)",
  "risk_level": "$(json_esc "$RISK_LEVEL")"
}
EOF

# ============================================================
# 6. 정상 종료
# ============================================================
exit 0
