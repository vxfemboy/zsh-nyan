#!/usr/bin/env zsh

#⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣀⣀⠀⠀⠀⠀⠀
#⠀⠀⠀⠀⠀⠀⣾⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⢀⠀⠈⡇⠀⠀⠀⠀
#⠀⠀⠀⠀⠀⠀⣿⠀⠁⠀⠘⠁⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠈⠀⠀⡇⠀⠀⠀⠀
#⣀⣀⣀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠄⠀⠀⠸⢰⡏⠉⠳⣄⠰⠀⠀⢰⣷⠶⠛⣧⠀
#⢻⡀⠈⠙⠲⡄⣿⠀⠀⠀⠀⠀⠀⠀⠠⠀⢸⠀⠀⠀⠈⠓⠒⠒⠛⠁⠀⠀⣿⠀
#⠀⠻⣄⠀⠀⠙⣿⠀⠀⠀⠈⠁⠀⢠⠄⣰⠟⠀⢀⡔⢠⠀⠀⠀⠀⣠⠠⡄⠘⢧
#⠀⠀⠈⠛⢦⣀⣿⠀⠀⢠⡆⠀⠀⠈⠀⣯⠀⠀⠈⠛⠛⠀⠠⢦⠄⠙⠛⠃⠀⢸
#⠀⠀⠀⠀⠀⠉⣿⠀⠀⠀⢠⠀⠀⢠⠀⠹⣆⠀⠀⠀⠢⢤⠠⠞⠤⡠⠄⠀⢀⡾
#⠀⠀⠀⠀⠀⢀⡿⠦⢤⣤⣤⣤⣤⣤⣤⣤⡼⣷⠶⠤⢤⣤⣤⡤⢤⡤⠶⠖⠋⠀
#⠀⠀⠀⠀⠀⠸⣤⡴⠋⠸⣇⣠⠼⠁⠀⠀⠀⠹⣄⣠⠞⠀⢾⡀⣠⠃⠀⠀⠀⠀
#⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠁⠀⠀⠀⠀⠀

# rainbow colors
rainbow_colors=(196 202 208 214 220 226 190 154 118 82 46 47 48 49 50 51 45 39 33 27 21 57 93 129 165 201)

# command tracking
typeset -i _failed_count=0
typeset -g _last_command
typeset -A _command_history
typeset -g _prompt_color
typeset -g _needs_newline=0
typeset -g _message_color

# get a random color from the list
random_color() {
    local array_size=${#rainbow_colors[@]}
    if [[ $array_size -eq 0 ]]; then
        echo "201"
        return
    fi
    local index=$(( $(od -An -N4 -t u4 /dev/urandom | tr -d ' ') % array_size ))
    local color="${rainbow_colors[$index]}"
    if [[ -z "$color" ]]; then
        echo "201"
    else
        echo "$color"
    fi
}

# update prompt color
update_prompt_color() {
    _prompt_color=$(random_color)
}

# print mommy's message right above the prompt
print_mommy_message() {
    local message="$1"
    local color="$2"

    if [[ $_needs_newline -eq 1 ]]; then
        echo
        _needs_newline=0
    fi

    echo -en "\033[38;5;${color}m❤\033[0m"
    local padding=$((COLUMNS - ${#message} - 1))
    printf "%${padding}s" ""
    echo -en "\033[38;5;${color}m${message}\033[0m"
    echo
}

# update colors and track command
preexec() {
    # current color for mommy's message if it's a real command
    if [[ -n "$1" ]]; then
        _message_color=$_prompt_color
        _last_command="$1"
        _needs_newline=1
    fi
}

# handle command completion
precmd() {
    local exit_status=$?
    local should_mommy=0
    local is_new_command=0
    local mommy_output=""

    update_prompt_color

    # process if we have a last command
    if [[ -n "$_last_command" ]]; then
        if [[ -z "${_command_history[$_last_command]}" ]]; then
            is_new_command=1
            _command_history[$_last_command]=1
        fi

        # show mommy's message
        if [[ $exit_status -ne 0 ]]; then
            ((_failed_count++))
            should_mommy=1
        else
            if [[ $_failed_count -gt 0 || $is_new_command -eq 1 ]]; then
                # higher chance of compliment after failures or for new commands
                local rand=$((RANDOM % 100))
                if [[ $rand -lt 80 ]]; then
                    should_mommy=1
                fi
            else
                # lower chance of compliment for regular successful commands
                local rand=$((RANDOM % 100))
                if [[ $rand -lt 20 ]]; then
                    should_mommy=1
                fi
            fi
            _failed_count=0
        fi

        # show mommy's message if needed
        if [[ $should_mommy -eq 1 ]]; then
            export MOMMY_HEART_COLOR="$_message_color"
            mommy_output=$(mommy -1 -s $exit_status)
            unset MOMMY_HEART_COLOR
            if [[ -n "$mommy_output" ]]; then
                print_mommy_message "$mommy_output" "$_message_color"
            fi
        fi

        # clear last command to prevent repeats on empty returns
        _last_command=""
    fi
}

# git prompt info
git_prompt_info() {
    local ref
    if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
        ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
        ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
        echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
    fi
}

parse_git_dirty() {
    local STATUS
    STATUS=$(command git status --porcelain 2> /dev/null | tail -n1)
    if [[ -n $STATUS ]]; then
        echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
    else
        echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
    fi
}

# set the prompt
PROMPT='%F{$_prompt_color}%n%f %F{51}%~%f $(git_prompt_info) %F{$_prompt_color}❤%f '

# load colors
autoload -U colors && colors

# git prompt settings
ZSH_THEME_GIT_PROMPT_PREFIX="%F{201}(%f"
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{201})%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{196}✗%f"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{46}✔%f"

# Enable prompt substitution
setopt prompt_subst

# Initial color setup
update_prompt_color
