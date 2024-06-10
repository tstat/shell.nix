{ config, pkgs, ... }:

let
  shell-aliases = {
    "l" = "ls -lah --color";
    "nix-gc-roots" = ''
      nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/w+-system|{memory|{censor)"'';
  };
in
{
  environment.systemPackages = with pkgs; [ ];
  programs = {
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
        bindkey -v
        # Push a command onto a stack allowing you to run another command first
        bindkey '^J' push-line
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
      '';
    };
  };
}
