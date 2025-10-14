#!/usr/bin/env bash

set -euo pipefail

# Ensure we have the necessary environment variables when launched from Hyprland
if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
  # Try to find the correct Wayland display
  for display in wayland-1 wayland-0; do
    if [[ -S "/run/user/$UID/$display" ]]; then
      export WAYLAND_DISPLAY="$display"
      break
    fi
  done
fi

# Ensure we have the correct PATH for wl-paste, wl-copy, wtype, etc.
if [[ -z "${PATH:-}" ]]; then
  export PATH="/usr/local/bin:/usr/bin:/bin"
fi


ASK_EXT=false
REMOVE_TMP=false
KEYSTROKE_MODE=false
COPY_SELECTED=false

FONT_SIZE=25
TERM_CLASS="nvim-wl-anywhere"
TERM="kitty"
TERM_OPTS="--class $TERM_CLASS"
TMPFILE_DIR="/tmp/nvim-wl-anywhere"

check_deps() {
  local deps=("nvim" $TERM "wofi" "wtype")

  if ! $KEYSTROKE_MODE || $COPY_SELECTED; then
    deps+=("wl-paste")
  fi

  for cmd in "${deps[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "Error: '$cmd' is required but not installed."
      exit 1
    fi
  done
}

kill_existing_instance() {
  local FOUND=false
  while read -r pid cmd; do
    if [[ "$cmd" == "$TERM"* ]]; then
      kill -9 "$pid"
      FOUND=true
    fi
  done < <(pgrep -af "$TERM_CLASS")

  if $FOUND; then
    echo "An existing instance was found and terminated."
    exit 1
  fi
}

create_tmpfile() {
  mkdir -p "$TMPFILE_DIR"
  local filename="doc-$(date +"%y%m%d%H%M%S")"
  if $ASK_EXT && [[ -n "${EXT:-}" ]]; then
    filename="$filename.$EXT"
  fi
  TMPFILE="$TMPFILE_DIR/$filename"
  touch "$TMPFILE"
  chmod og-rwx "$TMPFILE"
}

show_help() {
  echo "nvim-wl-anywhere <OPTIONS>"
  echo ""
  echo ""
  echo "--ask-ext"
  echo "  Prompt for a file extension when creating the temporary buffer. Useful if you want syntax highlighting in Neovim (.py, .rs, .md, etc.). "
  echo ""
  echo "--rm-tmp"
  echo "  Automatically delete the temporary file after use instead of leaving it in /tmp/nvim-hypr-anywhere. "
  echo ""
  echo "--copy-selected"
  echo "  Copy the currently selected text with Ctrl + C and start editing it"
  echo ""
  echo "--keystroke-mode"
  echo "  Switches from clipboard-paste to **direct keystroke mode** using wtype."
  echo "  - Useful in cases where pasting is blocked, unreliable, or when working inside apps that don’t accept clipboard input. (e.g: a Terminal; because they take a CTRL+SHIFT+V) "
  echo "  - Limitation: "
  echo "    - Line breaks are not yet handled perfectly (Shift+Enter support is TODO)."
  echo "    - Slower, since it needs to send keystrokes "

  echo "--font-size <size>"
  echo "  Set the terminal font size (default: 25)"

  echo "--term <terminal>"
  echo "  Choose which terminal emulator to launch Neovim in (default: alacritty). "

  echo "--term-opts <opts>"
  echo "  override terminal options (e.g. window size, class, etc.)."
  echo ""
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --ask-ext)
      ASK_EXT=true
      shift
      ;;

    --rm-tmp)
      REMOVE_TMP=true
      shift
      ;;

    --keystroke-mode)
      KEYSTROKE_MODE=true
      shift
      ;;

    --copy-selected)
      COPY_SELECTED=true
      shift
      ;;

    --font-size)
      if [[ $# -ge 2 && $2 != --* ]]; then
        FONT_SIZE="$2"
        shift 2
      else
        echo "Error: --font-size requires a value."
        exit 1
      fi
      ;;

    --term)
      if [[ $# -ge 2 && $2 != --* ]]; then
        TERM="$2"
        shift 2
      else
        echo "Error: --term requires a value."
        exit 1
      fi
      ;;

    --term-opts)
      TERM_OPTS=""
      shift
      while [[ $# -gt 0 && $1 != --* ]]; do
        TERM_OPTS="$TERM_OPTS $1"
        shift
      done
      ;;

    --help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      show_help
      exit 1
      ;;
    esac
  done
}

kill_existing_instance
parse_args "$@"
check_deps

# Ask for file extension if requested
if $ASK_EXT; then
  EXT=$(wofi --dmenu --lines 1 --prompt "File extension:")
fi

create_tmpfile

if $COPY_SELECTED; then
  # get the currently selected and edit it if it's different from the last copy
  #
  # so it won't paste the last one if the selected is empty
  LAST_CLIPBOARD=$(wl-paste || true)

  # Use wl-copy with primary selection to get selected text
  # This approach gets the primary selection (selected text) directly
  SELECTED_TEXT=$(wl-paste --primary || true)
  
  if [[ -n "$SELECTED_TEXT" ]]; then
    echo "$SELECTED_TEXT" >"$TMPFILE"
  else
    # If no text was selected, fall back to using current clipboard content
    if [[ -n "$LAST_CLIPBOARD" ]]; then
      echo "$LAST_CLIPBOARD" >"$TMPFILE"
    fi
  fi

  # put the last one back incase you copied something you want to paste
  echo "$LAST_CLIPBOARD" | wl-copy
else
  # Read from clipboard by default
  CLIPBOARD_CONTENT=$(wl-paste || true)
  if [[ -n "$CLIPBOARD_CONTENT" ]]; then
    echo "$CLIPBOARD_CONTENT" >"$TMPFILE"
  fi
fi

# Launch Neovim in insert mode, auto-quit on write
$TERM $TERM_OPTS nvim +startinsert +'autocmd BufWritePost <buffer> quit' "$TMPFILE"

TEXT=$(<"$TMPFILE")

# Paste the text if not empty
if [ -n "$TEXT" ]; then

  if $KEYSTROKE_MODE; then
    # FIXME: Do shift + return if a new line is detected to avoid new line as an enter. Was not able to do so
    printf '%s' "$TEXT" | wtype -

  else
    # Copy to clipboard
    cat "$TMPFILE" | wl-copy
    
    # Small delay to ensure clipboard is ready
    sleep 0.1
    
    # Try Ctrl+Shift+V first (common in many apps)
    # If that doesn't work, the user can manually paste with Ctrl+V
    wtype -M ctrl -k v -m ctrl
  fi

else
  echo "No text to paste (empty file)"
  exit 1
fi

if $REMOVE_TMP; then
  rm -rf "$TMPFILE"
fi
