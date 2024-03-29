;; -*- mode: emacs-lisp; lexical-binding: t -*-
;; This file is loaded by Spacemacs at startup.
;; It must be stored in your home directory.

(defun dotspacemacs/layers ()
  "Layer configuration:
This function should only modify configuration layer settings."
  (setq-default
   ;; Base distribution to use. This is a layer contained in the directory
   ;; `+distribution'. For now available distributions are `spacemacs-base'
   ;; or `spacemacs'. (default 'spacemacs)
   dotspacemacs-distribution 'spacemacs

   ;; Lazy installation of layers (i.e. layers are installed only when a file
   ;; with a supported type is opened). Possible values are `all', `unused'
   ;; and `nil'. `unused' will lazy install only unused layers (i.e. layers
   ;; not listed in variable `dotspacemacs-configuration-layers'), `all' will
   ;; lazy install any layer that support lazy installation even the layers
   ;; listed in `dotspacemacs-configuration-layers'. `nil' disable the lazy
   ;; installation feature and you have to explicitly list a layer in the
   ;; variable `dotspacemacs-configuration-layers' to install it.
   ;; (default 'unused)
   dotspacemacs-enable-lazy-installation 'unused

   ;; If non-nil then Spacemacs will ask for confirmation before installing
   ;; a layer lazily. (default t)
   dotspacemacs-ask-for-lazy-installation t

   ;; List of additional paths where to look for configuration layers.
   ;; Paths must have a trailing slash (i.e. `~/.mycontribs/')
   dotspacemacs-configuration-layer-path '()

   ;; List of configuration layers to load.
   dotspacemacs-configuration-layers
   '(
     elixir
     csv
     (colors :variables
       colors-colorize-identifiers 'all
       )
     (csharp :variables
       csharp-backend 'lsp
       )
     (dash :variables
       dash-docs-docset-newpath "~/.local/share/Zeal/Zeal/docsets"
       )
     dhall
     (elfeed :variables
       rmh-elfeed-org-files (list
                              "~/.config/emacs/private/elfeed/dev.org"
                              "~/.config/emacs/private/elfeed/fun.org"
                              "~/.config/emacs/private/elfeed/math.org"
                              )
       )
     epub
     finance
     floobits
     github
     graphviz
     gtags
     (haskell :variables
       haskell-completion-backend 'lsp
       )
     (html :variables
       css-enable-lsp t
       html-enable-lsp t
       web-fmt-tool 'prettier
       )
     (javascript :variables
       javascript-fmt-on-save t
       javascript-fmt-tool 'prettier
       )
     (json :variables
       json-fmt-on-save t
       json-fmt-tool 'prettier
       )
     nixos
     notmuch
     pass
     pdf
     prettier
     protobuf
     python
     react
     shell-scripts
     speed-reading
     templates
     (terraform :variables
       terraform-auto-format-on-save t
       )
     (typescript :variables
       typescript-fmt-on-save t
       typescript-fmt-tool 'prettier
       )
     (yaml :variables
       yaml-enable-lsp t)
     ;; ----------------------------------------------------------------
     ;; Example of useful layers you may want to use right away.
     ;; Uncomment some layer names and press `SPC f e R' (Vim style) or
     ;; `M-m f e R' (Emacs style) to install them.
     ;; ----------------------------------------------------------------
     auto-completion
     ;; better-defaults
     emacs-lisp
     git
     helm
     lsp
     ;; markdown
     multiple-cursors
     (org :variables
       org-enable-roam-support t
       org-enable-roam-protocol t
       org-agenda-files '("~/org" "~/org/roam" "~/org/roam/daily")
       org-roam-directory "~/org/roam"
       org-roam-capture-templates '(
                                    ("d" "default" plain "%?"
                                      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
                                      :unnarrowed t
                                      )
                                    ("r" "ref" plain "${body}\n%?"
                                      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" ":PROPERTIES:
:URL: ${ref}
:ROAM_REFS: ${ref}
:END:
#+title: ${title}
")
                                      :unnarrowed t
                                      )
                                    ("c" "cite" plain "%?"
                                      :if-new (file+head "${citekey}.org" "#+TITLE: ${citekey}: ${title}
#+ROAM_KEY: ${ref}
- tags ::
- keywords :: ${keywords}
* ${title}
  :PROPERTIES:
  :Custom_ID: ${citekey}
  :URL: ${url}
  :AUTHOR: ${author-or-editor}
  :NOTER_DOCUMENT: ${file}
  :NOTER_AUTO_SAVE_LAST_LOCATION: t
  :END:
                                          ")
                                      :unnarrowed t)
                                   )
       org-roam-dailies-capture-templates '(
                                            ("d" "default" plain
                                              "** %?"
                                              :if-new (file+head+olp "%<%Y-%m-%d>.org" "#+title: %<%F> (%<%G-W%V-%u>)" ("Journal"))
                                              )
                                            ("n" "now" plain
                                              "** %<%H:%M>\n   %?"
                                              :if-new (file+head+olp "%<%Y-%m-%d>.org" "#+title: %<%F> (%<%G-W%V-%u>)" ("Journal")))
                                           )
       org-roam-v2-ack t
       )
     (bibtex :variables
       bibtex-completion-bibliography (expand-file-name "~/My Library.bib")
       bibtex-completion-pdf-field "file"
       ;; org-ref stuff (but used by bibtex layer)
       org-ref-default-bibliography (list bibtex-completion-bibliography)
       org-ref-get-pdf-filename-function 'org-ref-get-pdf-filename-helm-bibtex
       org-ref-pdf-directory "~/org/papers/"
       org-ref-bibliography-notes "~/org/papers/notes.org")
     (shell :variables
            shell-default-height 30
            shell-default-position 'bottom)
     spell-checking
     syntax-checking
     version-control
     treemacs
     )

   ;; List of additional packages that will be installed without being wrapped
   ;; in a layer (generally the packages are installed only and should still be
   ;; loaded using load/require/use-package in the user-config section below in
   ;; this file). If you need some configuration for these packages, then
   ;; consider creating a layer. You can also put the configuration in
   ;; `dotspacemacs/user-config'. To use a local version of a package, use the
   ;; `:location' property: '(your-package :location "~/path/to/your-package/")
   ;; Also include the dependencies as they will not be resolved automatically.
   dotspacemacs-additional-packages '(editorconfig direnv org-noter ttl-mode org-board ob-http org-roam-bibtex org-chef org-pdftools org-caldav elfeed-score (org-krita :location (recipe :fetcher github :repo "lepisma/org-krita")))

   ;; A list of packages that cannot be updated.
   dotspacemacs-frozen-packages '()

   ;; A list of packages that will not be installed and loaded.
   dotspacemacs-excluded-packages '()

   ;; Defines the behaviour of Spacemacs when installing packages.
   ;; Possible values are `used-only', `used-but-keep-unused' and `all'.
   ;; `used-only' installs only explicitly used packages and deletes any unused
   ;; packages as well as their unused dependencies. `used-but-keep-unused'
   ;; installs only the used packages but won't delete unused ones. `all'
   ;; installs *all* packages supported by Spacemacs and never uninstalls them.
   ;; (default is `used-only')
   dotspacemacs-install-packages 'used-only))

(defun dotspacemacs/init ()
  "Initialization:
This function is called at the very beginning of Spacemacs startup,
before layer configuration.
It should only modify the values of Spacemacs settings."
  ;; This setq-default sexp is an exhaustive list of all the supported
  ;; spacemacs settings.
  (setq-default
   ;; If non-nil then enable support for the portable dumper. You'll need
   ;; to compile Emacs 27 from source following the instructions in file
   ;; EXPERIMENTAL.org at to root of the git repository.
   ;; (default nil)
   dotspacemacs-enable-emacs-pdumper nil

   ;; Name of executable file pointing to emacs 27+. This executable must be
   ;; in your PATH.
   ;; (default "emacs")
   dotspacemacs-emacs-pdumper-executable-file "emacs"

   ;; Name of the Spacemacs dump file. This is the file will be created by the
   ;; portable dumper in the cache directory under dumps sub-directory.
   ;; To load it when starting Emacs add the parameter `--dump-file'
   ;; when invoking Emacs 27.1 executable on the command line, for instance:
   ;;   ./emacs --dump-file=$HOME/.emacs.d/.cache/dumps/spacemacs-27.1.pdmp
   ;; (default (format "spacemacs-%s.pdmp" emacs-version))
   dotspacemacs-emacs-dumper-dump-file (format "spacemacs-%s.pdmp" emacs-version)

   ;; If non-nil ELPA repositories are contacted via HTTPS whenever it's
   ;; possible. Set it to nil if you have no way to use HTTPS in your
   ;; environment, otherwise it is strongly recommended to let it set to t.
   ;; This variable has no effect if Emacs is launched with the parameter
   ;; `--insecure' which forces the value of this variable to nil.
   ;; (default t)
   dotspacemacs-elpa-https t

   ;; Maximum allowed time in seconds to contact an ELPA repository.
   ;; (default 5)
   dotspacemacs-elpa-timeout 5

   ;; Set `gc-cons-threshold' and `gc-cons-percentage' when startup finishes.
   ;; This is an advanced option and should not be changed unless you suspect
   ;; performance issues due to garbage collection operations.
   ;; (default '(100000000 0.1))
   dotspacemacs-gc-cons '(100000000 0.1)

   ;; Set `read-process-output-max' when startup finishes.
   ;; This defines how much data is read from a foreign process.
   ;; Setting this >= 1 MB should increase performance for lsp servers
   ;; in emacs 27.
   ;; (default (* 1024 1024))
   dotspacemacs-read-process-output-max (* 1024 1024)

   ;; If non-nil then Spacelpa repository is the primary source to install
   ;; a locked version of packages. If nil then Spacemacs will install the
   ;; latest version of packages from MELPA. Spacelpa is currently in
   ;; experimental state please use only for testing purposes.
   ;; (default nil)
   dotspacemacs-use-spacelpa nil

   ;; If non-nil then verify the signature for downloaded Spacelpa archives.
   ;; (default t)
   dotspacemacs-verify-spacelpa-archives t

   ;; If non-nil then spacemacs will check for updates at startup
   ;; when the current branch is not `develop'. Note that checking for
   ;; new versions works via git commands, thus it calls GitHub services
   ;; whenever you start Emacs. (default nil)
   dotspacemacs-check-for-update nil

   ;; If non-nil, a form that evaluates to a package directory. For example, to
   ;; use different package directories for different Emacs versions, set this
   ;; to `emacs-version'. (default 'emacs-version)
   dotspacemacs-elpa-subdirectory 'emacs-version

   ;; One of `vim', `emacs' or `hybrid'.
   ;; `hybrid' is like `vim' except that `insert state' is replaced by the
   ;; `hybrid state' with `emacs' key bindings. The value can also be a list
   ;; with `:variables' keyword (similar to layers). Check the editing styles
   ;; section of the documentation for details on available variables.
   ;; (default 'vim)
   dotspacemacs-editing-style 'vim

   ;; If non-nil show the version string in the Spacemacs buffer. It will
   ;; appear as (spacemacs version)@(emacs version)
   ;; (default t)
   dotspacemacs-startup-buffer-show-version t

   ;; Specify the startup banner. Default value is `official', it displays
   ;; the official spacemacs logo. An integer value is the index of text
   ;; banner, `random' chooses a random text banner in `core/banners'
   ;; directory. A string value must be a path to an image format supported
   ;; by your Emacs build.
   ;; If the value is nil then no banner is displayed. (default 'official)
   dotspacemacs-startup-banner 'official

   ;; List of items to show in startup buffer or an association list of
   ;; the form `(list-type . list-size)`. If nil then it is disabled.
   ;; Possible values for list-type are:
   ;; `recents' `bookmarks' `projects' `agenda' `todos'.
   ;; List sizes may be nil, in which case
   ;; `spacemacs-buffer-startup-lists-length' takes effect.
   dotspacemacs-startup-lists '((recents . 5)
                                (projects . 7))

   ;; True if the home buffer should respond to resize events. (default t)
   dotspacemacs-startup-buffer-responsive t

   ;; Default major mode for a new empty buffer. Possible values are mode
   ;; names such as `text-mode'; and `nil' to use Fundamental mode.
   ;; (default `text-mode')
   dotspacemacs-new-empty-buffer-major-mode 'text-mode

   ;; Default major mode of the scratch buffer (default `text-mode')
   dotspacemacs-scratch-mode 'text-mode

   ;; If non-nil, *scratch* buffer will be persistent. Things you write down in
   ;; *scratch* buffer will be saved and restored automatically.
   dotspacemacs-scratch-buffer-persistent nil

   ;; If non-nil, `kill-buffer' on *scratch* buffer
   ;; will bury it instead of killing.
   dotspacemacs-scratch-buffer-unkillable nil

   ;; Initial message in the scratch buffer, such as "Welcome to Spacemacs!"
   ;; (default nil)
   dotspacemacs-initial-scratch-message nil

   ;; List of themes, the first of the list is loaded when spacemacs starts.
   ;; Press `SPC T n' to cycle to the next theme in the list (works great
   ;; with 2 themes variants, one dark and one light)
   dotspacemacs-themes '(spacemacs-dark
                         spacemacs-light)

   ;; Set the theme for the Spaceline. Supported themes are `spacemacs',
   ;; `all-the-icons', `custom', `doom', `vim-powerline' and `vanilla'. The
   ;; first three are spaceline themes. `doom' is the doom-emacs mode-line.
   ;; `vanilla' is default Emacs mode-line. `custom' is a user defined themes,
   ;; refer to the DOCUMENTATION.org for more info on how to create your own
   ;; spaceline theme. Value can be a symbol or list with additional properties.
   ;; (default '(spacemacs :separator wave :separator-scale 1.5))
   dotspacemacs-mode-line-theme '(spacemacs :separator wave :separator-scale 1.5)

   ;; If non-nil the cursor color matches the state color in GUI Emacs.
   ;; (default t)
   dotspacemacs-colorize-cursor-according-to-state t

   ;; Default font or prioritized list of fonts.
   dotspacemacs-default-font '("Fira Code"
                               :size 10.0
                               :weight normal
                               :width normal)

   ;; The leader key (default "SPC")
   dotspacemacs-leader-key "SPC"

   ;; The key used for Emacs commands `M-x' (after pressing on the leader key).
   ;; (default "SPC")
   dotspacemacs-emacs-command-key "SPC"

   ;; The key used for Vim Ex commands (default ":")
   dotspacemacs-ex-command-key ":"

   ;; The leader key accessible in `emacs state' and `insert state'
   ;; (default "M-m")
   dotspacemacs-emacs-leader-key "M-m"

   ;; Major mode leader key is a shortcut key which is the equivalent of
   ;; pressing `<leader> m`. Set it to `nil` to disable it. (default ",")
   dotspacemacs-major-mode-leader-key ","

   ;; Major mode leader key accessible in `emacs state' and `insert state'.
   ;; (default "C-M-m" for terminal mode, "<M-return>" for GUI mode).
   ;; Thus M-RET should work as leader key in both GUI and terminal modes.
   ;; C-M-m also should work in terminal mode, but not in GUI mode.
   dotspacemacs-major-mode-emacs-leader-key (if window-system "<M-return>" "C-M-m")

   ;; These variables control whether separate commands are bound in the GUI to
   ;; the key pairs `C-i', `TAB' and `C-m', `RET'.
   ;; Setting it to a non-nil value, allows for separate commands under `C-i'
   ;; and TAB or `C-m' and `RET'.
   ;; In the terminal, these pairs are generally indistinguishable, so this only
   ;; works in the GUI. (default nil)
   dotspacemacs-distinguish-gui-tab nil

   ;; Name of the default layout (default "Default")
   dotspacemacs-default-layout-name "Default"

   ;; If non-nil the default layout name is displayed in the mode-line.
   ;; (default nil)
   dotspacemacs-display-default-layout nil

   ;; If non-nil then the last auto saved layouts are resumed automatically upon
   ;; start. (default nil)
   dotspacemacs-auto-resume-layouts nil

   ;; If non-nil, auto-generate layout name when creating new layouts. Only has
   ;; effect when using the "jump to layout by number" commands. (default nil)
   dotspacemacs-auto-generate-layout-names nil

   ;; Size (in MB) above which spacemacs will prompt to open the large file
   ;; literally to avoid performance issues. Opening a file literally means that
   ;; no major mode or minor modes are active. (default is 1)
   dotspacemacs-large-file-size 1

   ;; Location where to auto-save files. Possible values are `original' to
   ;; auto-save the file in-place, `cache' to auto-save the file to another
   ;; file stored in the cache directory and `nil' to disable auto-saving.
   ;; (default 'cache)
   dotspacemacs-auto-save-file-location 'cache

   ;; Maximum number of rollback slots to keep in the cache. (default 5)
   dotspacemacs-max-rollback-slots 5

   ;; If non-nil, the paste transient-state is enabled. While enabled, after you
   ;; paste something, pressing `C-j' and `C-k' several times cycles through the
   ;; elements in the `kill-ring'. (default nil)
   dotspacemacs-enable-paste-transient-state nil

   ;; Which-key delay in seconds. The which-key buffer is the popup listing
   ;; the commands bound to the current keystroke sequence. (default 0.4)
   dotspacemacs-which-key-delay 0.4

   ;; Which-key frame position. Possible values are `right', `bottom' and
   ;; `right-then-bottom'. right-then-bottom tries to display the frame to the
   ;; right; if there is insufficient space it displays it at the bottom.
   ;; (default 'bottom)
   dotspacemacs-which-key-position 'bottom

   ;; Control where `switch-to-buffer' displays the buffer. If nil,
   ;; `switch-to-buffer' displays the buffer in the current window even if
   ;; another same-purpose window is available. If non-nil, `switch-to-buffer'
   ;; displays the buffer in a same-purpose window even if the buffer can be
   ;; displayed in the current window. (default nil)
   dotspacemacs-switch-to-buffer-prefers-purpose nil

   ;; If non-nil a progress bar is displayed when spacemacs is loading. This
   ;; may increase the boot time on some systems and emacs builds, set it to
   ;; nil to boost the loading time. (default t)
   dotspacemacs-loading-progress-bar t

   ;; If non-nil the frame is fullscreen when Emacs starts up. (default nil)
   ;; (Emacs 24.4+ only)
   dotspacemacs-fullscreen-at-startup nil

   ;; If non-nil `spacemacs/toggle-fullscreen' will not use native fullscreen.
   ;; Use to disable fullscreen animations in OSX. (default nil)
   dotspacemacs-fullscreen-use-non-native nil

   ;; If non-nil the frame is maximized when Emacs starts up.
   ;; Takes effect only if `dotspacemacs-fullscreen-at-startup' is nil.
   ;; (default nil) (Emacs 24.4+ only)
   dotspacemacs-maximized-at-startup nil

   ;; If non-nil the frame is undecorated when Emacs starts up. Combine this
   ;; variable with `dotspacemacs-maximized-at-startup' in OSX to obtain
   ;; borderless fullscreen. (default nil)
   dotspacemacs-undecorated-at-startup nil

   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's active or selected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-active-transparency 90

   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's inactive or deselected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-inactive-transparency 90

   ;; If non-nil show the titles of transient states. (default t)
   dotspacemacs-show-transient-state-title t

   ;; If non-nil show the color guide hint for transient state keys. (default t)
   dotspacemacs-show-transient-state-color-guide t

   ;; If non-nil unicode symbols are displayed in the mode line.
   ;; If you use Emacs as a daemon and wants unicode characters only in GUI set
   ;; the value to quoted `display-graphic-p'. (default t)
   dotspacemacs-mode-line-unicode-symbols t

   ;; If non-nil smooth scrolling (native-scrolling) is enabled. Smooth
   ;; scrolling overrides the default behavior of Emacs which recenters point
   ;; when it reaches the top or bottom of the screen. (default t)
   dotspacemacs-smooth-scrolling t

   ;; Control line numbers activation.
   ;; If set to `t', `relative' or `visual' then line numbers are enabled in all
   ;; `prog-mode' and `text-mode' derivatives. If set to `relative', line
   ;; numbers are relative. If set to `visual', line numbers are also relative,
   ;; but lines are only visual lines are counted. For example, folded lines
   ;; will not be counted and wrapped lines are counted as multiple lines.
   ;; This variable can also be set to a property list for finer control:
   ;; '(:relative nil
   ;;   :visual nil
   ;;   :disabled-for-modes dired-mode
   ;;                       doc-view-mode
   ;;                       markdown-mode
   ;;                       org-mode
   ;;                       pdf-view-mode
   ;;                       text-mode
   ;;   :size-limit-kb 1000)
   ;; When used in a plist, `visual' takes precedence over `relative'.
   ;; (default nil)
   dotspacemacs-line-numbers 'relative

   ;; Code folding method. Possible values are `evil', `origami' and `vimish'.
   ;; (default 'evil)
   dotspacemacs-folding-method 'evil

   ;; If non-nil `smartparens-strict-mode' will be enabled in programming modes.
   ;; (default nil)
   dotspacemacs-smartparens-strict-mode nil

   ;; If non-nil pressing the closing parenthesis `)' key in insert mode passes
   ;; over any automatically added closing parenthesis, bracket, quote, etc...
   ;; This can be temporary disabled by pressing `C-q' before `)'. (default nil)
   dotspacemacs-smart-closing-parenthesis nil

   ;; Select a scope to highlight delimiters. Possible values are `any',
   ;; `current', `all' or `nil'. Default is `all' (highlight any scope and
   ;; emphasis the current one). (default 'all)
   dotspacemacs-highlight-delimiters 'all

   ;; If non-nil, start an Emacs server if one is not already running.
   ;; (default nil)
   dotspacemacs-enable-server nil

   ;; Set the emacs server socket location.
   ;; If nil, uses whatever the Emacs default is, otherwise a directory path
   ;; like \"~/.emacs.d/server\". It has no effect if
   ;; `dotspacemacs-enable-server' is nil.
   ;; (default nil)
   dotspacemacs-server-socket-dir nil

   ;; If non-nil, advise quit functions to keep server open when quitting.
   ;; (default nil)
   dotspacemacs-persistent-server nil

   ;; List of search tool executable names. Spacemacs uses the first installed
   ;; tool of the list. Supported tools are `rg', `ag', `pt', `ack' and `grep'.
   ;; (default '("rg" "ag" "pt" "ack" "grep"))
   dotspacemacs-search-tools '("rg" "ag" "pt" "ack" "grep")

   ;; Format specification for setting the frame title.
   ;; %a - the `abbreviated-file-name', or `buffer-name'
   ;; %t - `projectile-project-name'
   ;; %I - `invocation-name'
   ;; %S - `system-name'
   ;; %U - contents of $USER
   ;; %b - buffer name
   ;; %f - visited file name
   ;; %F - frame name
   ;; %s - process status
   ;; %p - percent of buffer above top of window, or Top, Bot or All
   ;; %P - percent of buffer above bottom of window, perhaps plus Top, or Bot or All
   ;; %m - mode name
   ;; %n - Narrow if appropriate
   ;; %z - mnemonics of buffer, terminal, and keyboard coding systems
   ;; %Z - like %z, but including the end-of-line format
   ;; (default "%I@%S")
   dotspacemacs-frame-title-format "%I@%S"

   ;; Format specification for setting the icon title format
   ;; (default nil - same as frame-title-format)
   dotspacemacs-icon-title-format nil

   ;; Delete whitespace while saving buffer. Possible values are `all'
   ;; to aggressively delete empty line and long sequences of whitespace,
   ;; `trailing' to delete only the whitespace at end of lines, `changed' to
   ;; delete only whitespace for changed lines or `nil' to disable cleanup.
   ;; (default nil)
   dotspacemacs-whitespace-cleanup nil

   ;; If non nil activate `clean-aindent-mode' which tries to correct
   ;; virtual indentation of simple modes. This can interfer with mode specific
   ;; indent handling like has been reported for `go-mode'.
   ;; If it does deactivate it here.
   ;; (default t)
   dotspacemacs-use-clean-aindent-mode t

   ;; If non-nil shift your number row to match the entered keyboard layout
   ;; (only in insert state). Currently supported keyboard layouts are:
   ;; `qwerty-us', `qwertz-de' and `querty-ca-fr'.
   ;; New layouts can be added in `spacemacs-editing' layer.
   ;; (default nil)
   dotspacemacs-swap-number-row nil

   ;; Either nil or a number of seconds. If non-nil zone out after the specified
   ;; number of seconds. (default nil)
   dotspacemacs-zone-out-when-idle nil

   ;; Run `spacemacs/prettify-org-buffer' when
   ;; visiting README.org files of Spacemacs.
   ;; (default nil)
   dotspacemacs-pretty-docs nil

   ;; If nil the home buffer shows the full path of agenda items
   ;; and todos. If non nil only the file name is shown.
   dotspacemacs-home-shorten-agenda-source nil))

(defun dotspacemacs/user-env ()
  "Environment variables setup.
This function defines the environment variables for your Emacs session. By
default it calls `spacemacs/load-spacemacs-env' which loads the environment
variables declared in `~/.spacemacs.env' or `~/.spacemacs.d/.spacemacs.env'.
See the header of this file for more information."
  (spacemacs/load-spacemacs-env))

(defun dotspacemacs/user-init ()
  "Initialization for user code:
This function is called immediately after `dotspacemacs/init', before layer
configuration.
It is mostly for variables that should be set before packages are loaded.
If you are unsure, try setting them in `dotspacemacs/user-config' first."
  (load "~/.config/emacs/private/user-init")
  ;; (add-to-list 'lsp-language-id-configuration '(nix-mode . "nix"))
  ;; (lsp-register-client
  ;;   (make-lsp-client :new-connection (lsp-stdio-connection '("rnix-lsp"))
  ;;     :major-modes '(nix-mode)
  ;;     :server-id 'nix))
  ;; (lsp-register-client
  ;;   (make-lsp-client :new-connection (lsp-stdio-connection '("terraform-ls" "serve"))
  ;;     :major-modes '(terraform-mode)
  ;;     :server-id 'terraform))
  )

(defun dotspacemacs/user-load ()
  "Library to load while dumping.
This function is called only while dumping Spacemacs configuration. You can
`require' or `load' the libraries of your choice that will be included in the
dump."
  )

(defun dotspacemacs/user-config ()
  "Configuration for user code:
This function is called at the very end of Spacemacs startup, after layer
configuration.
Put your configuration code here, except for variables that should be set
before packages are loaded."
  (setq message-send-mail-function 'message-send-mail-with-sendmail)
  (setq sendmail-program "msmtp")
  (setq message-sendmail-f-is-evil t)
  (setq sendmail-program "msmtp")
  (add-to-list 'interpreter-mode-alist '("nix-shell" . nix-shebang-mode))
  (global-undo-tree-mode)
  (setq evil-undo-system 'undo-tree)
  (setq undo-tree-auto-save-history t)
  (setq projectile-project-search-path (seq-filter 'f-directory? (mapcan (lambda (d) (directory-files d t "^[^.]")) (directory-files "~/.ghq" t "^[^.]"))))
  (with-eval-after-load 'org-agenda
    (require 'org-projectile)
    (mapcar '(lambda (file)
               (when (file-exists-p file)
                 (push file org-agenda-files)))
      (org-projectile-todo-files)))
  (org-babel-do-load-languages
    'org-babel-load-languages
        '((haskell . t)
           (ledger . t)
              (dot . t)
            (shell . t)
             (http . t)
       (emacs-lisp . t)))
  (require 'org-protocol)
  (defun transform-square-brackets-to-round-ones(string-to-transform)
    "Transforms [ into ( and ] into ), other chars left unchanged."
    (concat
      (mapcar #'(lambda (c) (if (equal c ?[) ?\( (if (equal c ?]) ?\) c))) string-to-transform))
    )
  (setq org-capture-templates `(
	                               ("p" "Protocol" entry (file+headline ,(concat (file-name-as-directory org-directory) "notes.org") "Inbox")
                                   "* %^{Title}\n Source: %u, [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\n\n#+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n")
	                               ("L" "Protocol Link" entry (file+headline ,(concat (file-name-as-directory org-directory) "notes.org") "Inbox")
                                   "* [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\n")
                                 ("c" "Cookbook" entry (file "~/org/cookbook.org")
                                   "%(org-chef-get-recipe-from-url)"
                                   :empty-lines 1)
                                 ("m" "Manual Cookbook" entry (file "~/org/cookbook.org")
                                   "* %^{Recipe title: }\n  :PROPERTIES:\n  :source-url:\n  :servings:\n  :prep-time:\n  :cook-time:\n  :ready-in:\n  :END:\n** Ingredients\n   %?\n** Directions\n\n")
                                 ))
  (setq evil-want-minibuffer t)
  (spacemacs/declare-prefix-for-minor-mode 'org-noter-doc-mode
    "N" "org-noter"
    )
  (spacemacs/set-leader-keys-for-minor-mode 'org-noter-doc-mode
    "Ni" 'org-noter-insert-note
    "NI" 'org-noter-insert-precise-note
    "Nn" 'org-noter-sync-next-note
    "NN" 'org-noter-sync-prev-note
    "N," 'org-noter-sync-current-note
    "Nj" 'org-noter-sync-next-page-or-chapter
    "Nk" 'org-noter-sync-prev-page-or-chapter
    )
  (spacemacs/declare-prefix-for-minor-mode 'org-noter-notes-mode
    "N" "org-noter"
    )
  (spacemacs/set-leader-keys-for-minor-mode 'org-noter-notes-mode
    "Nn" 'org-noter-sync-next-note
    "NN" 'org-noter-sync-prev-note
    "N," 'org-noter-sync-current-note
    )
  (spacemacs/declare-prefix
    "aordc" "org-roam-dailies-capture"
    )
  (spacemacs/set-leader-keys
    "aordct" 'org-roam-dailies-capture-today
    "aordcy" 'org-roam-dailies-capture-yesterday
    "aordcT" 'org-roam-dailies-capture-tomorrow
    "aordcd" 'org-roam-dailies-capture-date
    )
  (setq org-noter-notes-search-path '("~/org/roam"))
  (setq org-noter-default-notes-file-names '("notes.org" "mathematics-exercises.org" "general-reading.org"))
  (add-to-list 'hs-special-modes-alist '(typescript-mode "{" "}" "/[*/]" nil))
  (setq org-refile-targets '((org-agenda-files . (:maxlevel . 2))))
  (setq org-refile-use-outline-path 'buffer-name)
  (setq org-outline-path-complete-in-steps nil)
  (setq org-pomodoro-clock-break t)
  (use-package org-roam-bibtex
    :after org-roam
    :hook (org-roam-mode . org-roam-bibtex-mode)
    :custom
    (orb-preformat-keywords '("citekey" "title" "url" "author-or-editor" "keywords" "file"))
    (orb-file-field-extensions '("pdf" "epub" "html"))

    )
  ;; (use-package org-pdftools
  ;;   :hook (org-load . org-pdftools-setup-link))
  (use-package org-noter
    :after (:any org pdf-view)
    :custom (org-noter-always-create-frame nil))
  ;; (use-package org-noter-pdftools
  ;;   :after org-noter
  ;;   :config
  ;;   (with-eval-after-load 'pdf-annot
  ;;     (add-hook 'pdf-annot-activate-handler-functions #'org-noter-pdftools-jump-to-note)))
  (use-package org-caldav
    :after org
    :custom
      (org-caldav-url "http://localhost:37358/maublew")
      (org-caldav-calendars '(
                              (
                                :calendar-id "elQOagpMiFzKw3JjVsGf00deUmbDgIR0"
                                :files ("~/media/keybase/private/myhlamaeus/org/roam/20210629180543-day_to_day_schedule.org")
                                :inbox (file+headline "~/media/keybase/private/myhlamaeus/org/roam/20210629180543-day_to_day_schedule.org" "Inbox")
                                )
                              (
                                :calendar-id "HQH290Ndqz11QAmcVBZG03BoXaIb2Dj9"
                                :files ("~/media/keybase/private/myhlamaeus/org/roam/20210704153949-trash.org")
                                :inbox (file+headline "~/media/keybase/private/myhlamaeus/org/roam/20210704153949-trash.org" "Inbox")
                                )
                              (
                                :calendar-id "PcGVhrtcG6ilHNz57koWYfCguhIb2kxM"
                                :files ("~/media/keybase/private/myhlamaeus/org/roam/20210705050400-holidays.org")
                                :inbox (file+headline "~/media/keybase/private/myhlamaeus/org/roam/20210705050400-holidays.org" "Inbox")
                                )
                              ;; (
                              ;;   :calendar-id
                              ;;   :files ("~/.ghq/gitlab.com/fitnesspilot/fitnesspilot/TODOs.org")
                              ;;   :inbox (file+headline "~/.ghq/gitlab.com/fitnesspilot/fitnesspilot/TODOs.org" "Inbox")
                              ;;   )
                              )
        )
      (org-caldav-backup-file "~/org.bak/caldav/backup.org")
      (org-caldav-save-directory "~/org.bak/caldav/saves/")
    )
  (use-package elfeed-score
    :after elfeed
    :custom
      (elfeed-search-print-entry-function #'elfeed-score-print-entry)
    :config
      (elfeed-score-enable)
      (define-key elfeed-search-mode-map "=" elfeed-score-map)
      (run-at-time nil (* 1 60 60) #'elfeed-update)
    )
  (use-package org-krita
    :config
    (add-hook 'org-mode-hook 'org-krita-mode))
  )

;; Do not write anything past this comment. This is where Emacs will
;; auto-generate custom variable definitions.
(defun dotspacemacs/emacs-custom-settings ()
  "Emacs custom settings.
This is an auto-generated function, do not modify its content directly, use
Emacs customize menu instead.
This function is called at the very end of Spacemacs initialization."
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(direnv-mode t nil (direnv))
 '(editorconfig-mode t)
 '(evil-undo-system 'undo-tree)
 '(evil-want-Y-yank-to-eol nil)
 '(haskell-font-lock-symbols t)
 '(package-selected-packages
    '(org-krita elfeed-score org-chef flycheck-credo elixir-mode reformatter floobits highlight dhall-mode ob-http github-search github-clone gist gh marshal logito pcache forge ghub closql emacsql-sqlite emacsql treepy graphviz-dot-mode org-board org-noter pdf-tools spray csv-mode magit-section helm-notmuch notmuch git-gutter-fringe+ fringe-helper git-gutter+ browse-at-remote org-journal protobuf-mode zeal-at-point helm-dash dash-docs elfeed-org elfeed-goodies ace-jump-mode noflet elfeed helm-pass password-store auth-source-pass rainbow-mode rainbow-identifiers color-identifiers-mode yatemplate dap-mode bui tree-mode nov esxml powershell counsel-gtags counsel swiper ivy rjsx-mode treemacs-magit smeargle orgit magit-svn magit-gitflow magit-popup helm-gitignore helm-git-grep gitignore-templates gitignore-mode gitconfig-mode gitattributes-mode git-timemachine git-messenger git-link evil-magit transient git-commit with-editor python ttl-mode yasnippet-snippets yapfify yaml-mode xterm-color web-mode web-beautify vterm tide typescript-mode tagedit slim-mode shell-pop scss-mode sass-mode pytest pyenv-mode py-isort pug-mode prettier-js pippel pipenv pyvenv pip-requirements org-projectile org-category-capture org-present org-pomodoro alert log4e gntp org-mime org-download org-cliplink org-brain omnisharp nodejs-repl nix-mode multi-term mmm-mode markdown-toc lsp-haskell lsp-mode markdown-mode livid-mode skewer-mode live-py-mode json-navigator hierarchy json-mode json-snatcher json-reformat js2-refactor multiple-cursors js2-mode js-doc intero insert-shebang importmagic epc ctable concurrent deferred impatient-mode simple-httpd htmlize hlint-refactor hindent helm-pydoc helm-org-rifle helm-org helm-nixos-options helm-hoogle helm-gtags helm-css-scss helm-company helm-c-yasnippet haskell-snippets haml-mode gnuplot gh-md ggtags fuzzy flyspell-correct-helm flyspell-correct flycheck-pos-tip pos-tip flycheck-ledger flycheck-haskell flycheck-bashate fish-mode evil-org evil-ledger ledger-mode eshell-z eshell-prompt-extras esh-help emmet-mode direnv dante lcr cython-mode csharp-mode company-web web-completion-data company-terraform terraform-mode hcl-mode company-tern dash-functional tern company-statistics company-shell company-nixos-options nixos-options company-ghci company-ghc ghc haskell-mode company-cabal company-anaconda company cmm-mode blacken auto-yasnippet yasnippet auto-dictionary attrap anaconda-mode pythonic ac-ispell auto-complete ws-butler writeroom-mode winum which-key volatile-highlights vi-tilde-fringe uuidgen use-package treemacs-projectile treemacs-evil toc-org symon symbol-overlay string-inflection spaceline-all-the-icons restart-emacs request rainbow-delimiters popwin persp-mode pcre2el password-generator paradox overseer org-plus-contrib org-bullets open-junk-file nameless move-text macrostep lorem-ipsum link-hint indent-guide hybrid-mode hungry-delete hl-todo highlight-parentheses highlight-numbers highlight-indentation helm-xref helm-themes helm-swoop helm-purpose helm-projectile helm-mode-manager helm-make helm-flx helm-descbinds helm-ag google-translate golden-ratio font-lock+ flycheck-package flx-ido fill-column-indicator fancy-battery eyebrowse expand-region evil-visualstar evil-visual-mark-mode evil-unimpaired evil-tutor evil-textobj-line evil-surround evil-numbers evil-nerd-commenter evil-mc evil-matchit evil-lisp-state evil-lion evil-indent-plus evil-iedit-state evil-goggles evil-exchange evil-escape evil-ediff evil-cleverparens evil-args evil-anzu eval-sexp-fu elisp-slime-nav editorconfig dumb-jump dotenv-mode doom-modeline diminish devdocs define-word column-enforce-mode clean-aindent-mode centered-cursor-mode auto-highlight-symbol auto-compile aggressive-indent ace-link ace-jump-helm-line))
 '(paradox-github-token t)
 '(safe-local-variable-values
    '((undo-tree-auto-save-history)
       (yaml-enable-lsp . t)
       (lsp-haskell-process-path-hie . "ghcide")
       (lsp-haskell-process-path-hie . ghcide)
       (lsp-haskell-process-args-hie)
       (json-fmt-tool . prettier)
       (typescript-backend . tide)
       (javascript-backend . tern)
       (javascript-lsp-linter)
       (typescript-linter . eslint)
       (typescript-fmt-tool . prettier)
       (javascript-import-tool . javascript-import-tool)
       (javascript-fmt-tool . prettier)
       (web-fmt-tool . prettier)
       (typescript-backend . lsp)
       (javascript-backend . lsp))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
)
