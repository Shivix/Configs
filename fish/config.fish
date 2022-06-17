starship init fish | source
zoxide init --cmd=cd fish | source

fzf_key_bindings
fish_vi_key_bindings
set fish_cursor_insert line
for mode in insert default
bind \cd -M $mode ""
end
bind \cr -M default "redo"
bind U -M visual "togglecase-selection"
bind _ -M default "beginning-of-line"
for mode in insert replace
    bind jk -M $mode -m default ""
end

alias make="make -j12"
alias md="make --no-print-directory -j12 -C cmake-build-debug"
alias mr="make --no-print-directory -j12 -C cmake-build-release"
alias mdc="make --no-print-directory -j12 -C cmake-build-debug-clang"
alias mrc="make --no-print-directory -j12 -C cmake-build-release-clang"

alias ctd="ctest --test-dir cmake-build-debug"
alias ctr="ctest --test-dir cmake-build-release"
alias ctdc="ctest --test-dir cmake-build-debug-clang"
alias ctrc="ctest --test-dir cmake-build-release-clang"

alias rm="rm -i"
alias mv="mv -i"
alias wt="git worktree"
alias tree="tree --gitignore"
alias rg="rg --smart-case --line-number --fixed-strings"
alias ssh="env TERM=xterm-256color ssh"

alias gitlscpp="git ls-files '*.cpp' '*.hpp' '*.cxx' '*.hxx'"
alias gitformat="gitlscpp | xargs clang-format -i"
alias gittidy="gitlscpp | xargs clang-tidy"

alias gamend="git commit --amend"
alias gcommit="git commit"
alias gdiff="git diff"
alias gfetch="git fetch upstream"
alias gpush="git push origin"
alias grebase="git rebase -i upstream/master"
alias gstash="git stash"
alias gstatus="git status"

set -gx scratchfile "$HOME/Documents/Notes/scratch.md"
alias scratch="nvim $scratchfile"

set -gx NVIM_PIPE "$HOME/.cache/nvim/server.pipe"
alias nvimr="nvim --listen $NVIM_PIPE"
alias nvimpipe="nvim --server $NVIM_PIPE --remote"
alias nvimsend="nvim --server $NVIM_PIPE --remote-send"

alias countincludes="gitcppfiles | xargs cat | awk -F '[\"<>]' '/#include/ { arr[\$2]++ } END { for (i in arr) print i, arr[i] }' | sort"

set -gx VISUAL nvim
set -gx EDITOR nvim

set -gx GPG_TTY (tty)

set -gx fish_greeting "Welcome to fish, the friendly interactive shell"
set -gx fish_browser "firefox-developer-edition"

set -gx FZF_DEFAULT_OPTS "--tiebreak=index --bind=ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up"
set -gx FZF_DEFAULT_COMMAND "fd --type f --full-path --strip-cwd-prefix"

set -gx RG_PREFIX "rg --column --no-heading --color=always"

set -gx BAT_THEME "gruvbox-dark"
set -gx MANPAGER "sh -c 'col -b | nvim -c Man!'"

set -gx PYTHONPATH ~/cpp/python
fish_add_path /usr/local/go/bin
fish_add_path ~/go/bin
fish_add_path ~/.local/bin

function rund
    set file (fd -1 --type x --full-path $argv[1] cmake-build-debug)
    $file $argv[2..]
end

function mkcd --wraps mkdir --description "creates directory and cds into it"
    mkdir $argv && cd $argv
end

alias fix2pipe="sed -e 's/\x01/|/g'"

function config_diff
    nvim -d ~/GitHub/configs/$argv ~/.config/$argv
end

function fzk8slogs --wraps "kubectl logs" --description "Fuzzy search kubectl logs"
    kubectl logs $argv | sed -e 's/\x01/|/g' | fzf --delimiter : --preview 'echo {} | cut -f2- -d":" | prefix -v' --preview-window up:50%:wrap --multi
end
alias fzl="fzk8slogs"

function nvimfzf --description "fzf files and open in new nvim instance"
    if test -z "$argv"
        set file (fzf \
        --preview "bat --color=always {1}" \
        --preview-window "up,50%,border-bottom")
    else
        set file (fzf --query $argv)
    end
    if test -z "$file"
        return
    end
    nvim $file
end
alias nvf="nvimfzf"

function nvimrg --description "Grep string and open selection in new nvim instance"
    set old_FZF_DEFAULT_COMMAND $FZF_DEFAULT_COMMAND
    set FZF_DEFAULT_COMMAND $RG_PREFIX
    set match (fzf --disabled --ansi --delimiter : \
        --bind "change:reload:$RG_PREFIX {q} || true" \
        --preview "bat --color=always {1} --highlight-line {2}" \
        --preview-window "up,60%,border-bottom,+{2}" \
        | awk -F ":" '{print $1"\n"$2}')
    set FZF_DEFAULT_COMMAND $old_FZF_DEFAULT_COMMAND
    if test -z "$match"
        return
    end
    set file (fd --absolute-path --type f --full-path $match[1])
    nvim +$match[2] $file
end
alias nvrg="nvimrg"

function update_copyright --description "Increment the copyright year on any modified files"
    set files (git diff --name-only --ignore-submodules)
    if test -z "$files"
        set files (git show $argv --pretty="" --name-only --ignore-submodules)
    end
    for file in $files
        sed -i "0,/2020\|2021\|2022/ s//2022/g" $file
    end
end

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.fish.inc" ]; . "$HOME/google-cloud-sdk/path.fish.inc"; end
