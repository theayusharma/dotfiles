if status is-interactive
    # Commands to run in interactive sessions can go here
    sys-stats
    starship init fish | source
    zoxide init fish | source
    thefuck --alias | source
    ~/.config/fish/tty.sh &
end

set -l teal 94e2d5
set -l flamingo f2cdcd
set -l mauve cba6f7
set -l pink f5c2e7
set -l red f38ba8
set -l peach fab387
set -l green a6e3a1
set -l yellow f9e2af
set -l blue 89b4fa
# set -l gray 54232d
set -l black 191724

# Completion Pager Colors
set -g fish_pager_color_progress $gray
set -g fish_pager_color_prefix $mauve
set -g fish_pager_color_completion $peach
set -g fish_pager_color_description $gray

# Some config
set -g fish_greeting

# Git config
set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_showupstream informative
set -g __fish_git_prompt_showdirtystate yes
set -g __fish_git_prompt_char_stateseparator ' '
set -g __fish_git_prompt_char_cleanstate '✔'
set -g __fish_git_prompt_char_dirtystate '✚'
set -g __fish_git_prompt_char_invalidstate '✖'
set -g __fish_git_prompt_char_stagedstate '●'
set -g __fish_git_prompt_char_stashstate '⚑'
set -g __fish_git_prompt_char_untrackedfiles '?'
set -g __fish_git_prompt_char_upstream_ahead ''
set -g __fish_git_prompt_char_upstream_behind ''
set -g __fish_git_prompt_char_upstream_diverged ﱟ
set -g __fish_git_prompt_char_upstream_equal ''
set -g __fish_git_prompt_char_upstream_prefix ''''

set -g man_blink -o $teal
set -g man_bold -o $pink
set -g man_standout -b $gray
set -g man_underline -u $blue

# Directory abbreviations
abbr -a -g l ls
abbr -a -g la 'ls -a'
abbr -a -g ll 'ls -l'
abbr -a -g lal 'ls -al'
abbr -a -g d dirs
abbr -a -g h 'cd $HOME'

export LC_CTYPE=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
# Locale

export LANG="en_IN.UTF-8"
export LC_ALL="en_US.UTF-8"
# Exports
export VISUAL="nvim"
export EDITOR="$VISUAL"

# Term
switch "$TERM_EMULATOR"
    case '*kitty*'
        export TERM='xterm-kitty'
    case '*'
        export TERM='xterm-256color'
end

# Make su launch fish
function su
    command su --shell=/usr/bin/fish $argv
end

function wa
    set -f APPID 6HV6YJ-QGK36VKQQJ # Get one at https://products.wolframalpha.com/api/
    echo $argv | string escape --style=url | read question_string
    set -f url "https://api.wolframalpha.com/v1/result?appid="$APPID"&i="$question_string
    curl -s $url
end

function code
    command code $argv
end

function starship_transient_prompt_func
    echo "❯ "
end

function prompt_newline --on-event fish_postexec
    echo
end

alias clear "command clear; commandline -f clear-screen"
# Neofetch with terminal-specific backends
#switch "$TERM_EMULATOR"
#case '*kitty*'
#    neofetch --backend 'kitty'
#case '*tmux*' '*login*' '*sshd*' '*konsole*'
#    neofetch --backend 'ascii' --ascii_distro 'arch_small'
#case '*'
#    neofetch --backend 'w3m' --xoffset 34 --yoffset 34 --gap 0
#end

# alias bat='bat --theme="gruvbox-dark"'
# alias bat= bat --theme="gruvbox dark"

set MOZ_ENABLE_WAYLAND 1
# set XDG_CURRENT_DESKTOP Hyprland

# Created by `pipx` on 2022-09-11 05:02:32
# set PATH $HOME/.local/bin $PATH
# set -Ux PATH /opt/cuda/bin $PATH
# set -Ux PATH $ANDROID_HOME/emulator $ANDROID_HOME/platform-tools

# Android SDK environment variables
# set -Ux ANDROID_SDK /home/catisgoal/Android/Sdk/
# set -Ux ANDROID_HOME /home/catisgoal/Android/Sdk/
# set -Ux ANDROID_SDK_ROOT /home/catisgoal/Android/Sdk/
#
# Adding Android tools to PATH
# set -Ux PATH $ANDROID_HOME/emulator $ANDROID_HOME/platform-tools $PATH

# Default browser setup
# set -Ux BROWSER /usr/bin/thorium-browser
# set -Ux EDGE_PATH /usr/bin/thorium-browser

# Setting PATH with all your custom directories
# set -Ux PATH /opt/cuda/bin:/home/catisgoal/.local/bin:/opt/cuda/bin:/home/catisgoal/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/opt/android-sdk/platform-tools:/opt/cuda/bin:/opt/cuda/nsight_compute:/opt/cuda/nsight_systems/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/usr/lib/rustup/bin:/home/catisgoal/.local/share/nvim/mason/bin:/home/catisgoal/.jiotv_go/bin:$PATH
#
#
# set -Ux JAVA_HOME /usr/lib/jvm/java-17-openjdk
# set -Ux PATH /usr/lib/jvm/java-17-openjdk/bin
# set -gx PATH /opt/cuda/bin:/home/catisgoal/.local/bin:/home/catisgoal/.local/share/nvim/mason/bin:/usr/local/bin:/usr/bin /home/catisgoal/.jiotv_go/bin
# set -gx PATH /opt/cuda/bin:/home/catisgoal/.local/bin:/home/catisgoal/.local/share/nvim/mason/bin:/usr/local/bin:/usr/bin /home/catisgoal/.jiotv_go/bin

# set -Ux REACT_NATIVE_PACKAGER_HOSTNAME 192.168.1.9

#below this was imp sort offf
# set -gx LD_LIBRARY_PATH /opt/cuda/lib64 $LD_LIBRARY_PATH
# fish_add_path /home/catisgoal/.termcast/compiled/tuitube/bin
#
# ---------------------------------------------------------
# ENVIRONMENT VARIABLES
# ---------------------------------------------------------
set -Ux JAVA_HOME /usr/lib/jvm/java-25-openjdk
set -gx LD_LIBRARY_PATH /opt/cuda/lib64 $LD_LIBRARY_PATH
set -gx MOZ_ENABLE_WAYLAND 1
fish_vi_key_bindings
# ---------------------------------------------------------
# PATH CONFIGURATION (The Fix)
# ---------------------------------------------------------

# 1. Reset PATH to safe system defaults first
# This stops the "infinite loop" of duplicates
set -gx PATH /usr/local/sbin /usr/local/bin /usr/bin /usr/bin/site_perl /usr/bin/vendor_perl /usr/bin/core_perl

# 2. Add /sbin (Arch Linux system binaries) - Append to end
fish_add_path -a /sbin

# 3. Add Heavy SDKs - Append to end (keeps path clean)
fish_add_path -a \
    /opt/cuda/bin \
    /opt/cuda/nsight_compute \
    /opt/cuda/nsight_systems/bin \
    /opt/android-sdk/cmdline-tools/latest/bin \
    /opt/android-sdk/platform-tools \
    /opt/android-sdk/emulator \
    /usr/lib/jvm/java-25-openjdk/bin

# 4. Add User Tools - PREPEND (Move to front)
# This ensures your installed 'go', 'nvim', etc. always win over system versions
fish_add_path -m \
    $HOME/go/bin \
    $HOME/.local/bin \
    $HOME/.local/share/nvim/mason/bin \
    $HOME/.jiotv_go/bin \
    $HOME/.bun/bin \
    $HOME/.termcast/compiled/tuitube/bin \
    /usr/lib/rustup/bin
set -gx PATH $HOME/flutter/bin $PATH
set -gx PATH $HOME/flutter/bin $PATH
