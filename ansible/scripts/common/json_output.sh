print_json() {
  local bool="false"
  [ "$IS_AUTO_FIXABLE" == "true" ] && bool="true"

  _esc() {
    printf '%s' "$1" \
      | sed 's/\\/\\\\/g; s/"/\\"/g' \
      | sed ':a;N;$!ba; s/\n/\\n/g' \
      | tr -d '\t\r'
  }

  printf '{"check_id":"%s","category":"%s","status":"%s","current_value":"%s","expected_value":"%s","evidence":"%s","risk_level":"%s","is_auto_fixable":%s}\n' \
    "$(_esc "$CHECK_ID")" "$(_esc "$CATEGORY")" "$(_esc "$STATUS")" "$(_esc "$CURRENT_VALUE")" \
    "$(_esc "$EXPECTED_VALUE")" "$(_esc "$EVIDENCE")" "$(_esc "$RISK_LEVEL")" "$bool"
}