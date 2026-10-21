ulimit -n 10240

set fish_color_command green
set fish_color_cwd blue
set fish_greeting

set -gx BROWSER none
set -gx EDITOR nvim
set -gx FZF_DEFAULT_COMMAND rg
set -gx MANPAGER nvim +Man!
set -gx MANWIDTH 999
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx ZIG_BUILD_ERROR_STYLE minimal_clear

fish_add_path /opt/homebrew/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.radicle/bin
fish_add_path $HOME/.zig
fish_add_path $HOME/Library/pnpm/bin

abbr -a ls eza
abbr -a p posting --collection .
abbr -a ngc nix-collect-garbage -d
abbr -a ssh mosh
abbr -a v nvim
abbr -a x exit

function fish_prompt
    # c_<name> = color
    # v_<name> = value
    set -l c_normal (set_color normal)

    set c_pipes (set_color 767676)
    set -l v_upper_pipe $c_pipes '╭╴ ' $c_normal
    set -l v_lower_pipe $c_pipes '╰╴ ' $c_normal

    # Show the hostname on remote connections (ssh/mosh)
    set -l c_hostname (set_color -o B2B2B2)
    set -l v_hostname
    if test -n "$SSH_CONNECTION"
        set v_hostname $c_hostname '[' (prompt_hostname) '] ' $c_normal
    end

    # Since we display the prompt on a new line allow the directory names to be longer.
    set -q fish_prompt_pwd_dir_length
    or set -lx fish_prompt_pwd_dir_length 0

    set -l c_pwd (set_color 767676)
    set -l v_pwd $c_pwd (prompt_pwd) $c_normal

    # Show the last command's status, if unsuccessful
    set -l last_status $status
    set -l c_status (set_color FF8700)
    set -l v_status
    if test $last_status -ne 0
        set v_status $c_status "[" $last_status "]" $c_normal
    end

    set -l c_caret (set_color FF8700)
    set -l v_caret $c_caret '▷ ' $c_normal

    echo -s $v_upper_pipe $v_hostname $v_pwd ' ' $v_status
    echo -n -s $v_lower_pipe $v_caret
end

if status is-interactive
    if type -q zoxide
        zoxide init fish | source
    end
end
