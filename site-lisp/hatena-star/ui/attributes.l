; -*- mode: lisp; package: hatena-star.ui -*-

;;; hatena-star/ui/attributes.l
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
  )

(in-package :hatena-star.ui)

(export '(hatena-star-list-attributes
          hatena-star-find-attribute
          ))

;; text-attribute アクセッサ
;; (start end (tag-name colored-stars uri) color...)
(defun attr-start (attr) (car attr))
(defun attr-end (attr) (cadr attr))
(defun attr-tag (attr) (caddr attr))
(defun attr-color (attr) (cdddr attr))
(defun attr-tag-name (attr) (car (attr-tag attr)))
(defun attr-tag-star (attr) (cadr (attr-tag attr)))
(defun attr-tag-star-color (attr) (car (attr-tag-star attr)))
(defun attr-tag-star-stars (attr) (cdr (attr-tag-star attr)))
(defun attr-tag-uri (attr) (caddr (attr-tag attr)))


(defun make-tag-info (color/stars entry-or-stars)
  (list *hatena-star-text-attribute-tag-name*
        color/stars
        (if (hatena-star-entry-p entry-or-stars)
            (hatena-star-entry-uri entry-or-stars)
          nil)))

(defun update-star-attribute (point color entry-or-stars)
  (let ((attr (lookup-star-attribute point)))
    (apply #'set-text-attribute
           (attr-start attr) (attr-end attr)
           (make-tag-info (cons color (hatena-star-entry-stars-by-color entry-or-stars color))
                          entry-or-stars)
           (attr-color attr))))

(defun lookup-star-values (point)
  (let ((attr (lookup-star-attribute point)))
    (values (attr-start attr)
            (attr-end attr)
            (attr-tag-star-color attr)
            (attr-tag-star-stars attr)
            (attr-tag-uri attr)
            )))

(defun lookup-star-attribute (point)
  (multiple-value-bind (start end)
      (save-excursion
        (goto-char point)
        (values (progn (goto-bol) (point))
                (progn (goto-eol) (point))))
    (find-if #'(lambda (attr)
                 (and (<= (attr-start attr) point)
                      (< point (attr-end attr))))
             (list-star-attributes start end))))

(defun list-star-attributes (&optional start end)
  (remove-if #'(lambda (attr)
                 (not (eq (attr-tag-name attr)
                          *hatena-star-text-attribute-tag-name* )))
             (list-text-attributes start end)))


(provide "hatena-star/ui/attributes")

;;; End
