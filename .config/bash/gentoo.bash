alias portage='cd /etc/portage'
alias world='bat --style=plain /var/lib/portage/world'
alias esync='sudo eix-sync'
alias news='eselect news read'
alias dispatch='sudo dispatch-conf'
alias elog='less +G /var/log/emerge.log'
alias edeps='sudo emerge -avc'
alias eobs='sudo eix-test-obsolete'
alias erebuild='sudo emerge -av @preserved-rebuild'
alias eprev='sudo emerge -pvuDN @world'

phelp() {
    cat <<'EOF'
Portage helpers:
  portage      cd /etc/portage
  world        show the @world file
  esync        synchronise repositories and refresh eix
  news         read unread Gentoo news
  dispatch     review CONFIG_PROTECT updates
  elog         view emerge.log from the end
  edeps        preview depclean
  eobs         find obsolete /etc/portage entries
  erebuild     rebuild preserved libraries
  eprev        preview system update
EOF
}

# Interactive fuzzy search for files with preview.
ff() {
    local path=${1:-.}
    local pattern=${2:-.}
    local file

    # Adjust 'clip' to your clipboard manager (e.g., wl-copy, xclip -selection clipboard) if needed
    file=$(
        fd --type f --hidden --follow -- "$pattern" "$path" |
        fzf \
            --preview='bat --style=plain --color=always --line-range=:300 {}' \
            --header='Ctrl-Y: copy selected path' \
            --bind 'ctrl-y:execute-silent(printf %s {} | clip)'
    ) || return

    printf '%s\n' "$file"
}

# Interactively search Portage packages with eix and fzf.
fps() {
    if ! command -v eix >/dev/null 2>&1; then
        echo "eix is not installed." >&2
        return 1
    fi
    local pkg
    pkg=$(eix --compact --pure-packages | fzf --query="${1:-}" --preview='eix -c {}') || return
    [[ -n $pkg ]] && eix "$pkg"
}

function ynobin() {
    (emerge -pv -K --binpkg-respect-use=n --color=y $1 2>&1 | rg --color=never $1) && \
    (emerge -pv                           --color=y $1 2>&1 | rg --color=never $1)
}

pconf() {
    local type=$1
    local file=$2
    local dir target

    case "$type" in
        use)       dir=/etc/portage/package.use ;;
        kw|keywords) dir=/etc/portage/package.accept_keywords ;;
        mask)      dir=/etc/portage/package.mask ;;
        unmask)    dir=/etc/portage/package.unmask ;;
        env)       dir=/etc/portage/package.env ;;
        repos)     dir=/etc/portage/repos.conf ;;
        make)
            medit /etc/portage/make.conf
            return
            ;;
        *)
            printf 'Usage: pconf {use|kw|mask|unmask|env|repos|make} [file]\n' >&2
            return 2
            ;;
    esac

    if [[ -z $file ]]; then
        printf "pconf: '%s' is a directory; specify a file to edit.\n" "$dir" >&2
        printf 'Available files:\n' >&2
        find "$dir" -maxdepth 1 -type f -printf '  %f\n' 2>/dev/null | sort >&2
        return 2
    fi

    target="$dir/$file"

    if [[ ! -f $target ]]; then
        printf "pconf: file not found: %s\n" "$target" >&2
        return 1
    fi

    medit "$target"
}

_pconf_completion() {
    local cur prev dir

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        use)
            dir=/etc/portage/package.use
            ;;
        kw|keywords)
            dir=/etc/portage/package.accept_keywords
            ;;
        mask)
            dir=/etc/portage/package.mask
            ;;
        unmask)
            dir=/etc/portage/package.unmask
            ;;
        env)
            dir=/etc/portage/package.env
            ;;
        repos)
            dir=/etc/portage/repos.conf
            ;;
        *)
            if (( COMP_CWORD == 1 )); then
                COMPREPLY=( $(compgen -W 'use kw keywords mask unmask env repos make' -- "$cur") )
            fi
            return
            ;;
    esac

    if [[ -d $dir ]]; then
        COMPREPLY=(
            $(compgen -W "$(find "$dir" -maxdepth 1 -type f -printf '%f\n' 2>/dev/null)" -- "$cur")
        )
    fi
}

complete -F _pconf_completion pconf

# Read one or more Portage files.
pcat() {
    if command -v bat >/dev/null 2>&1; then
        sudo bat --style=plain --paging=always -- "$@"
    else
        sudo less -- "$@"
    fi
}
