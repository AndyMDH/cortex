#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/vault-template"

VAULT_PATH="${1:-}"
if [ -z "$VAULT_PATH" ]; then
  read -rp "Vault path to update [$HOME/Obsidian/Cortex]: " VAULT_PATH
  VAULT_PATH="${VAULT_PATH:-$HOME/Obsidian/Cortex}"
fi
VAULT_PATH="${VAULT_PATH/#\~/$HOME}"

CONFIG="$VAULT_PATH/90-System/.cortex-config"
if [ ! -f "$CONFIG" ]; then
  echo "Error: no $CONFIG found."
  echo "This doesn't look like a vault created by install.sh (or it predates"
  echo "the config file this script relies on) - update the files by hand instead."
  exit 1
fi
# shellcheck source=/dev/null
source "$CONFIG"

echo "Updating Cortex system files in: $VAULT_PATH"
echo "Your notes (00-Inbox/, 10-Meetings/, 20-Wikis/, 30-Tags/) are never touched."
echo

substitute() {
  local file="$1"
  sed -i '' \
    -e "s|{{VAULT_PATH}}|$VAULT_PATH|g" \
    -e "s|{{VAULT_NAME}}|$VAULT_NAME|g" \
    -e "s|{{ALIAS_NAME}}|$ALIAS_NAME|g" \
    -e "s|{{CLAUDE_DIR}}|$CLAUDE_DIR|g" \
    -e "s|{{RUN_HOUR}}|$RUN_HOUR|g" \
    -e "s|{{RUN_MINUTE}}|$RUN_MINUTE|g" \
    "$file"
}

cp "$TEMPLATE_DIR/90-System/run.sh.template" "$VAULT_PATH/90-System/run.sh"
substitute "$VAULT_PATH/90-System/run.sh"
chmod +x "$VAULT_PATH/90-System/run.sh"

cp "$TEMPLATE_DIR/90-System/quick-capture.sh.template" "$VAULT_PATH/90-System/quick-capture.sh"
substitute "$VAULT_PATH/90-System/quick-capture.sh"
chmod +x "$VAULT_PATH/90-System/quick-capture.sh"

cp "$TEMPLATE_DIR/90-System/com.cortex.pipeline.plist.template" "$VAULT_PATH/90-System/com.cortex.pipeline.plist"
substitute "$VAULT_PATH/90-System/com.cortex.pipeline.plist"

cp "$TEMPLATE_DIR/90-System/doctor.sh" "$VAULT_PATH/90-System/doctor.sh"
chmod +x "$VAULT_PATH/90-System/doctor.sh"

cp -R "$TEMPLATE_DIR/.claude/skills/." "$VAULT_PATH/.claude/skills/"

echo "Done. Updated: run.sh, quick-capture.sh, launchd plist, doctor.sh, and both skills."
echo

if launchctl list 2>/dev/null | grep -q local.cortex.pipeline; then
  echo "A launchd job is currently loaded - reload it to pick up the new plist:"
  echo "  launchctl unload ~/Library/LaunchAgents/com.cortex.pipeline.plist"
  echo "  cp \"$VAULT_PATH/90-System/com.cortex.pipeline.plist\" ~/Library/LaunchAgents/"
  echo "  launchctl load ~/Library/LaunchAgents/com.cortex.pipeline.plist"
fi
