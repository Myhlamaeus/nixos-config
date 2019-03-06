;; evil
(require 'evil-leader)
	(global-evil-leader-mode)
	(evil-leader/set-leader ",")

(require 'undo-tree)
	(global-undo-tree-mode)

(require 'evil)
	(evil-mode 1)

(require 'evil-args)
	;; bind evil-args text objects
	(define-key evil-inner-text-objects-map "a" 'evil-inner-arg)
	(define-key evil-outer-text-objects-map "a" 'evil-outer-arg)

	;; bind evil-forward/backward-args
	;; (define-key evil-normal-state-map "L" 'evil-forward-arg)
	;; (define-key evil-normal-state-map "H" 'evil-backward-arg)
	(define-key evil-motion-state-map "L" 'evil-forward-arg)
	(define-key evil-motion-state-map "H" 'evil-backward-arg)

	;; bind evil-jump-out-args
	(define-key evil-normal-state-map "K" 'evil-jump-out-args)

(require 'evil-ediff)

(require 'evil-exchange)
	(setq evil-exchange-key (kbd "gx"))
	(setq evil-exchange-cancel-key (kbd "gX"))
	(evil-exchange-install)

(require 'expand-region)
(require 'iedit)
(require 'evil-iedit-state)

(require 'evil-indent-plus)
	(evil-indent-plus-default-bindings)

(require 'evil-lisp-state)
	(evil-lisp-state-leader ", l")

(require 'evil-mc)

(require 'evil-nerd-commenter)
(progn
      ;; double all the commenting functions so that the inverse operations
      ;; can be called without setting a flag
      (defun spacemacs/comment-or-uncomment-lines-inverse (&optional arg)
        (interactive "p")
        (let ((evilnc-invert-comment-line-by-line t))
          (evilnc-comment-or-uncomment-lines arg)))

      (defun spacemacs/comment-or-uncomment-lines (&optional arg)
        (interactive "p")
        (let ((evilnc-invert-comment-line-by-line nil))
          (evilnc-comment-or-uncomment-lines arg)))

      (defun spacemacs/copy-and-comment-lines-inverse (&optional arg)
        (interactive "p")
        (let ((evilnc-invert-comment-line-by-line t))
          (evilnc-copy-and-comment-lines arg)))

      (defun spacemacs/copy-and-comment-lines (&optional arg)
        (interactive "p")
        (let ((evilnc-invert-comment-line-by-line nil))
          (evilnc-copy-and-comment-lines arg)))

      (defun spacemacs/quick-comment-or-uncomment-to-the-line-inverse
          (&optional arg)
        (interactive "p")
        (let ((evilnc-invert-comment-line-by-line t))
          (evilnc-comment-or-uncomment-to-the-line arg)))

      (defun spacemacs/quick-comment-or-uncomment-to-the-line (&optional arg)
        (interactive "p")
        (let ((evilnc-invert-comment-line-by-line nil))
          (evilnc-comment-or-uncomment-to-the-line arg)))

      (defun spacemacs/comment-or-uncomment-paragraphs-inverse (&optional arg)
        (interactive "p")
        (let ((evilnc-invert-comment-line-by-line t))
          (evilnc-comment-or-uncomment-paragraphs arg)))

      (defun spacemacs/comment-or-uncomment-paragraphs (&optional arg)
        (interactive "p")
        (let ((evilnc-invert-comment-line-by-line nil))
          (evilnc-comment-or-uncomment-paragraphs arg)))

      (define-key evil-normal-state-map "gc" 'evilnc-comment-operator)
      (define-key evil-normal-state-map "gy" 'spacemacs/copy-and-comment-lines)

      (evil-leader/set-key
        ";"  'evilnc-comment-operator
        "cl" 'spacemacs/comment-or-uncomment-lines
        "cL" 'spacemacs/comment-or-uncomment-lines-inverse
        "cp" 'spacemacs/comment-or-uncomment-paragraphs
        "cP" 'spacemacs/comment-or-uncomment-paragraphs-inverse
        "ct" 'spacemacs/quick-comment-or-uncomment-to-the-line
        "cT" 'spacemacs/quick-comment-or-uncomment-to-the-line-inverse
        "cy" 'spacemacs/copy-and-comment-lines
        "cY" 'spacemacs/copy-and-comment-lines-inverse))

