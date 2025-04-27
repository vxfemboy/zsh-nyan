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

# random color from the list
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

# git prompt
git_prompt_info() {
    local ref
    if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
        ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
        ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
        echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
    fi
}

# parse git dirty status
parse_git_dirty() {
    local STATUS
    STATUS=$(command git status --porcelain 2> /dev/null | tail -n1)
    if [[ -n $STATUS ]]; then
        echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
    else
        echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
    fi
}

# update color variables
update_colors() {
    RAINBOW_USER_COLOR=$(random_color)
    RAINBOW_HEART_COLOR=$(random_color)
}

# Preexec function to update colors before each command
preexec() {
    update_colors
}

# Precmd function to update colors before each prompt
precmd() {
    update_colors
}

# Set the prompt
PROMPT='%F{$RAINBOW_USER_COLOR}%n%f %F{51}%~%f $(git_prompt_info) %F{$RAINBOW_HEART_COLOR}❤%f '

# Load colors
autoload -U colors && colors

# Git prompt settings
ZSH_THEME_GIT_PROMPT_PREFIX="%F{201}(%f"
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{201})%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{196}✗%f"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{46}✔%f"

# Additional Git status indicators
ZSH_THEME_GIT_PROMPT_ADDED="%F{46}+%f"
ZSH_THEME_GIT_PROMPT_MODIFIED="%F{226}!%f"
ZSH_THEME_GIT_PROMPT_DELETED="%F{196}-%f"

ZSH_THEME_COLORIZE_USERNAME=true
ZSH_THEME_COLORIZE_PATH=true
ZSH_THEME_COLORIZE_GIT_STATUS=true

# Enable prompt substitution
setopt prompt_subst

# Initial color setup
update_colors
