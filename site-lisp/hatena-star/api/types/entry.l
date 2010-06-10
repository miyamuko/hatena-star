;;;; -*- mode: lisp; package: hatena-star.api -*-
;;;;
;;;; File: hatena-star/api/types/entry.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008-2009 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-star is released under an MIT license.
;;;;   See hatena-star/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-star/api/package")
  (require "hatena-star/api/util")
  (require "hatena-star/api/types/bool")
  (require "hatena-star/api/types/star")
  (require "hatena-star/api/types/comment")
  )

(in-package :hatena-star.api)

(export '(hatena-star-entry-p
          hatena-star-entry-can-comment-p
          hatena-star-entry-uri
          hatena-star-entry-stars
          hatena-star-entry-stars-by-color
          hatena-star-entry-colored-stars
          hatena-star-entry-comments
          ))

;;;; sample
;;
;; (("entries"
;;   (("stars"
;;     (("count" . "") ("quote" . "") ("name" . "foo1"))
;;     (("count" . "") ("quote" . "") ("name" . "foo2"))
;;     (("count" . "") ("quote" . "") ("name" . "foo3"))
;;     (("count" . "") ("quote" . "") ("name" . "foo4")))
;;    ("can_comment" . 0)
;;    ("colored_stars"
;;     (("stars"
;;       (("count" . "") ("quote" . "") ("name" . "foo4")))
;;      ("color" . "blue"))
;;     (("stars"
;;       (("count" . "") ("quote" . "") ("name" . "foo6"))
;;       (("count" . "") ("quote" . "") ("name" . "foo7")))
;;      ("color" . "red"))
;;     (("stars"
;;       (("count" . "") ("quote" . "") ("name" . "foo8"))
;;       (("count" . "") ("quote" . "") ("name" . "foo9")))
;;      ("color" . "green")))
;;    ("uri" . "http://d.hatena.ne.jp/hatenadiary/20090331/1238500999")))
;;  ("can_comment" . 0))

(defstruct hatena-star-entry
  uri
  can-comment-p
  sealed-normal-stars
  sealed-colored-stars
  sealed-comments
  )

(defun hatena-star-entry-stars (x)
  (colored-stars->stars (hatena-star-entry-colored-stars x)))

(defun hatena-star-entry-stars-by-color (x color)
  (case color
    (:normal
     (release (hatena-star-entry-sealed-normal-stars x)))
    (t
     (cdr (assoc color (release (hatena-star-entry-sealed-colored-stars x)))))
    ))

(defun hatena-star-entry-colored-stars (x)
  (append1 (release (hatena-star-entry-sealed-colored-stars x))
           (cons :normal (release (hatena-star-entry-sealed-normal-stars x)))))

(defun colored-stars->stars (colored-stars)
  (apply #'append (mapcar #'cdr colored-stars)))

(defun hatena-star-entry-comments (x)
  (release (hatena-star-entry-sealed-comments x)))


(defun entry-json->lisp-value (json)
  (make-hatena-star-entry
   :uri ($ json "uri")
   :can-comment-p (can-comment->bool json)
   :sealed-normal-stars (seal (stars-json->lisp-value ($ json "stars")))
   :sealed-colored-stars (seal (colored-stars-json->lisp-value ($ json "colored_stars")))
   :sealed-comments (seal (comments-json->lisp-value ($ json "comments")))
   ))


(defun entries1/rks-json->lisp-values (json)
  (entries/rks-json->lisp-values json t))

(defun entries/rks-json->lisp-values (json &optional one)
  (values
   (entries-json->lisp-value json one)
   ($ json "rks")
   ;; can_comment はいるの？
   ;; HatenaStar.js では各エントリの can_comment が undefined のときにこの値を使っているけど
   ;; can_comment が undefined になる場合ってなに？
   ;; とりあえず無視。
   ))

(defun entries1-json->lisp-value (json)
  (entries-json->lisp-value json t))

(defun entries-json->lisp-value (json &optional one)
  (let ((entries (mapcar #'entry-json->lisp-value ($ json "entries"))))
    (if one (car entries) entries)))


(provide "hatena-star/api/types/entry")

;;;; End
