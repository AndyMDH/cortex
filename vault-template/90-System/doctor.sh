#!/usr/bin/env bash
# Deliberately no `set -e`: check() inspects $? from commands that are
# expected to fail (missing deps, missing folders), and -e would abort the
# script on the first one instead of reporting all of them.
set -uo pipefail

VAULT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

check() {
  local ok="$1" msg="$2"
  if [ "$ok" -eq 0 ]; then
    echo "[OK]      $msg"
  else
    echo "[MISSING] $msg"
    FAIL=1
  fi
}

echo "Cortex doctor - checking $VAULT"
echo

command -v claude >/dev/null 2>&1
check $? "claude (Claude Code CLI) is on PATH"

command -v git >/dev/null 2>&1
check $? "git is on PATH"

[ -d "/Applications/Obsidian.app" ]
check $? "Obsidian.app is installed in /Applications"

[ -x "$VAULT/90-System/run.sh" ]
check $? "run.sh exists and is executable"

for d in "00-Inbox" "10-Meetings" "20-Wikis" "30-Tags"; do
  [ -d "$VAULT/$d" ]
  check $? "$d/ exists"
done

[ -d "$VAULT/.claude/skills/meeting-enricher" ] && [ -d "$VAULT/.claude/skills/wiki-builder" ]
check $? "both Claude Code skills (meeting-enricher, wiki-builder) are present"

echo
if launchctl list 2>/dev/null | grep -q local.cortex.pipeline; then
  echo "[OK]      daily launchd job is loaded"
else
  echo "[INFO]    daily launchd job is not loaded (fine if you run manually, or haven't set it up yet)"
fi

echo
echo "Can't be checked automatically - verify by hand:"
echo "  - claude is authenticated: run 'claude' once; if it prompts you to log"
echo "    in, do that, then re-run this script"
echo "  - your dictation tool has Microphone, Accessibility, and Input"
echo "    Monitoring permission (System Settings > Privacy & Security) - a"
echo "    global hotkey can appear to fire with Accessibility/Input Monitoring"
echo "    missing while silently typing nothing"

echo
if [ "$FAIL" -eq 0 ]; then
  echo "All automatic checks passed."
else
  echo "Some checks failed - see [MISSING] lines above."
  exit 1
fi
