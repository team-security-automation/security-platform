#!/bin/bash
# ============================================================
# U-25 (상) world writable 파일 점검 - 조치 스크립트
# 분류: 파일 및 디렉터리 관리 | 대상: Rocky Linux (rocky)
# 주의: 설정 파일을 변경하는 경우 원본을 .bak_<시각> 으로 백업합니다.
#       운영 서버 적용 전 반드시 테스트 서버에서 먼저 검증하세요.
# 실행: sudo bash u_25_file_fix.sh
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
FIX_ID="U-25"
CATEGORY="파일 및 디렉터리 관리"
RISK_LEVEL="상"

# ============================================================
# 2~4. 현재 상태 확인 후 필요 시 조치 실행
#   STATUS 값: 조치완료 | 조치불필요 | 조치실패 | 수동조치필요
# ============================================================
EXCLUDE_RE='^/(proc|sys|dev|tmp|var/tmp|var/spool/mail|var/spool/postfix|run)(/|$)'
FIXED=0
while IFS= read -r -d '' f; do
    echo "$f" | grep -qE "$EXCLUDE_RE" && continue
    chmod o-w "$f" 2>/dev/null && FIXED=$((FIXED + 1))
done < <(find / -xdev -type f -perm -0002 -print0 2>/dev/null)

if [ $FIXED -gt 0 ]; then
    STATUS="조치완료"; ACTION="${FIXED}개 world writable 파일에서 일반 사용자 쓰기 권한을 제거함(/tmp 등 예외 경로 제외)"
else
    STATUS="조치불필요"; ACTION="world writable 파일이 없거나 모두 예외 경로 내에 있음"
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
