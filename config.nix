{ config, pkgs, ... }:

let
  shell-aliases = {
    "l" = "ls -lah --color";
    "nix-gc-roots" = ''
      nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/w+-system|{memory|{censor)"'';
    "ssh-unsafe" = "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
  };
  shell-functions = ./shell-functions;
  zsh-functions = ./zsh-functions;
in
{
  environment.systemPackages = with pkgs; [
    bat
    difftastic
    dtc
    fd
    fzf
    gnumake
    htop
    inetutils
    jq
    libarchive
    lsof
    man-pages
    man-pages-posix
    netcat
    nix-prefetch-git
    nix-prefetch-github
    p7zip
    pciutils
    pkg-config
    pv
    ripgrep
    screen
    socat
    stow
    tcpdump
    tmux
    tmux
    tree
    unrar
    unzip
    vim
    wget
    zip
    zstd
  ];
  programs = {
    screen = {
      enable = true;
      screenrc = ''
        # GNU Screen - main configuration file 

        # Allow bold colors - necessary for some reason
        attrcolor b ".I"

        # Tell screen how to set colors. AB = background, AF=foreground
        termcapinfo xterm 'Co#256:AB=\E[48;5;%dm:AF=\E[38;5;%dm'

        # Enables use of shift-PgUp and shift-PgDn
        termcapinfo xterm|xterms|xs|rxvt ti@:te@

        # Erase background with current bg color
        defbce "on"

        # Enable 256 color term
        term xterm-256color

        # Cache 30000 lines for scroll back
        defscrollback 30000

        hardstatus alwayslastline 
        # Very nice tabbed colored hardstatus line
        hardstatus string '%{= Kd} %{= Kd}%-w%{= Kr}[%{= KW}%n %t%{= Kr}]%{= Kd}%+w %-= %{KG} %H%{KW}|%{KY}%101`%{KW}|%D %M %d %Y%{= Kc} %C%A%{-}'

        # change command character from ctrl-a to ctrl-t (emacs users may want this)
        escape ^Tt

        # Hide hardstatus: ctrl-a f 
        bind f eval "hardstatus ignore"
        # Show hardstatus: ctrl-a F
        bind F eval "hardstatus alwayslastline"
      '';
    };
    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      historyLimit = 8192;
      shortcut = "t";
      plugins = with pkgs.tmuxPlugins; [
        dracula
      ];
      extraConfig = ''
        # split panes with vim bindings
        unbind '"'
        unbind %
        bind v split-window -h
        bind s split-window -v
        
        # reload config
        bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded..."
        
        # pane switching
        bind h select-pane -L
        bind l select-pane -R
        bind k select-pane -U
        bind j select-pane -D
        
        # enable mouse control
        set -g mouse off
        
        # don't rename windows automatically
        set-option -g allow-rename off

        # switch to last pane with C-t, last window with p
        unbind p
        bind p last-window
        bind C-t last-pane

        # joining panes
        bind h choose-window 'join-pane -h -s "%%"'
        bind H choose-window 'join-pane -s "%%"'
      '';
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      interactiveShellInit = ''
        umask 027
        export EDITOR=${pkgs.vim}/bin/vim
        REPORTTIME=60       # Report time statistics for progs that take more than a minute to run
        WATCH=notme         # Report any login/logout of other users
        WATCHFMT='%n %a %l from %m at %T.'

        # enable zsh colors
        autoload -U colors && colors

        # key bindings
        bindkey -e
        # Push a command onto a stack allowing you to run another command first
        bindkey '^J' push-line

        source ${shell-functions}
        source ${zsh-functions}
      '';
      shellAliases = shell-aliases;
      promptInit = ''
        setopt prompt_subst
        autoload -Uz vcs_info
        PROMPT="%{$fg_bold[blue]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg_no_bold[yellow]%}%~ %{$reset_color%}# "
        RPROMPT="%{$fg_bold[red]%}%(?..[%?] )%{$reset_color%}"
        autoload -Uz promptinit
        promptinit
      '';
      histSize = 655360;
      histFile = "$HOME/.zsh_history";
      setOptions = [
        "chase_links"
        "extended_glob"
        "mark_dirs"
        "hist_ignore_dups"
        "share_history"
        "hist_fcntl_lock"
      ];
    };
    bash = {
      enableCompletion = true;
      shellAliases = shell-aliases;
      interactiveShellInit = ''
        source "${pkgs.bash-preexec}/share/bash/bash-preexec.sh"
        source ${shell-functions}
      '';
    };
  };
}
