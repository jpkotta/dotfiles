;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NOTES

; needs emacs-goodies-el package

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GENERAL
 
; set user and hostname
(setq user-name (getenv "USER"))
(setq system-name (getenv "HOSTNAME"))

; frame title (window title)
; user@host: buffer
(setq frame-title-format
      '(multiple-frames "%b" ("" user-name "@" system-name ": " mode-line-buffer-identification " ("buffer-file-truename")")))

; i store my extra elisps in ~/.emacs.d
(pushnew (expand-file-name "~/.emacs.d") load-path :test 'equal)
(pushnew (expand-file-name "~/.xemacs") load-path :test 'equal)

; debian seems to store some auxillary elisp files here
(setq load-path (append load-path
(list
 "/usr/share/emacs/site-lisp"
 "/usr/share/emacs/21.4/lisp"
 "/usr/share/emacs/site-lisp/emacs-goodies-el")))

; enable downcasing a region
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

(require 'color-theme)

(load "cua-mode-1.3-xemacs.el")
(CUA-mode t)

; no sound or beeps
(setq bell-volume 0)
(setq sound-alist nil)

; start server
;(gnuserv-start)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; comint-mode
; used for interactive shells

(add-hook 'comint-mode-hook 
          (lambda ()
            (define-key comint-mode-map (kbd "<up>") 'comint-previous-matching-input-from-input)
            (define-key comint-mode-map (kbd "<down>") 'comint-next-matching-input-from-input)
            )
          )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PERL

(add-hook 'cperl-mode-hook
	  (lambda ()
	    (cperl-set-style "BSD")
	    )
	  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; C

; gdb
;(defun gdb-mode-hook ()
;  (local-set-key (kbd "<up>") 'comint-previous-matching-input-from-input)
;  (local-set-key (kbd "<down>") 'comint-next-matching-input-from-input)
;  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OCTAVE

; open .m files in octave mode (i can't believe there isn't a matlab mode)
(setq auto-mode-alist (cons '("\\.m\\'" . octave-mode) auto-mode-alist))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FVWM

; fvwm config file major mode
(load "fvwm-mode")
; this is slow, currently
(setq fvwm-preload-completions nil)

; fvwm major mode
(setq auto-mode-alist
       (cons '("FvwmApplet-" . fvwm-mode)
        (cons '("FvwmScript-" . fvwm-mode)
         (cons '(".fvwm" . fvwm-mode)
      auto-mode-alist))))

; fvwm indent function
(defun fvwm-indent-line ()
  (tab-to-tab-stop))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MEDIAWIKI MODE

; needs longlines.el
(autoload 'wikipedia-mode "wikipedia-mode.el"
  "Major mode for editing documents in Wikipedia markup." t)

(add-to-list 'auto-mode-alist 
   '("\\.wiki\\'" . wikipedia-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PYTHON MODE

(require 'ipython)

(autoload 'python-mode "python-mode.el"
  "Major mode for editing Python source." t)

(add-to-list 'auto-mode-alist 
   '("\\.py\\'" . python-mode))

(add-hook 'py-shell-hook
          (lambda ()
            (local-set-key (kbd "<up>") 'comint-previous-matching-input-from-input)
            (local-set-key (kbd "<down>") 'comint-next-matching-input-from-input)
            )
          )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LaTeX (AUCTeX) MODE

(add-hook 'LaTeX-mode-hook
          (lambda ()
            (local-set-key (kbd "C-S-<Enter>") 'TeX-complete)
            (reftex-mode)
            (setq reftex-plugin-to-auctex t)
            (auto-fill-mode)
            )
          )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GNUGO

; use the i key to toggle between ascii and xpm modes
;(load "gnugo")				
;(eval-after-load "gnugo"
;  '(load-file "~/.emacs.d/gnugo/default-gnugo-xpms.el"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LINE NUMBERS

; line numbering
; needs setnu.el
;(load "setnu")

; toggle line numbering
(global-set-key (kbd "C-c l") 'setnu-mode)

; you can warp to a line with M-x goto-line RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MISCELLANEOUS KEYBINDINGS

; the best way to find the symbol for a key is to run C-h k <key>

; replace kill- functions with delete- functions
; I find it unintuitive to kill the text
; usually I want to replace it with killed text, not go to the kill ring
(defun delete-word (arg)
  "Delete characters forward until encountering the end of a word.
With argument, do this that many times."
  (interactive "p")
  (delete-region (point) (progn (forward-word arg) (point))))

(defun backward-delete-word (arg)
  "Delete characters backward until encountering the end of a word.
With argument, do this that many times."
  (interactive "p")
  (delete-word (- arg)))

(defun delete-line (&optional arg)
  "Delete the rest of the current line; if no nonblanks there, delete thru newline.
With prefix argument, delete that many lines from point.
Negative arguments delete lines backward.
With zero argument, deletes the text before point on the current line.

When calling from a program, nil means \"no arg\",
a number counts as a prefix arg.

To delete a whole line, when point is not at the beginning, type \
\\[beginning-of-line] \\[delete-line] \\[delete-line].

If `kill-whole-line' is non-nil, then this command deletes the whole line
including its terminating newline, when used at the beginning of a line
with no argument.  As a consequence, you can always delete a whole line
by typing \\[beginning-of-line] \\[delete-line].

If the buffer is read-only, Emacs will beep and refrain from deleting
the line."
  (interactive "P")
  (delete-region (point)
                 ;; It is better to move point to the other end of the kill
                 ;; before killing.  That way, in a read-only buffer, point
                 ;; moves across the text that is copied to the kill ring.
                 ;; The choice has no effect on undo now that undo records
                 ;; the value of point from before the command was run.
                 (progn
                   (if arg
                       (forward-visible-line (prefix-numeric-value arg))
                     (if (eobp)
                         (signal 'end-of-buffer nil))
                     (if (or (looking-at "[ \t]*$") (and kill-whole-line (bolp)))
                   (forward-visible-line 1)
                   (end-of-visible-line)))
                   (point))))

; toggle auto-fill-mode
(global-set-key (kbd "C-c q") 'auto-fill-mode)


;(global-set-key (kbd "C-k") 'delete-line)
(global-set-key (kbd "<C-backspace>") 'backward-delete-word)
(global-set-key (kbd "<C-delete>") 'delete-word)

; make C-y do what you expect in ISearch mode
(define-key isearch-mode-map (kbd "C-y") 'isearch-yank-kill)
; make C-v do what you expect in ISearch mode
(define-key isearch-mode-map (kbd "C-v") 'isearch-yank-kill)

; macro record/playback
; F3 == M-x e, S-F3 == set
(global-set-key (kbd "<f3>") 'call-last-kbd-macro)
(global-set-key (kbd "S-<f3>") 'toggle-kbd-macro-recording-on)

; up/downcase a region
(global-set-key (kbd "C-6") 'downcase-region)
(global-set-key (kbd "C-^") 'upcase-region)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FILL AND INDENT

; tab key only inserts spaces to the next tab stop
; C-i still runs the indentation macros
; tab characters can be inserted with C-q TAB
; see the wiki for TurnAllIndentationOff for a possibly better solution
; see indent-for-tab-command in emacs help
(setq jpk-tab-mode nil)
(defun jpk-turn-off-indent ()
  "Rebinds the TAB key to tab-to-tab-stop"
  (interactive)
  (local-set-key (kbd "<tab>") 'tab-to-tab-stop)
;  (local-set-key (kbd "RET") 'newline-and-indent)
  (setq jpk-tab-mode t)
  (message "Auto indent is now off"))
(defun jpk-turn-on-indent ()
  "Rebinds the TAB key to whatever the current mode wants it to be by default"
  (interactive)
;  (local-set-key (kbd "<tab>") 'find a function to set tab correctly)
;  (local-set-key (kbd "RET") 'newline)
  (setq jpk-tab-mode nil)
  (message "Auto indent is now on"))
(defun jpk-toggle-indent ()
  "Toggles jpk-tab-mode on and off.  Runs either jpk-turn-on-indent (off) or jpk-turn-off-indent (on)"
  (interactive)
  (if jpk-tab-mode
      (jpk-turn-on-indent)
    (jpk-turn-off-indent)))
(global-set-key (kbd "C-<tab>") 'jpk-toggle-indent)

; rigidly indent
; see EmacsWiki://MovingRegionHorizontally
(defun jpk-move-region (beg en dir)
    (indent-rigidly beg en dir)
    ;; this line is very important. makes the region mark sticky
    (setq deactivate-mark nil)
    (push-mark beg t t))
(defun jpk-push-region (beg en)
    (interactive "r")
    (jpk-move-region beg en 1))
(defun jpk-pull-region (beg en)
    (interactive "r")
    (jpk-move-region beg en -1))
(defun jpk-push-region-four (beg en)
    (interactive "r")
    (jpk-move-region beg en 4))
(defun jpk-pull-region-four (beg en)
    (interactive "r")
    (jpk-move-region beg en -4))
(global-set-key (kbd "C-9") 'jpk-pull-region)
(global-set-key (kbd "C-0") 'jpk-push-region)
(global-set-key (kbd "C-(") 'jpk-pull-region-four)
(global-set-key (kbd "C-)") 'jpk-push-region-four)

;;; Stefan Monnier <foo at acm.org>. It is the opposite of fill-paragraph       
(defun unfill-paragraph ()
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))

(global-set-key (kbd "M-Q") 'unfill-paragraph)

; make long lines wrap, but without inserting real newlines
(autoload 'longlines-mode
  "longlines.el"
  "Minor mode for automatically wrapping long lines." t)

; turn long lines mode on and off
(global-set-key (kbd "C-c w") 'longlines-mode)