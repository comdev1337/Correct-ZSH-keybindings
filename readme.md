# Correct ZSH text editing keybindings/shortcuts used in the real world by real (existing) and typically employed (they have a job) people in real-world text editing software (made in the 21st century) instead of the default vi/emacs garbage

## Requirements
* xclip (clip.exe used in WSL)
* [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) plugins:
```
plugins=(
  zsh-autosuggestions
  fzf # and the fzf program itself!
  fzf-tab 
)
```
## Install
```
cd && wget https://raw.githubusercontent.com/comdev1337/Correct-ZSH-keybindings/refs/heads/main/zsh_keyboard.sh && echo "source zsh_keyboard.sh" >> .zshrc && cd -
```

## Shortcuts

| Shortcut | Correct Action | Default Action | Equivalent default shortcut |
|----------|----------------|----------------|----------------------------|
| **Ctrl+Z** | Undo | Suspend (SIGTSTP) | ??? |
| **Home** | Go to beginning of line | beginning-of-line | Ctrl+A |
| **End** | Go to end of line | end-of-line | Ctrl+E |
| **Ctrl+Backspace** | backward-kill-word | Deletes a char | Alt+Backspace |
| **Ctrl+Delete** | Kill word | delete-char | Alt+D |
| **Tab** | Smart Tab (zsh-autosuggestions) | expand-or-complete | Right (zsh-autosuggestions) |
| **Shift+Tab** | Default completion | None | Tab |
| **Ctrl+A** | Select all | beginning-of-line | ??? |
| **Ctrl+X** | Smart cut | None/varies | Ctrl+U + Ctrl+K |
| **Ctrl+C** | Smart copy or interrupt | send-break (interrupt) | ??? |
| **Ctrl+Y** | Redo | yank (paste) | ??? |
| **Left** | Move left (clear selection) | backward-char | Ctrl+B |
| **Right** | Move right (clear selection) | forward-char | Ctrl+F |
| **Up** | Search up (clear selection) | up-line-or-search | Ctrl+P |
| **Down** | Search down (clear selection) | down-line-or-search | Ctrl+N |
| **Ctrl+Left** | Move backward one word | backward-word | Alt+B |
| **Ctrl+Right** | Move forward one word | forward-word | Alt+F |
| **Ctrl+Up** | Jump to previous paragraph | None | ??? |
| **Ctrl+Down** | Jump to next paragraph | None | ??? |
| **Shift+Left** | Select backward one char | None (no selection) | ??? |
| **Shift+Right** | Select forward one char | None (no selection) | ??? |
| **Shift+Up** | Select up one line | None (no selection) | ??? |
| **Shift+Down** | Select down one line | None (no selection) | ??? |
| **Shift+Home** | Select to beginning of line | None (no selection) | ??? |
| **Shift+End** | Select to end of line | None (no selection) | ??? |
| **Ctrl+Shift+Left** | Select backward one word | None (no selection) | ??? |
| **Ctrl+Shift+Right** | Select forward one word | None (no selection) | ??? |
| **Ctrl+Shift+Up** | Select to previous paragraph | None (no selection) | ??? |
| **Ctrl+Shift+Down** | Select to next paragraph | None (no selection) | ??? |
| **Ctrl+Shift+Home** | Select to beginning of buffer | None (no selection) | ??? |
| **Ctrl+Shift+End** | Select to end of buffer | None (no selection) | ??? |
| **Ctrl+Home** | Go to beginning of buffer | beginning-of-line | Ctrl+A |
| **Ctrl+End** | Go to end of buffer | end-of-line | Ctrl+E |
| **Shift+Enter** | Insert newline | None? | Alt+Enter |
| **Alt+Up** | Search backward in history | up-line-or-search | Ctrl+P |
| **Alt+Down** | Search forward in history | down-line-or-search | Ctrl+N |
| **Ctrl+R** | FZF reverse search | history-substring-search | Ctrl+R (standard) |
| **Ctrl+G** | Open visual editor | ??? | ??? |
