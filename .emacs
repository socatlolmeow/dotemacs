;;; .emacs --- init file -*- lexical-binding: t -*-
(server-start)
(setq custom-file "~/.emacs.custom.el")
(package-initialize)

(add-to-list 'load-path "~/.emacs.local/")

(load "~/.emacs.rc/rc.el")
(load "~/.emacs.rc/misc-rc.el")
(load "~/.emacs.rc/org-mode-rc.el")
(load "~/.emacs.rc/autocommit-rc.el")
(load "~/.emacs.rc/custom-rc.el")

;;; no-littering — keep ~/.emacs.d clean; load early
(rc/require 'no-littering)
(require 'no-littering)
(savehist-mode)

;;; Quality-of-life settings (from valignatev/dotemacs)
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init t
      create-lockfiles nil
      initial-major-mode 'fundamental-mode
      initial-scratch-message nil
      scroll-conservatively 101
      mouse-wheel-progressive-speed nil
      mouse-wheel-scroll-amount '(3)
      x-gtk-use-system-tooltips nil
      use-dialog-box nil
      auto-window-vscroll nil
      vc-follow-symlinks t
      confirm-kill-processes nil
      echo-keystrokes 0.5
      dired-dwim-target t
      tab-always-indent t
      ;; 1mb — improves LSP/process performance
      read-process-output-max (* 1024 1024)
      column-number-indicator-zero-based nil
      save-interprogram-paste-before-kill t
      truncate-partial-width-windows nil
      ring-bell-function 'ignore
      require-final-newline t
      imenu-max-items 1000
      imenu-max-item-length 1000
      eldoc-echo-area-use-multiline-p nil
      pixel-scroll-precision-interpolate-page t
      mouse-wheel-tilt-scroll t
      warning-minimum-level :error
      gdb-many-windows t)

(setq-default select-active-regions nil
              indent-tabs-mode nil
              truncate-lines t
              tab-width 4)

(put 'compile-run-command 'safe-local-variable #'stringp)

(defalias 'yes-or-no-p 'y-or-n-p)

;;; Appearance

;; Font: Maple Mono
(defvar font-name "Iosevka Nerd Font")
(defvar font-size 14)
(set-frame-font (format "%s-%d" font-name font-size) t t)
;; Ensure default face is set explicitly so zoom (C-x C-+/-) looks clean
(set-face-attribute 'default nil
                    :family font-name
                    :height (* font-size 10)
                    :weight 'normal)

;; Disable bold and italic regardless of theme
(defun rc/disable-bold-and-italic (theme &optional no-confirm no-enable)
  (mapc #'disable-theme (remq theme custom-enabled-themes))
  (set-face-italic 'italic nil)
  (set-face-bold 'bold nil))
(advice-add 'load-theme :after #'rc/disable-bold-and-italic)

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)
(blink-cursor-mode 0)
(global-hl-line-mode t)
(global-auto-revert-mode t)
(recentf-mode 1)
(winner-mode 1)
(pixel-scroll-precision-mode t)

;;; Transparency (GUI only)
;; alpha-background: only background is transparent, text stays sharp (Emacs 29+)
(defun rc/set-transparency (value)
  "Set frame background transparency to VALUE (0–100, 100 = opaque)."
  (interactive "nTransparency (0-100): ")
  (set-frame-parameter nil 'alpha-background value))

;; Apply on every new frame (e.g. emacsclient)
(add-to-list 'default-frame-alist '(alpha-background . 93))

;;; Theme: tokyo-night
(rc/require 'tokyo-night)
(load-theme 'tokyo-night t)

;;; gcmh — magic GC hack to reduce GC pauses
(rc/require 'gcmh)
(setq gcmh-idle-delay 5
      gcmh-high-cons-threshold (* 100 1024 1024))  ; 100mb
(add-hook 'window-setup-hook #'gcmh-mode)

;;; minions — hide minor modes in modeline
(rc/require 'minions)
(minions-mode 1)

;;; vertico — vertical minibuffer completion UI (replaces ido for C-x C-f etc.)
(rc/require 'vertico)
(vertico-mode 1)

;;; orderless — fuzzy/space-separated completion style
(rc/require 'orderless)
(setq completion-styles '(orderless basic)
      completion-category-defaults nil
      completion-category-overrides '((file (styles partial-completion))))

;;; marginalia — annotations in the minibuffer (file size, docstrings, etc.)
(rc/require 'marginalia)
(marginalia-mode 1)

;;; smex — still used for M-x (keeps your familiar M-x experience)
(rc/require 'smex)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;;; c-mode
(setq-default c-basic-offset 4
              c-default-style '((java-mode . "java")
                                (awk-mode . "awk")
                                (other . "bsd")))

(add-hook 'c-mode-hook (lambda ()
                         (interactive)
                         (c-toggle-comment-style -1)))

;;; Paredit
(rc/require 'paredit)

(defun rc/turn-on-paredit ()
  (interactive)
  (paredit-mode 1))

(add-hook 'emacs-lisp-mode-hook  'rc/turn-on-paredit)
(add-hook 'clojure-mode-hook     'rc/turn-on-paredit)
(add-hook 'lisp-mode-hook        'rc/turn-on-paredit)
(add-hook 'common-lisp-mode-hook 'rc/turn-on-paredit)
(add-hook 'scheme-mode-hook      'rc/turn-on-paredit)
(add-hook 'racket-mode-hook      'rc/turn-on-paredit)

;;; Emacs lisp
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-j") 'eval-print-last-sexp)))
(add-to-list 'auto-mode-alist '("Cask" . emacs-lisp-mode))

;;; Local modes (from ~/.emacs.local/)
(require 'basm-mode)

(require 'fasm-mode)
(add-to-list 'auto-mode-alist '("\\.asm\\'" . fasm-mode))

(require 'porth-mode)

(require 'noq-mode)

(require 'jai-mode)

(require 'simpc-mode)
(add-to-list 'auto-mode-alist '("\\.[hc]\\(pp\\)?\\'" . simpc-mode))
(add-to-list 'auto-mode-alist '("\\.[b]\\'" . simpc-mode))

(require 'tatr)

(require 'umka-mode)

(require 'c3-mode)

;;; uxntal-mode
(rc/require 'uxntal-mode)

;;; Haskell mode
(rc/require 'haskell-mode)
(setq haskell-process-type 'cabal-new-repl)
(setq haskell-process-log t)
(add-hook 'haskell-mode-hook 'haskell-indent-mode)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
(add-hook 'haskell-mode-hook 'haskell-doc-mode)

;;; Whitespace mode
(defun rc/set-up-whitespace-handling ()
  (interactive)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))

(add-hook 'tuareg-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'c++-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'c-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'simpc-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'emacs-lisp-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'java-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'lua-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'rust-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'scala-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'markdown-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'haskell-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'python-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'erlang-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'asm-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'fasm-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'go-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'nim-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'yaml-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'porth-mode-hook 'rc/set-up-whitespace-handling)

;;; Neotree
(rc/require 'neotree)
(global-set-key (kbd "C-c n") 'neotree-toggle)

;;; Smooth scrolling
(rc/require 'smooth-scrolling)
(smooth-scrolling-mode 1)
(setq smooth-scroll-margin 5)

;;; display-line-numbers-mode
(when (version<= "26.0.50" emacs-version)
  (global-display-line-numbers-mode))

;;; magit
(rc/require 'cl-lib)
(rc/require 'magit)
(setq magit-auto-revert-mode nil
      magit-diff-refine-hunk t
      git-commit-summary-max-length 73
      magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1
      magit-save-repository-buffers nil)

(global-set-key (kbd "C-c m s") 'magit-status)
(global-set-key (kbd "C-c m l") 'magit-log)

;;; git-link — copy GitHub/GitLab links to current line
(rc/require 'git-link)
(setq git-link-open-in-browser t)

;;; multiple cursors
(rc/require 'multiple-cursors)

(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->")         'mc/mark-next-like-this)
(global-set-key (kbd "C-<")         'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<")     'mc/mark-all-like-this)
(global-set-key (kbd "C-\"")        'mc/skip-to-next-like-this)
(global-set-key (kbd "C-:")         'mc/skip-to-previous-like-this)

;;; dired
(require 'dired-x)
(setq dired-omit-files
      (concat dired-omit-files "\\|^\\..+$"))
(setq-default dired-dwim-target t)
(setq dired-listing-switches "-alh")
(setq dired-mouse-drag-files t)
(add-hook 'dired-mode-hook #'dired-hide-details-mode)

;;; yasnippet
(rc/require 'yasnippet)
(require 'yasnippet)
(setq yas/triggers-in-field nil)
(setq yas-snippet-dirs '("~/.emacs.snippets/"))
(yas-global-mode 1)
(setcar (cdr (assq 'yas-minor-mode minor-mode-alist)) " meow")

;;; word-wrap
(defun rc/enable-word-wrap ()
  (interactive)
  (toggle-word-wrap 1))

(add-hook 'markdown-mode-hook 'rc/enable-word-wrap)
(add-hook 'text-mode-hook #'visual-line-mode)
(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'compilation-mode-hook #'visual-line-mode)

;;; nxml
(add-to-list 'auto-mode-alist '("\\.html\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.xsd\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.ant\\'" . nxml-mode))

;;; tramp
(setq tramp-auto-save-directory "/tmp")

;;; powershell
(rc/require 'powershell)
(add-to-list 'auto-mode-alist '("\\.ps1\\'" . powershell-mode))
(add-to-list 'auto-mode-alist '("\\.psm1\\'" . powershell-mode))

;;; eldoc mode
(defun rc/turn-on-eldoc-mode ()
  (interactive)
  (eldoc-mode 1))

(add-hook 'emacs-lisp-mode-hook 'rc/turn-on-eldoc-mode)

;;; Company
(rc/require 'company)
(require 'company)
(global-company-mode)

(add-hook 'tuareg-mode-hook
          (lambda ()
            (interactive)
            (company-mode 0)))

;;; Typescript
(rc/require 'typescript-mode)
(add-to-list 'auto-mode-alist '("\\.mts\\'" . typescript-mode))

;;; eglot — LSP client (replaces tide/flycheck for TypeScript)
;;; requires: npm install -g typescript-language-server typescript
(rc/require 'eglot)
(with-eval-after-load 'eglot
  (setq eglot-ignored-server-capabilities
        '(:documentHighlightProvider :documentOnTypeFormattingProvider))
  (setq eglot-events-buffer-size 0)
  (add-to-list 'eglot-server-programs
               '((typescript-mode) . ("typescript-language-server" "--stdio")))
  ;; disable flymake when eglot is active (we don't use flycheck anymore)
  (add-hook 'eglot-managed-mode-hook (lambda () (flymake-mode -1))))

(add-hook 'typescript-mode-hook #'eglot-ensure)

;;; editorconfig
(rc/require 'editorconfig)
(editorconfig-mode 1)

;;; rainbow-mode — colorize color strings like #ff0000
(rc/require 'rainbow-mode)

;;; deadgrep — fast ripgrep search UI
(rc/require 'deadgrep)

(defvar rc/deadgrep-global-path default-directory)
(defun rc/deadgrep-project-root-function ()
  rc/deadgrep-global-path)

(defun rc/deadgrep-vanilla ()
  "Run deadgrep with no extra config flags."
  (interactive)
  (setq deadgrep-extra-arguments '("--no-config"))
  (call-interactively 'deadgrep))

(defun rc/deadgrep-u ()
  "Run deadgrep ignoring .gitignore (-u)."
  (interactive)
  (setq deadgrep-extra-arguments '("--no-config" "-u"))
  (call-interactively 'deadgrep))

(defun rc/deadgrep-global ()
  "Run deadgrep from rc/deadgrep-global-path."
  (interactive)
  (let ((deadgrep-project-root-function #'rc/deadgrep-project-root-function))
    (call-interactively 'deadgrep)))

(global-set-key (kbd "<f5>") 'rc/deadgrep-vanilla)
(global-set-key (kbd "<f6>") 'rc/deadgrep-u)
(global-set-key (kbd "C-<f5>") 'rc/deadgrep-global)

;;; Proof general
(rc/require 'proof-general)
(add-hook 'coq-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-q C-n") 'proof-assert-until-point-interactive)))

;;; LaTeX mode
(add-hook 'tex-mode-hook
          (lambda ()
            (interactive)
            (add-to-list 'tex-verbatim-environments "code")))

(setq font-latex-fontify-sectioning 'color)

;;; Move Text
(rc/require 'move-text)
(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)

;;; Ebisp
(add-to-list 'auto-mode-alist '("\\.ebi\\'" . lisp-mode))

;;; Packages that don't require configuration
(rc/require
 'scala-mode
 'd-mode
 'yaml-mode
 'glsl-mode
 'tuareg
 'lua-mode
 'less-css-mode
 'graphviz-dot-mode
 'clojure-mode
 'cmake-mode
 'rust-mode
 'csharp-mode
 'nim-mode
 'jinja2-mode
 'markdown-mode
 'purescript-mode
 'nix-mode
 'dockerfile-mode
 'toml-mode
 'nginx-mode
 'kotlin-mode
 'go-mode
 'php-mode
 'racket-mode
 'qml-mode
 'ag
 'elpy
 'typescript-mode
 'rfc-mode
 'sml-mode
 )

;;; Utility helpers (from valignatev/dotemacs)
(defvar IS-WINDOWS (eq system-type 'windows-nt))

(defun rc/project-root-or-default-dir ()
  "Return project root if in a project, otherwise default-directory."
  (if-let ((proj (project-current)))
      (project-root proj)
    default-directory))

(defun rc/edit-init-file ()
  "Open init file for editing."
  (interactive)
  (find-file user-init-file))

;; Determine OS-specific terminal emulator
(defvar rc/terminal
  (if IS-WINDOWS "powershell.exe" (getenv "TERMINAL")))
(defvar rc/terminal-args
  (if IS-WINDOWS "Start-Process PowerShell" nil))

(defun rc/terminal-in-project-root (arg)
  "Open $TERMINAL in project root. With ARG, open in current directory."
  (interactive "P")
  (let ((default-directory
          (if arg default-directory
            (rc/project-root-or-default-dir))))
    (if rc/terminal-args
        (start-process "terminal" nil rc/terminal rc/terminal-args)
      (start-process "terminal" nil rc/terminal))))

(global-set-key (kbd "C-x t") 'rc/terminal-in-project-root)

;;; Additional file-mode associations (from valignatev/dotemacs)
(add-to-list 'auto-mode-alist '("Pipfile\\'" . conf-toml-mode))
(add-to-list 'auto-mode-alist '("requirements.txt\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.styl\\'" . css-mode))
(add-to-list 'auto-mode-alist '("\\.env\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.env.local\\'" . conf-mode))

;;; astyle for simpc-mode
(defun astyle-buffer (&optional justify)
  (interactive)
  (let ((saved-line-number (line-number-at-pos)))
    (shell-command-on-region
     (point-min)
     (point-max)
     "astyle --style=kr"
     nil
     t)
    (goto-line saved-line-number)))

(add-hook 'simpc-mode-hook
          (lambda ()
            (interactive)
            (setq-local fill-paragraph-function 'astyle-buffer)))

;;; Compilation
(require 'compile)

(add-to-list 'compilation-error-regexp-alist
             '("\\([a-zA-Z0-9\\.]+\\)(\\([0-9]+\\)\\(,\\([0-9]+\\)\\)?) \\(Warning:\\)?"
               1 2 (4) (5)))

;; Colorize ANSI codes in compilation output
(ignore-errors
  (require 'ansi-color)
  (defun rc/colorize-compilation-buffer-ansi ()
    (when (eq major-mode 'compilation-mode)
      (ansi-color-apply-on-region compilation-filter-start (point-max))))
  (add-hook 'compilation-filter-hook 'rc/colorize-compilation-buffer-ansi))

;; Recompile helper respecting compile-run-command dir variable
(defun rc/recompile ()
  (interactive)
  (let ((default-directory (rc/project-root-or-default-dir)))
    (if (local-variable-p 'compile-run-command)
        (setq-local compile-command compile-run-command))
    (recompile)))

(global-set-key (kbd "<f7>") 'rc/recompile)

;;; Shadow rc (loaded last so it can override anything)
(load "~/.emacs.shadow/shadow-rc.el" t)

(load-file custom-file)
