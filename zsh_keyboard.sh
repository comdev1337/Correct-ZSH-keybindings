# Correct ZSH text editing shortcuts

# --- KEY BINDINGS ---

# Basic Key Fixes
bindkey '^Z'      undo                 # Ctrl+Z, no use case for suspend's ever been found
bindkey '\eOH'    beginning-of-line    # Home (App)
bindkey '\eOF'    end-of-line          # End (App)
bindkey '^H'      backward-kill-word   # Backspace / Ctrl+H
bindkey '\e[3;5~' kill-word            # Delete
bindkey '^[[H'    beginning-of-line    # Home
bindkey '^[[F'    end-of-line          # End

# Tab Remapping
bindkey '^I'      smart-tab              # Tab = Smart (Accept or Complete)
bindkey '^[[Z'    fzf-tab-complete       # Shift+Tab = Force Completion (Backup)

# Standard
bindkey '^A'      select-all             # Ctrl+A
bindkey '^X'      smart-cut              # Ctrl+X
bindkey '^C'      smart-ctrl-c           # Ctrl+C
bindkey '^Z'      undo                   # Ctrl+Z
bindkey '^Y'      redo                   # Ctrl+Y
bindkey '^?'      smart-backspace        # Backspace
bindkey '^[[3~'   smart-delete           # Delete

# Smart Navigation (Clears selection)
bindkey '^[[D'    smart-backward-char    # Left
bindkey '^[[C'    smart-forward-char     # Right
bindkey '\eOD'    smart-backward-char    # Left App
bindkey '\eOC'    smart-forward-char     # Right App
bindkey '^[[H'    smart-home             # Home
bindkey '^[[F'    smart-end              # End
bindkey '\eOH'    smart-home             # Home App
bindkey '\eOF'    smart-end              # End App

# Up/Down (Smart = Clear selection)
bindkey '^[[A'    smart-up-line-or-search   # Up
bindkey '^[[B'    smart-down-line-or-search # Down
bindkey '\eOA'    smart-up-line-or-search   # Up App
bindkey '\eOB'    smart-down-line-or-search # Down App

# Ctrl + Arrow
bindkey '^[[1;5D' smart-backward-word      # Ctrl+Left
bindkey '^[[1;5C' smart-forward-word       # Ctrl+Right
bindkey '^[[1;5A' jump-paragraph-backward  # Ctrl+Up
bindkey '^[[1;5B' jump-paragraph-forward   # Ctrl+Down

# Shift + Arrow (Selection)
bindkey '^[[1;2D' select-backward-char     # Shift+Left
bindkey '^[[1;2C' select-forward-char      # Shift+Right
bindkey '^[[1;2A' select-up-line           # Shift+Up
bindkey '^[[1;2B' select-down-line         # Shift+Down
bindkey '^[[1;2H' select-to-line-begin     # Shift+Home
bindkey '^[[1;2F' select-to-line-end       # Shift+End

# Ctrl + Shift + Arrow (Selection)
bindkey '^[[1;6D' select-backward-word      # Ctrl+Shift+Left
bindkey '^[[1;6C' select-forward-word       # Ctrl+Shift+Right
bindkey '^[[1;6A' select-paragraph-backward # Ctrl+Shift+Up
bindkey '^[[1;6B' select-paragraph-forward  # Ctrl+Shift+Down
bindkey '^[[1;6H' select-to-home            # Ctrl+Shift+Home
bindkey '^[[1;6F' select-to-end             # Ctrl+Shift+End

# Ctrl + Home/End (Buffer Jump)
bindkey '^[[1;5H' smart-goto-begin          # Ctrl+Home
bindkey '^[[1;5F' smart-goto-end            # Ctrl+End

# Misc
bindkey '^[[13;2u' insert-newline           # Shift+Enter
bindkey '^[[1;3A'  history-search-backward  # Alt+Up
bindkey '^[[1;3B'  history-search-forward   # Alt+Down

if zle -l | grep -q "fzf-history-widget"; then
  bindkey '^R' fzf-history-widget         # Ctrl+R (reverse search)
fi

# --- VISUAL EDITOR (Ctrl+G) ---
autoload -z edit-command-line
zle -N edit-command-line
bindkey '^G' edit-command-line           # Ctrl+G

# Clipboard command — WSL uses clip.exe, native Linux uses xclip
if [[ -n "$WSL_DISTRO_NAME" ]]; then
  CLIPBOARD_CMD="clip.exe"
