# Interactive shells only.
[[ $- == *i* ]] || return

# ─────────────────────────────────────────────
# Environment
# ─────────────────────────────────────────────

export EDITOR=micro
export VISUAL=micro

export LESS='-FRX'
export LESSHISTFILE='-'

# Add ~/.local/bin if it isn't already in PATH.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac


# ─────────────────────────────────────────────
# History
# ─────────────────────────────────────────────

export HISTCONTROL='ignoreboth:erasedups'
export HISTSIZE=50000
export HISTFILESIZE=100000

shopt -s histappend
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# Up/Down search through history using the current command prefix.
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'


# ─────────────────────────────────────────────
# Shell behaviour
# ─────────────────────────────────────────────

shopt -s autocd
shopt -s cdspell
shopt -s dirspell


# ─────────────────────────────────────────────
# Navigation
# ─────────────────────────────────────────────

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'


# ─────────────────────────────────────────────
# Everyday aliases
# ─────────────────────────────────────────────

alias ls='ls --color=auto'
alias ll='ls -alFh --color=auto'
alias la='ls -A --color=auto'

alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias rg='rg --smart-case'

alias df='df -hT'
alias rm='rm -I'

# Allow aliases to expand after sudo.
alias sudo='sudo '


# ─────────────────────────────────────────────
# Useful helpers
# ─────────────────────────────────────────────

mkcd() {
    if [[ -z ${1:-} ]]; then
        echo "Usage: mkcd <directory>" >&2
        return 1
    fi

    mkdir -p -- "$1" && cd -- "$1"
}

path() {
    tr ':' '\n' <<< "$PATH"
}

batman() {
    if (( $# == 0 )); then
        echo "Usage: batman <command>" >&2
        return 1
    fi

    man "$1" | col -b | bat --language=man --style=plain
}

extract() {
    if [[ -z ${1:-} ]]; then
        echo "Usage: extract <archive_file>" >&2
        return 1
    fi

    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2|*.tbz2) tar xjf "$1" ;;
            *.tar.gz|*.tgz)   tar xzf "$1" ;;
            *.tar.xz|*.txz)   tar xJf "$1" ;;
            *.tar.zst)        tar --zstd -xf "$1" ;;
            *.bz2)            bunzip2 "$1" ;;
            *.rar)            unrar x "$1" ;;
            *.gz)             gunzip "$1" ;;
            *.tar)            tar xvf "$1" ;;
            *.zip)            unzip "$1" ;;
            *.Z)              uncompress "$1" ;;
            *.7z)              7z x "$1" ;;
            *.xz)              unxz "$1" ;;
            *.zst)             unzstd "$1" ;;
            *) echo "'$1' cannot be extracted via extract()" >&2; return 1 ;;
        esac
    else
        echo "'$1' is not a valid file" >&2
        return 1
    fi
}


# ─────────────────────────────────────────────
# Optional CLI integrations
# ─────────────────────────────────────────────

if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash)"
fi

# Load distro-specific configuration.
if [[ -r /etc/os-release ]]; then
    . /etc/os-release

    case "$ID" in
        nixos)
            source "$HOME/.config/bash/nixos.bash"
            ;;
        gentoo)
            source "$HOME/.config/bash/gentoo.bash"
            ;;
    esac
fi

fastfetch