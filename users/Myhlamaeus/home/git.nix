{ config, pkgs, lib, ... }:

with lib;
let cfg = config.programs.git;

in {
  options = {
    programs.git.custom = {
      ignoreFiles = mkOption { type = with lib.types; listOf path; };

      ignoreTemplates = mkOption { type = with lib.types; listOf str; };
    };
  };

  config = {
    home.packages = (with pkgs; [ git git-lfs git-bug ])
      ++ (with pkgs.gitAndTools; [
        git-absorb
        git-appraise
        git-codeowners
        git-ignore
        git-open
        git-recent
        lab
      ]);

    programs.git = {
      enable = true;

      lfs.enable = true;

      profiles = rec {
        private = {
          name = "Maurice B. Lewis";
          email = "dreyer.maltem+dev@gmail.com";
          signingKey = "4BBC645F979A88FA!";
          dirs = [ "~" "/etc/nixos" ];
        };
      };
      defaultProfile = "private";

      custom = {
        ignoreFiles = map (n: "${pkgs.gitignore}/templates/${n}.gitignore")
          cfg.custom.ignoreTemplates;

        ignoreTemplates = [
          "Archive"
          "Archives"
          "Backup"
          "direnv"
          "dotenv"
          "Emacs"
          "Linux"
          "Vim"
          "Zsh"
        ];
      };

      ignores = map builtins.readFile cfg.custom.ignoreFiles ++ [
        # nix
        "result"
        ".direnv"
        # Linux
        "nohup.out"
      ];

      attributes = [
        # Automatically normalize line endings for all text-based files
        "* text=auto"
      ];

      extraConfig = {
        apply = {
          # Detect whitespace errors when applying a patch
          whitespace = "fix";
        };

        core = {
          # Treat spaces before tabs and all kinds of trailing whitespace as an error
          # [default] trailing-space: looks for spaces at the end of a line
          # [default] space-before-tab: looks for spaces before tabs at the beginning of a line
          whitespace = "space-before-tab,-indent-with-non-tab,trailing-space";

          # Speed up commands involving untracked files such as `git status`.
          # https://git-scm.com/docs/git-update-index#_untracked_cache
          untrackedCache = true;

          editor = "${pkgs.neovim}/bin/nvim";
        };

        color = {
          # Use colors in Git commands that are capable of colored output when
          # outputting to the terminal. (This is the default setting in Git ≥ 1.8.4.)
          ui = "auto";
        };

        "color \"branch\"" = {
          current = "green";
          local = "white";
          remote = "red";
        };

        "color \"diff\"" = {
          meta = "yellow bold";
          frag = "magenta bold"; # line info
          old = "red"; # deletions
          new = "green"; # additions
        };

        "color \"status\"" = {
          added = "green";
          changed = "red";
          untracked = "magenta";
        };

        diff = {
          # Detect copies as well as renames
          renames = "copies";
        };

        help = {
          # Automatically correct and execute mistyped commands
          autocorrect = 1;
        };

        init = { defaultBranch = "main"; };

        log = { date = "format:%c"; };

        merge = {
          # Include summaries of merged commits in newly created merge commit messages
          log = true;
        };

        "merge \"npm-merge-driver\"" = {
          name = "automatically merge npm lockfiles";
          driver = "${pkgs.nodejs}/bin/npx npm-merge-driver merge %A %O %B %P";
        };

        pull = { rebase = true; };

        push = {
          # https://git-scm.com/docs/git-config#git-config-pushdefault
          default = "simple";
          # Make `git push` push relevant annotated tags when pushing branches out.
          followTags = true;
        };

        rebase = {
          autoSquash = true;
          autoStash = true;
          missingCommitsCheck = "warn";
          abbreviateCommands = true;
        };

        # URL shorthands
        "url \"git@github.com:\"" = { insteadOf = "gh:"; };

        "url \"git://github.com/\"" = { insteadOf = "github:"; };

        "url \"git@gist.github.com:\"" = { insteadOf = "gst:"; };

        "url \"git://gist.github.com/\"" = { insteadOf = "gist:"; };

        credential = {
          helper = "${pkgs.gitAndTools.pass-git-helper}/bin/pass-git-helper";
          useHttpPath = true;
        };

        github.user = "Myhlamaeus";
        gitlab.user = "Myhlamaeus";
      };

      aliases = {
        ap = "!git push -u origin $(git symbolic-ref --short HEAD)";
        br = "branch";
        ci = "commit";
        co = "checkout";
        cp = "cherry-pick";
        df = "diff --patch-with-stat";
        fu = "commit --fixup";
        fuh = "commit --fixup HEAD";
        pu = "push";
        puf = "push --force-with-lease";
        "rec" = "rebase --continue";
        ri = "rebase -i";
        upd = "fetch origin master:master develop:develop";
        uu = "diff --name-only --diff-filter=U";
        # View abbreviated SHA, description, and history graph of the latest 20 commits
        l = "log --pretty=oneline -n 20 --graph --abbrev-commit";
        # View the current working tree status using the short format
        s = "status -s";
        # Show the diff between the latest commit and the current state
        d =
          "!git diff-index --quiet HEAD -- || clear; git diff --patch-with-stat";
        # `git di $number` shows the diff between the state `$number` revisions ago and the current state
        di =
          "!d() { git diff --patch-with-stat HEAD~$1; }; git diff-index --quiet HEAD -- || clear; d";
        # Pull in remote changes for the current repository and all its submodules
        p = "!git pull; git submodule foreach git pull";
        pras = "!git pull; git submodule foreach git pull";
        # Commit all changes
        ca = "!git add -A && git commit -av";
        # Switch to a branch, creating it if necessary
        go = ''
          !f() { git checkout -b "$1" 2> /dev/null || git checkout "$1"; }; f'';
        # List aliases
        aliases = "config --get-regexp alias";
        # Amend the currently staged files to the latest commit
        amd = "commit --amend --reuse-message=HEAD";
        # Find branches containing commit
        fb = "!f() { git branch -a --contains $1; }; f";
        # Find tags containing commit
        ft = "!f() { git describe --always --contains $1; }; f";
        # Find commits by source code
        fc =
          "!f() { git log --pretty=format:'%C(yellow)%h  %Cblue%ad  %Creset%s%Cgreen  [%cn] %Cred%d' --decorate --date=short -S$1; }; f";
        # Find commits by commit message
        fm =
          "!f() { git log --pretty=format:'%C(yellow)%h  %Cblue%ad  %Creset%s%Cgreen  [%cn] %Cred%d' --decorate --date=short --grep=$1; }; f";
        # List contributors with number of commits
        contributors = "shortlog --summary --numbered;";
        # Merge GitHub pull request on top of the current branch or,
        # if a branch name is specified, on top of the specified branch
        mpr = ''
          "!f() { \
            declare currentBranch=\"$(git symbolic-ref --short HEAD)\"; \
            declare branch=\"''${2:-$currentBranch}\"; \
            if [ $(printf \"%s\" \"$1\" | grep '^[0-9]\\+$' > /dev/null; printf $?) -eq 0 ]; then \
              git fetch origin refs/pull/$1/head:pr/$1 && \
              git checkout -B $branch && \
              git rebase $branch pr/$1 && \
              git checkout -B $branch && \
              git merge pr/$1 && \
              git branch -D pr/$1 && \
              git commit --amend -m \"$(git log -1 --pretty=%B)\n\nCloses #$1.\"; \
            fi \
                }; f"
        '';
        remote-pr = ''
          "!f() { \
            declare remote=\"''${1:-origin}\"; \
            git config --add "remote.$remote.fetch" "+refs/pull/*:refs/remotes/origin/pull/*"; \
                }; f"
        '';
        # Delete all merged branches
        cleanbranches =
          "!git branch --merged | egrep -v '(^\\\\*|master|develop)' | xargs -r git branch -d";
      };

      signing = { signByDefault = true; };
    };

    xdg.configFile."pass-git-helper/git-pass-mapping.ini".text = ''
      [DEFAULT]
      username_extractor=regex_search
      regex_username=^login: (.*)$
    '';
  };
}
