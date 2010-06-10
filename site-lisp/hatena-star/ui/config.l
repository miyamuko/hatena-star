; -*- mode: lisp; package: hatena-star.ui -*-

;;; hatena-star/ui/config.l
;;
;; Copyright (c) 2008-2009 MIYAMUKO Katsuyuki.
;;
;; hatena-star is released under an MIT license.
;; See hatena-star/docs/MIT-LICENSE for full license.
;;

;;; Code:

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-star/ui/package")
  )

(in-package :hatena-star.ui)

(export '(*hatena-star-text-attribute-tag-name*

          *hatena-star-default-star-color*
          *hatena-star-default-star-color-red*
          *hatena-star-default-star-color-green*
          *hatena-star-default-star-color-blue*

          *hatena-star-default-star-char*
          *hatena-star-default-star-char-red*
          *hatena-star-default-star-char-green*
          *hatena-star-default-star-char-blue*

          *hatena-star-inner-count-min*
          ))

(defvar *hatena-star-text-attribute-tag-name*
  :hatena-star-tag)

(defvar *hatena-star-default-star-color*
  '(:foreground 11)) ;; :foreground 3 ‚Í‚Ü‚Ô‚µ‚·‚¬‚é
(defvar *hatena-star-default-star-color-red*
  '(:foreground 1))
(defvar *hatena-star-default-star-color-green*
  '(:foreground 2))
(defvar *hatena-star-default-star-color-blue*
  '(:foreground 4))

(defvar *hatena-star-default-star-char* #\š)
(defvar *hatena-star-default-star-char-red*
  *hatena-star-default-star-char*)
(defvar *hatena-star-default-star-char-green*
  *hatena-star-default-star-char*)
(defvar *hatena-star-default-star-char-blue*
  *hatena-star-default-star-char*)

(defvar *hatena-star-inner-count-min* 16)


(provide "hatena-star/ui/config")

;;; End