else
  CLIPBOARD_CMD="xclip -selection clipboard"
fi

# Fix right arrow garbage
# WHY THE FUCK WOULD YOU DEFAULT AUTOCOMPLETE ON THE RIGHT ARROW???
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=("${(@)ZSH_AUTOSUGGEST_ACCEPT_WIDGETS:#forward-char}")

# --- TTY SIGNAL FIX ---
function _disable_ctrl_c_signal {
    [[ -t 0 ]] && stty intr undef < /dev/tty 2>/dev/null
}
function _enable_ctrl_c_signal {
    [[ -t 0 ]] && stty intr ^C < /dev/tty 2>/dev/null
}
add-zsh-hook precmd _disable_ctrl_c_signal
add-zsh-hook preexec _enable_ctrl_c_signal

# --- CUSTOM WIDGETS ---

# --- SMART INSERT WRAPPER ---
# This overrides the default typing behavior for ALL keys (ASCII & Unicode) (actually not)
function smart-insert {
  # If text is selected, kill it first
  if (( REGION_ACTIVE )) && (( MARK != CURSOR )); then
    zle kill-region
    REGION_ACTIVE=0
  fi

  # Then insert the typed character
  zle .self-insert
}
# Overlay the built-in self-insert widget with our custom one
zle -N self-insert smart-insert

# 1. Smart Copy/Interrupt
function smart-ctrl-c {
  if (( REGION_ACTIVE )) && (( MARK != CURSOR )); then
    zle copy-region-as-kill
    print -rn -- $CUTBUFFER | $CLIPBOARD_CMD
    # zle -M "Copied"
  else
    zle send-break
  fi
}
zle -N smart-ctrl-c

# 2. Smart Cut
function smart-cut {
  if (( REGION_ACTIVE )) && (( MARK != CURSOR )); then
    # If text is selected, cut the selection
    zle kill-region
    print -rn -- $CUTBUFFER | $CLIPBOARD_CMD
    # zle -M "Cut Selection"
    REGION_ACTIVE=0
  else
    # If nothing is selected, cut the whole line
    zle kill-whole-line
    print -rn -- $CUTBUFFER | $CLIPBOARD_CMD
    # zle -M "Cut Line"
  fi
}
zle -N smart-cut

# --- BRACKETED PASTE WRAPPER ---
# Handles the native Windows Terminal paste (Ctrl+V, Right Click)
function smart-bracketed-paste {
  # 1. If text is selected, kill it first
  if (( REGION_ACTIVE )) && (( MARK != CURSOR )); then
    zle kill-region
    REGION_ACTIVE=0
  fi

  # 2. Trigger the native paste mechanism
  zle .bracketed-paste
}

# Replace the default paste widget with our smart wrapper
zle -N bracketed-paste smart-bracketed-paste

# 4. Select All
function select-all {
  MARK=0
  CURSOR=$#BUFFER
  REGION_ACTIVE=1
}
zle -N select-all

# 5. Smart Delete/Backspace
function smart-delete {
  if (( REGION_ACTIVE )) && (( MARK != CURSOR )); then
    zle kill-region
    REGION_ACTIVE=0
  else
    zle delete-char
  fi
}
zle -N smart-delete

function smart-backspace {
  if (( REGION_ACTIVE )) && (( MARK != CURSOR )); then
    zle kill-region
    REGION_ACTIVE=0
  else
    zle backward-delete-char
  fi
}
zle -N smart-backspace

# 6. Manual Shift+Arrow Selection
function select-backward-char {
  if (( ! REGION_ACTIVE )); then MARK=$CURSOR; REGION_ACTIVE=1; fi
  zle backward-char
}
zle -N select-backward-char

function select-forward-char {
  if (( ! REGION_ACTIVE )); then MARK=$CURSOR; REGION_ACTIVE=1; fi
  zle forward-char
}
zle -N select-forward-char

# 7. Shift+Home/End (Line based)
function select-to-line-begin {
  if (( ! REGION_ACTIVE )); then MARK=$CURSOR; REGION_ACTIVE=1; fi
  zle beginning-of-line
}
zle -N select-to-line-begin

function select-to-line-end {
  if (( ! REGION_ACTIVE )); then MARK=$CURSOR; REGION_ACTIVE=1; fi
  zle end-of-line
}
zle -N select-to-line-end

