(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/\\1" t)))
 '(backup-directory-alist '((".*" . "~/.emacs.d/backups/")))
 '(column-number-mode t)
 '(lsp-enable-symbol-highlighting nil)
 '(lsp-rust-analyzer-cargo-watch-command "clippy")
 '(lsp-rust-analyzer-diagnostics-disabled
   ["unresolved-macro-call" "unresolved-proc-macro" "unresolved-import" "type-mismatch" "mismatched-arg-count"])
 '(package-selected-packages
   '(dockerfile-mode lsp-ui company lsp-mode org-modern org json-mode yaml-mode simpleclip cargo flycheck-rust rust-mode flycheck))
 '(scroll-bar-mode nil)
 '(select-enable-clipboard nil)
 '(show-paren-mode t)
 '(text-mode-hook '(text-mode-hook-identify))
 '(tool-bar-mode nil)
 '(truncate-lines nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Put autosave files (ie #foo#) and backup files (ie foo~) in ~/.emacs.d/.
;; create the autosave dir if necessary, since emacs won't.
(make-directory "~/.emacs.d/autosaves/" t)

(setq-default indent-tabs-mode nil)

(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl
    (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

(require 'whitespace)
 (setq whitespace-style '(face empty tabs trailing))
 (global-whitespace-mode t)

(load-theme 'tango-dark t)

(electric-indent-mode 0)

(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; http://www.flycheck.org/manual/latest/index.html
(require 'flycheck)

;; turn on flychecking globally
(add-hook 'after-init-hook #'global-flycheck-mode)

(setq create-lockfiles nil)

(defun enable-minor-mode (my-pair)
  "Enable minor mode if filename match the regexp.  MY-PAIR is a cons cell (regexp . minor-mode)."
  (if (buffer-file-name)
      (if (string-match (car my-pair) buffer-file-name)
      (funcall (cdr my-pair)))))

(defun xml-pretty-print-region (begin end)
  "Pretty format XML markup in region. You need to have nxml-mode
http://www.emacswiki.org/cgi-bin/wiki/NxmlMode installed to do
this.  The function inserts linebreaks to separate tags that have
nothing but whitespace between them.  It then indents the markup
by using nxml's indentation rules."
  (interactive "r")
  (save-excursion
      (nxml-mode)
      (goto-char begin)
      (while (search-forward-regexp "\>[ \\t]*\<" nil t)
        (backward-char) (insert "\n"))
      (indent-region begin end))
    (message "Ah, much better!"))

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

(setq rust-format-on-save t)

(with-eval-after-load 'rust-mode
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(add-hook 'rust-mode-hook (lambda () (setq indent-tabs-mode nil)))
(add-hook 'rust-mode-hook 'cargo-minor-mode)

(setq mac-command-modifier 'control)
(setq mac-option-modifier 'meta)
(setq mac-control-modifier 'super)

(require 'simpleclip)
(simpleclip-mode 1)

(unless (display-graphic-p)
   (menu-bar-mode -1))

(add-hook 'json-mode-hook
          (lambda ()
            (make-local-variable 'js-indent-level)
            (setq js-indent-level 4)))

(setq inhibit-startup-screen t)

(setq initial-major-mode 'text-mode)

(setq initial-scratch-message nil)

(setq lsp-rust-server 'rust-analyzer)
;; disable lsp headerline
(setq lsp-headerline-breadcrumb-enable nil)
;; disable lsp icons on modeline
(setq lsp-modeline-code-actions-enable nil)
(with-eval-after-load 'lsp-mode
  ;; symbol navigation
  (define-key lsp-mode-map (kbd "M-n") 'lsp-ui-find-next-reference)
  (define-key lsp-mode-map (kbd "M-p") 'lsp-ui-find-prev-reference)
  ;; disable automatic symbol highlighting
  (add-hook 'lsp-mode-hook #'lsp-toggle-symbol-highlight))

(add-hook 'rust-mode-hook #'lsp-deferred)

(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))
