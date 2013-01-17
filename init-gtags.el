;; Maintainer: Yudi Shi
;; Time-stamp: <2012-10-21 19:53:59 ryan>

;; here is global gtags settings.
(require 'gtags)

(define-key gtags-mode-map (kbd "C-c g f") 'gtags-find-tag)
(define-key gtags-mode-map (kbd "C-c g l") 'gtags-pop-stack)
(define-key gtags-select-mode-map (kbd "g") 'gtags-select-tag)
(define-key gtags-select-mode-map (kbd "SPC") 'gtags-select-tag)
(define-key gtags-select-mode-map (kbd "RET") 'gtags-select-tag)
(define-key gtags-select-mode-map (kbd "l") 'gtags-pop-stack)
(define-key gtags-select-mode-map (kbd "q")
  (lambda () (interactive) (kill-buffer)))

(setq gtags-select-mode-hook nil)
(add-hook 'gtags-select-mode-hook
          '(lambda ()
             (setq hl-line-face 'hl-line)
             (hl-line-mode 1)
             (local-set-key (kbd "g") 'gtags-select-tag)
             ))

;; @see http://emacs-fu.blogspot.com.au/2008/01/navigating-through-source-code-using.html
(defun djcb-gtags-create-or-update ()
  "create or update the gnu global tag file"
  (interactive)
  (if (not (= 0 (call-process "global" nil nil nil " -p"))) ; tagfile doesn't exist?
      (let ((olddir default-directory)
            (topdir (read-directory-name
                     "gtags: top of source tree:" default-directory)))
        (cd topdir)
        (shell-command "gtags && echo 'created tagfile'")
        (cd olddir)) ; restore
    ;;  tagfile already exists; update it
    (shell-command "global -u && echo 'updated tagfile'"))
  )

(defun add-gtagslibpath (libdir &optional del)
  "add external library directory to environment variable GTAGSLIBPATH.\ngtags will can that directory if needed.\nC-u M-x add-gtagslibpath will remove the directory from GTAGSLIBPATH."
  (interactive "DDirectory containing GTAGS:\nP")
  (let (sl)
  (if (not (file-exists-p (concat (file-name-as-directory libdir) "GTAGS")))
      ;; create tags
      (let ((olddir default-directory))
        (cd libdir)
        (shell-command "gtags && echo 'created tagfile'")
        (cd olddir)
        )
    )
  (setq libdir (directory-file-name libdir)) ;remove final slash
  (setq sl (split-string (if (getenv "GTAGSLIBPATH") (getenv "GTAGSLIBPATH") "")  ":" t))
  (if del (setq sl (delete libdir sl)) (add-to-list 'sl libdir t))
  (setenv "GTAGSLIBPATH" (mapconcat 'identity sl ":")))
  )

(defun print-gtagslibpath ()
  "print the GTAGSLIBPATH (for debug purpose)"
  (interactive)
  (message "GTAGSLIBPATH=%s" (getenv "GTAGSLIBPATH"))
  )

(provide 'init-gtags)