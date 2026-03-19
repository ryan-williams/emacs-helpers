;;; init.el --- Modern Emacs config -*- lexical-binding: t; -*-

;; ============================================================================
;; Package management
;; ============================================================================
(require 'package)
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

;; use-package is built into Emacs 29+
(require 'use-package)
(setq use-package-always-ensure t)

;; ============================================================================
;; Sane defaults
;; ============================================================================
(setq inhibit-startup-screen t
      initial-scratch-message nil
      ring-bell-function 'ignore
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Load custom file if it exists (keeps init.el clean)
(when (file-exists-p custom-file)
  (load custom-file))

(setq-default indent-tabs-mode nil
              tab-width 2
              fill-column 80
              truncate-lines t)

(setq column-number-mode t
      revert-without-query '(".*")
      scroll-conservatively 101
      scroll-margin 3)

;; y/n instead of yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; Remember recent files
(recentf-mode 1)
(setq recentf-max-saved-items 100)

;; Remember cursor position
(save-place-mode 1)

;; Auto-refresh buffers when files change on disk
(global-auto-revert-mode 1)

;; Show matching parens
(show-paren-mode 1)

;; Line numbers in programming modes
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Highlight current line
(global-hl-line-mode 1)

;; Delete selection when typing
(delete-selection-mode 1)

;; UTF-8 everywhere
(set-default-coding-systems 'utf-8)

;; Mac: command = meta, option = super (for special chars)
(when (eq system-type 'darwin)
  (setq mac-command-modifier 'meta
        mac-option-modifier 'super))

;; PATH from shell
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :config
  (exec-path-from-shell-initialize))

;; Enable useful commands
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;; ============================================================================
;; Theme
;; ============================================================================
(use-package doom-themes
  :config
  (load-theme 'doom-one t)
  (doom-themes-org-config))

;; Mode line
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 28)
  (doom-modeline-buffer-encoding nil))

;; ============================================================================
;; Navigation & completion
;; ============================================================================

;; Vertico: vertical completion UI
(use-package vertico
  :init (vertico-mode)
  :custom
  (vertico-count 15)
  (vertico-cycle t))

;; Orderless: flexible matching
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; Marginalia: annotations in minibuffer
(use-package marginalia
  :init (marginalia-mode))

;; Consult: enhanced search commands
(use-package consult
  :bind (("C-s"   . consult-line)        ; search in buffer
         ("C-x b" . consult-buffer)      ; switch buffer
         ("M-g g" . consult-goto-line)
         ("M-s r" . consult-ripgrep)     ; ripgrep across files
         ("M-s f" . consult-find)))      ; find files

;; Which-key: show available keybindings
(use-package which-key
  :init (which-key-mode)
  :custom
  (which-key-idle-delay 0.5))

;; ============================================================================
;; Magit
;; ============================================================================
(use-package magit
  :bind (("C-x g" . magit-status)       ; main entry point
         ("C-x M-g" . magit-dispatch))   ; quick actions
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (magit-diff-refine-hunk 'all))         ; show word-level diffs

;; Show git changes in the gutter
(use-package diff-hl
  :hook ((magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :init (global-diff-hl-mode))

;; ============================================================================
;; Terminal / Shell (vterm)
;; ============================================================================
(use-package vterm
  :bind (("C-c t" . vterm)              ; open terminal
         ("C-c T" . vterm-other-window)) ; terminal in split
  :custom
  (vterm-max-scrollback 10000)
  (vterm-shell "/opt/homebrew/bin/bash"))

;; Multiple vterm buffers
(use-package multi-vterm
  :bind (("C-c n" . multi-vterm)         ; new terminal
         ("C-c p" . multi-vterm-prev)    ; previous terminal
         ("C-c ]" . multi-vterm-next)))  ; next terminal

;; ============================================================================
;; Window management
;; ============================================================================

;; Quickly switch windows with ace-window
(use-package ace-window
  :bind ("M-o" . ace-window)
  :custom
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

;; Winner mode: undo/redo window layouts with C-c left/right
(winner-mode 1)

;; ============================================================================
;; Project management
;; ============================================================================
(use-package project
  :ensure nil  ; built-in
  :bind-keymap ("C-c p" . project-prefix-map))

;; ============================================================================
;; Programming
;; ============================================================================

;; Tree-sitter for better syntax highlighting (Emacs 29+)
(setq treesit-language-source-alist
      '((python "https://github.com/tree-sitter/tree-sitter-python")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript"
                    "master" "typescript/src")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript"
             "master" "tsx/src")
        (json "https://github.com/tree-sitter/tree-sitter-json")
        (yaml "https://github.com/tree-sitter/tree-sitter-yaml")
        (bash "https://github.com/tree-sitter/tree-sitter-bash")
        (toml "https://github.com/tree-sitter/tree-sitter-toml")
        (markdown "https://github.com/tree-sitter-grammars/tree-sitter-markdown"
                  "split_parser" "tree-sitter-markdown/src")
        (lua "https://github.com/tree-sitter-grammars/tree-sitter-lua")
        (rust "https://github.com/tree-sitter/tree-sitter-rust")))

;; Remap modes to tree-sitter versions when available
(setq major-mode-remap-alist
      '((python-mode    . python-ts-mode)
        (js-mode        . js-ts-mode)
        (typescript-mode . typescript-ts-mode)
        (json-mode      . json-ts-mode)
        (yaml-mode      . yaml-ts-mode)
        (bash-mode      . bash-ts-mode)
        (rust-mode      . rust-ts-mode)))

;; Markdown
(use-package markdown-mode
  :mode ("\\.md\\'" . markdown-mode))

;; YAML
(use-package yaml-mode)

;; Company: in-buffer completion
(use-package company
  :hook (after-init . global-company-mode)
  :custom
  (company-idle-delay 0.2)
  (company-minimum-prefix-length 2))

;; ============================================================================
;; Org mode
;; ============================================================================
(use-package org
  :ensure nil  ; built-in
  :custom
  (org-startup-indented t)
  (org-hide-leading-stars t)
  (org-return-follows-link t)
  (org-confirm-babel-evaluate nil)
  (org-src-tab-acts-natively t)
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (shell . t))))

;; ============================================================================
;; Custom keybindings (preserved from old config + new)
;; ============================================================================

;; Buffer management
(global-set-key (kbd "C-b") 'switch-to-buffer)
(global-set-key (kbd "C-q") 'kill-current-buffer)
(global-set-key (kbd "C-l") 'goto-line)

;; Comment/uncomment
(global-set-key (kbd "C-c c") 'comment-region)
(global-set-key (kbd "C-c u") 'uncomment-region)

;; Revert
(global-set-key (kbd "<f5>") 'revert-buffer)

;; Keyboard macros
(global-set-key (kbd "C-(") 'kmacro-start-macro)
(global-set-key (kbd "C-)") 'kmacro-end-macro)
(global-set-key (kbd "C-=") 'kmacro-end-and-call-macro)

;; Search/replace
(global-set-key (kbd "M-S") 'query-replace)

;; ============================================================================
;; Git diff/log paging (replaces `less` for git output)
;; ============================================================================

;; Use Emacs as git pager (optional, enable in shell with:
;;   export GIT_PAGER="emacsclient -nw"
;; after starting the emacs server with M-x server-start)

;; Start Emacs server for emacsclient usage
(require 'server)
(unless (server-running-p)
  (server-start))

(provide 'init)
;;; init.el ends here