# 8. Shift+Up/Down (Robust Last Line Logic)
function select-up-line {
  if (( ! REGION_ACTIVE )); then MARK=$CURSOR; REGION_ACTIVE=1; fi
  local old_cursor=$CURSOR
  zle up-line-or-search
  # If cursor didn't move (at top), select to absolute begin
  if [[ $CURSOR -eq $old_cursor ]]; then
      zle beginning-of-line
  fi
}
zle -N select-up-line

function select-down-line {
  if (( ! REGION_ACTIVE )); then MARK=$CURSOR; REGION_ACTIVE=1; fi
  local old_cursor=$CURSOR
  zle down-line-or-search
  # If cursor didn't move (at bottom), select to absolute end
  if [[ $CURSOR -eq $old_cursor ]]; then
      zle end-of-line
  fi
}
zle -N select-down-line

# 9. Smart Navigation (Clear selection on move)
function smart-backward-char { REGION_ACTIVE=0; zle backward-char; }
zle -N smart-backward-char
function smart-forward-char { REGION_ACTIVE=0; zle forward-char; }
zle -N smart-forward-char
function smart-backward-word { REGION_ACTIVE=0; zle backward-word; }
zle -N smart-backward-word
function smart-forward-word { REGION_ACTIVE=0; zle forward-word; }
zle -N smart-forward-word
function smart-home { REGION_ACTIVE=0; zle beginning-of-line; }
zle -N smart-home
function smart-end { REGION_ACTIVE=0; zle end-of-line; }
zle -N smart-end
function smart-up-line-or-search { REGION_ACTIVE=0; zle up-line-or-search; }
zle -N smart-up-line-or-search
function smart-down-line-or-search { REGION_ACTIVE=0; zle down-line-or-search; }
zle -N smart-down-line-or-search

# 10. Ctrl+Shift+Home/End (Buffer based)
function select-to-home {
  if (( ! REGION_ACTIVE )); then MARK=$CURSOR; REGION_ACTIVE=1; fi
  CURSOR=0
}
zle -N select-to-home

function select-to-end {
  if (( ! REGION_ACTIVE )); then MARK=$CURSOR; REGION_ACTIVE=1; fi
  CURSOR=$#BUFFER
}
zle -N select-to-end

# 11. Word Selection (Ctrl+Shift+Left/Right)
function select-backward-word {
  if (( ! REGION_ACTIVE )); then MARK=$CURSOR; REGION_ACTIVE=1; fi
  zle backward-word
}
zle -N select-backward-word

function select-forward-word {
  if (( ! REGION_ACTIVE )); then MARK=$CURSOR; REGION_ACTIVE=1; fi
  zle forward-word
}
zle -N select-forward-word

# 12. Buffer Navigation (Ctrl+Home/End) - Clears Selection
function smart-goto-begin { REGION_ACTIVE=0; CURSOR=0; }
zle -N smart-goto-begin
function smart-goto-end { REGION_ACTIVE=0; CURSOR=$#BUFFER; }
zle -N smart-goto-end

# 13. Paragraph Navigation (Ctrl+Up/Down) - Simulated
function jump-paragraph-backward {
  REGION_ACTIVE=0
  zle vi-backward-blank-word
}
zle -N jump-paragraph-backward

function jump-paragraph-forward {
  REGION_ACTIVE=0
  zle vi-forward-blank-word
}
zle -N jump-paragraph-forward

# 14. Paragraph Selection (Ctrl+Shift+Up/Down)
function select-paragraph-backward {
  if (( ! REGION_ACTIVE )); then MARK=$CURSOR; REGION_ACTIVE=1; fi
  zle vi-backward-blank-word
}
zle -N select-paragraph-backward

function select-paragraph-forward {
  if (( ! REGION_ACTIVE )); then MARK=$CURSOR; REGION_ACTIVE=1; fi
  zle vi-forward-blank-word
}
zle -N select-paragraph-forward

# 15. Shift+Enter
function insert-newline { LBUFFER+=$'\n'; }
zle -N insert-newline

# Smart Tab: Accept suggestion if visible, otherwise trigger completion
function smart-tab {
  # Check if autosuggestion is available
  if [[ -n "$POSTDISPLAY" ]]; then
    zle autosuggest-accept
  else
    # STRICT MODE: Explicitly clear the ghost text before fzf launches.
    # This prevents the "ghost" from merging with the completion menu.
    zle autosuggest-clear
    zle fzf-tab-complete
  fi
}
zle -N smart-tab
# Keep ignoring it so it doesn't auto-clear on entry,
# but we manually clear it on exit in the 'else' block.
ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(smart-tab)
