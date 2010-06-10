; -*- mode: lisp; package: hatena-star.ui -*-

;;; hatena-star/ui/renderer.l
;;
;; Copyright (c) 2008-2009 MIYAMUKO Katsuyuki.
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

(export '(hatena-star-stars-write
          hatena-star-stars-insert
          hatena-star-stars-to-string
          hatena-star-make-stars-string
          ))

(defparameter *default-star-color-alist*
  `((:red    . ,*hatena-star-default-star-color-red*)
    (:blue   . ,*hatena-star-default-star-color-blue*)
    (:green  . ,*hatena-star-default-star-color-green*)
    (:normal . ,*hatena-star-default-star-color*)
    ))

(defparameter *default-star-char-alist*
  `((:red    . ,*hatena-star-default-star-char-red*)
    (:blue   . ,*hatena-star-default-star-char-blue*)
    (:green  . ,*hatena-star-default-star-char-green*)
    (:normal . ,*hatena-star-default-star-char*)
    ))


(defun color-name->foreground (color-name quick-config)
  (if (and (consp quick-config) (every #'atom quick-config))
      quick-config
    (or (cdr (assoc color-name quick-config))
        (cdr (assoc color-name *default-star-color-alist*))
        *hatena-star-default-star-color*)))

(defun color-name->star-char (color-name quick-config)
  (if (characterp quick-config)
      quick-config
    (or (cdr (assoc color-name quick-config))
        (cdr (assoc color-name *default-star-char-alist*))
        *hatena-star-default-star-char*)))


(defmacro with-selected-buffer (buffer &body body)
  (let ((org (gensym)))
    `(if (eq ,buffer (selected-buffer))
         (progn ,@body)
       (let ((,org (selected-buffer)))
         (unwind-protect
             (with-set-buffer
               (set-buffer ,buffer)
               (progn ,@body))
           (set-buffer ,org))))))
(setf (get 'with-selected-buffer 'ed::lisp-indent-hook) 'with-selected-window)

(defmacro wrap-text-attribute ((pointer tag color) &body body)
  (let ((from (gensym)))
    `(let ((,from ,pointer))
       (progn ,@body)
       (when (or ,tag ,color)
         (apply 'set-text-attribute ,from ,pointer ,tag ,color)))))
(setf (get 'wrap-text-attribute 'ed::lisp-indent-hook) 'let)


(defun render-colored-star (entry-or-stars &key star-char color
                                           buffer buffer-pointer renderer)
  (if (and buffer color)
      (with-selected-buffer buffer
        (dolist (color/stars (to-colored-star entry-or-stars))
          (let ((color-name (car color/stars))
                (stars (cdr color/stars)))
            (let ((star-str (hatena-star-stars-to-string
                             stars :star-char (color-name->star-char color-name star-char))))
              (wrap-text-attribute ((funcall buffer-pointer)
                                    (make-tag-info color/stars entry-or-stars)
                                    (color-name->foreground color-name color))
                (funcall renderer star-str))))))
    (let ((star-str (hatena-star-stars-to-string
                     entry-or-stars :star-char (color-name->star-char :normal star-char))))
      (funcall renderer star-str))))

(defun hatena-star-stars-write (entry-or-stars &key
                                               (star-char *default-star-char-alist*)
                                               (color *default-star-color-alist*)
                                               (stream t) )
  (when (eq stream t)
    (setf stream *standard-output*))
  (check-type stream stream)
  (render-colored-star entry-or-stars
                       :star-char star-char
                       :color color
                       :buffer (if (buffer-stream-p stream)
                                   (buffer-stream-buffer stream)
                                 nil)
                       :buffer-pointer #'(lambda () (buffer-stream-point stream))
                       :renderer #'(lambda (star-str) (format stream star-str))))

(defun hatena-star-stars-insert (entry-or-stars &key
                                                (star-char *default-star-char-alist*)
                                                (color *default-star-color-alist*)
                                                (buffer (selected-buffer)))
  (check-type buffer buffer)
  (render-colored-star entry-or-stars
                       :star-char star-char
                       :color color
                       :buffer buffer
                       :buffer-pointer #'point
                       :renderer #'insert))

(defun hatena-star-stars-to-string (entry-or-stars &key star-char)
  (let ((star-char (or star-char *hatena-star-default-star-char*))
        (n (hatena-star-stars-count entry-or-stars)))
    (check-type star-char character)
    (if (or (hatena-star-stars-inner-count-p entry-or-stars)
            (<= *hatena-star-inner-count-min* n))
        (multiple-value-bind (first count last)
            (hatena-star-stars-inner-count-values entry-or-stars)
          (format nil "~A~D~A"
                  (if first star-char "")
                  count
                  (if last star-char "")))
      (make-star n star-char))))

(defun hatena-star-make-stars-string (count &key star-char inner (inner-min *hatena-star-inner-count-min*))
  (let ((star-char (or star-char *hatena-star-default-star-char*)))
    (check-type star-char character)
    (if (and (< 2 count) (or inner (<= inner-min count)))
        (format nil "~A~D~A" star-char (- count 2) star-char)
      (make-star count star-char))))

(defun make-star (count star-char)
  (make-sequence 'string count :initial-element star-char))

(defun to-colored-star (entry-or-stars)
  (cond ((hatena-star-entry-p entry-or-stars)
         (hatena-star-entry-colored-stars entry-or-stars))
        ((hatena-star-colored-stars-p entry-or-stars)
         entry-or-stars)
        ((hatena-star-stars-p entry-or-stars)
         (acons :normal entry-or-stars nil))
        (t
         (type-error entry-or-stars '(or hatena-star-entry list)))))


(provide "hatena-star/ui/renderer")

;;; End
