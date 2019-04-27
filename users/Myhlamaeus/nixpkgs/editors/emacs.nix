{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;

    extraPackages = epkgs: with epkgs; [
      # undo-tree
      # evil
      # evil-leader
      # evil-anzu
      # evil-args
      # evil-ediff
      # evil-exchange
      # evil-iedit-state
      # evil-indent-plus
      # evil-lisp-state
      # evil-mc
      # evil-nerd-commenter
      # evil-matchit
      # evil-numbers
      # evil-search-highlight-persist
      # evil-surround
      # # ;; Temporarily disabled, pending the resolution of
      # # ;; https://github.com/7696122/evil-terminal-cursor-changer/issues/8
      # # ;; evil-terminal-cursor-changer
      # # evil-tutor
      # # (evil-unimpaired :location (recipe :fetcher local))
      # evil-visual-mark-mode
      # # (hs-minor-mode :location built-in)
      # linum-relative
      # vi-tilde-fringe
      # org-plus-contrib

      # expand-region
      # iedit
      # haskell-mode
    ];
  };

  services.emacs.enable = true;

  # Not yet in stable
  # systemd.user.sessionVariables = {
  home.sessionVariables = {
    VISUAL = "emacs";
  };
}
