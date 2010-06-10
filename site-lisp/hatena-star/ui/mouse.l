; -*- mode: lisp; package: hatena-star.ui -*-

;;; hatena-star/ui/mouse.l
;;
;; Copyright (c) 2009 MIYAMUKO Katsuyuki.
;;
;; hatena-star is released under an MIT license.
;; See hatena-star/docs/MIT-LICENSE for full license.
;;

;;; Code:

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-star/ui/package")
  (require "hatena-star/ui/config")
  (require "hatena-star/ui/attributes")
  )

(in-package :hatena-star.ui)

(export '(hatena-star-mouse-lookup
          ))

(defparameter *hatena-star-last-range-begin* nil)
(defparameter *hatena-star-last-range-end* nil)

(defun char-numeric-p (char)
  (and (alphanumericp char)
       (not (alpha-char-p char))))

(defun skip-number (forward)
  (funcall
   (if forward #'skip-chars-forward #'skip-chars-backward)
   "0123456789"))

(defun skip-number-forward ()
  (skip-number t))

(defun skip-number-backward ()
  (skip-number nil))

(defun hatena-star-mouse-lookup ()
  (interactive)
  (continue-pre-selection)
  (with-selected-window
    (set-window *last-mouse-window*)
    (save-excursion
      (goto-last-mouse-point)
      (cond ((eolp)
             (setq *hatena-star-last-range-begin* nil))
            ;; カーソルがポップアップ対象内
            ((and *hatena-star-last-range-begin*
                  (<= *hatena-star-last-range-begin* (point))
                  (< (point) *hatena-star-last-range-end*))
             (continue-popup))
            ;; カーソルが ★数字★ の上
            ((char-numeric-p (following-char))
             (let ((beg (progn (skip-number-backward) (point)))
                   (end (progn (skip-number-forward) (point))))
               (setq *hatena-star-last-range-begin* beg)
               (setq *hatena-star-last-range-end* end)
               (multiple-value-bind (start end color stars uri)
                   (lookup-star-values (point))
                 (when stars
                   ;; 省略した星しか取得していない場合は、全部取得して text-attribute を更新
                   (when (hatena-star-stars-inner-count-p stars)
                     (long-operation
                       (let ((e (hatena-star-get-entry uri)))
                         (update-star-attribute (point) color e)
                         (setf stars (hatena-star-entry-stars-by-color e color)))))
                   (let ((popups (mapcar #'(lambda (star)
                                             (let ((n (hatena-star-star-name star))
                                                   (s (hatena-star-make-stars-string
                                                       (hatena-star-star-count star)))
                                                   (q (hatena-star-star-quote star)))
                                               (if q
                                                   (format nil "~A ~A ~S" n s q)
                                                 (format nil "~A ~A" n s))))
                                         (hatena-star-stars-by-user
                                          (cdr (butlast stars))))))
                     (popup-string (format nil "~{~A~%~}" popups) (point)))))
               ))
            ;; カーソルが ★ の上
            (t
             (let ((end (point))
                   (beg (1+ (point))))
               (setq *hatena-star-last-range-begin* beg)
               (setq *hatena-star-last-range-end* end)
               (multiple-value-bind (start end color stars uri)
                   (lookup-star-values (point))
                 (when stars
                   (let ((star (if (char-numeric-p (preceding-char))
                                   (car (last stars))
                                 (nth (- (point) start) stars))))
                     (when star
                       (let ((name (hatena-star-star-name star))
                             (quote (hatena-star-star-quote star)))
                         (let ((popup (if quote
                                          (format nil "~A~%----------~%\"~A\"" name quote)
                                        name)))
                           (popup-string popup (point))))))))
               ))))))


(provide "hatena-star/ui/mouse")

;;; End
