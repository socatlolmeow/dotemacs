;;; custom-rc.el --- personal keybinds, LSP, buffer navigation -*- lexical-binding: t -*-

;;; ─── Richer syntax highlighting ─────────────────────────────────────────────

;; Apply every decoration level each mode supports
(setq font-lock-maximum-decoration t)

;; Highlight numbers in prog-modes (gruber-darker quartz color)
(defface rc/number-face
  '((t :foreground "#95a99f"))
  "Face for numeric literals.")

(defun rc/highlight-numbers ()
  "Add number literal highlighting to the current buffer."
  (font-lock-add-keywords
   nil
   '(("\\_<\\(0[xX][0-9a-fA-F]+\\|[0-9]+\\.?[0-9]*\\(?:[eE][+-]?[0-9]+\\)?\\)\\_>"
      1 'rc/number-face))
   'append))

(add-hook 'prog-mode-hook #'rc/highlight-numbers)

;; Highlight TODO/FIXME/NOTE/HACK in comments across all prog-modes
(defface rc/todo-face
  '((t :foreground "#ffdd33" :weight bold))
  "Face for TODO-style comment keywords.")

(defun rc/highlight-todos ()
  (font-lock-add-keywords
   nil
   '(("\\<\\(TODO\\|FIXME\\|HACK\\|NOTE\\|XXX\\)\\>" 1 'rc/todo-face prepend))
   'append))

(add-hook 'prog-mode-hook #'rc/highlight-todos)
(add-hook 'text-mode-hook #'rc/highlight-todos)

;;; ─── Electric pairs ──────────────────────────────────────────────────────────

(electric-pair-mode 1)

;;; ─── No bell ─────────────────────────────────────────────────────────────────

(setq ring-bell-function 'ignore)

;;; ─── Keybinds ────────────────────────────────────────────────────────────────

;; Use a minor mode so our bindings beat all major/minor mode keymaps.
;; Minor modes added last in the list win, and emulation-mode-map-alists
;; takes priority over everything except overriding-local-map.

(defun rc/kill-whole-line ()
  "Kill the entire current line including the newline."
  (interactive)
  (beginning-of-line)
  (kill-whole-line))

(defun rc/kill-buffer-and-window ()
  "Kill the current buffer. If more than one window is open, also close this window."
  (interactive)
  (kill-current-buffer)
  (when (not (one-window-p))
    (delete-window)))

(defvar rc/keys-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-d")       'rc/kill-whole-line)
    (define-key map (kbd "C-b")       'ido-switch-buffer)
    (define-key map (kbd "C-f")       'isearch-forward)
    (define-key map (kbd "C-c c")     'compile)
    (define-key map (kbd "M-q")       'rc/kill-buffer-and-window)
    (define-key map (kbd "M-<up>")    'windmove-up)
    (define-key map (kbd "M-<down>")  'windmove-down)
    (define-key map (kbd "M-<left>")  'windmove-left)
    (define-key map (kbd "M-<right>") 'windmove-right)
    map)
  "Keymap for rc/keys-minor-mode — overrides major/minor mode bindings.")

(define-minor-mode rc/keys-minor-mode
  "Minor mode to enforce personal keybindings."
  :init-value t
  :lighter ""
  :keymap rc/keys-minor-mode-map)

(rc/keys-minor-mode 1)

;; Make sure it survives minibuffer and other special buffers
(add-hook 'after-change-major-mode-hook
          (lambda () (rc/keys-minor-mode 1)))

;;; ─── LSP (eglot — built-in since Emacs 29) ──────────────────────────────────

;; eglot is built-in; just hook it up to the relevant major modes.
;; Make sure rust-analyzer and clangd are on your PATH.

(require 'eglot)

;; Rust — rust-analyzer
(add-hook 'rust-mode-hook 'eglot-ensure)

;; C/C++ — clangd
(add-hook 'c-mode-hook   'eglot-ensure)
(add-hook 'c++-mode-hook 'eglot-ensure)
(add-hook 'simpc-mode-hook 'eglot-ensure)

;; Python — pyright or pylsp (whichever is on PATH)
(add-hook 'python-mode-hook 'eglot-ensure)

;; Go — gopls
(add-hook 'go-mode-hook 'eglot-ensure)

;; TypeScript/JS — typescript-language-server
(add-hook 'typescript-mode-hook 'eglot-ensure)
(add-hook 'js-mode-hook          'eglot-ensure)

;; Haskell — haskell-language-server
(add-hook 'haskell-mode-hook 'eglot-ensure)

;; Nix — nil or nixd
(with-eval-after-load 'nix-mode
  (add-hook 'nix-mode-hook 'eglot-ensure))

;; Prefer clangd for C/C++ explicitly
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode simpc-mode) . ("clangd" "--background-index")))
  (add-to-list 'eglot-server-programs
               '(rust-mode . ("rust-analyzer"))))

;; Performance tweaks for eglot
(setq eglot-autoshutdown t          ; shut down LSP when last buffer closes
      eglot-ignored-server-capabilities
      '(:documentHighlightProvider) ; skip highlight spam
      eglot-sync-connect 1)

;;; ─── Completion (corfu — lightweight inline popup) ──────────────────────────

(rc/require 'corfu)
(require 'corfu)

(setq corfu-auto t
      corfu-auto-delay 0.0
      corfu-auto-prefix 1
      corfu-cycle t
      corfu-quit-no-match 'separator)

(global-corfu-mode 1)

;; Tab triggers completion in eglot-backed modes; falls back to indent otherwise.
(defun rc/tab-complete-or-indent ()
  "Trigger completion if eglot is active and point is after a non-space char,
otherwise indent the line."
  (interactive)
  (if (and (bound-and-true-p eglot--managed-mode)
           (> (point) (line-beginning-position))
           (not (looking-back "^[[:space:]]*" (line-beginning-position))))
      (completion-at-point)
    (indent-for-tab-command)))

(dolist (hook '(c-mode-hook
                c++-mode-hook
                simpc-mode-hook
                rust-mode-hook))
  (add-hook hook (lambda ()
                   (local-set-key (kbd "TAB") #'rc/tab-complete-or-indent))))

;;; ─── Flymake (used by eglot for diagnostics) ────────────────────────────────

;; Show errors in the minibuffer when point is on them
(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") 'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") 'flymake-goto-prev-error))
