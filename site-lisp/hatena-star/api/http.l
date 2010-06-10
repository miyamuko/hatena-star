;;;; -*- mode: lisp; package: hatena-star.api -*-
;;;;
;;;; File: hatena-star/api/http.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-star is released under an MIT license.
;;;;   See hatena-star/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-star/api/package")
  )

(in-package :hatena-star.api)

(defun hatena-star-http-headers ()
  `(:User-Agent ,(hatena-star-user-agent)))

(defun hatena-star-get-json (uri &key (filter 'identity) nomsg since callback future async)
  (hatena-star-get uri
                   :nomsg nomsg :since since
                   :callback callback :future future :async async
                   :key (make-json-bridge filter)))

(defun hatena-star-get (uri &key key nomsg since callback future async)
  (cond (future
         (xhr-get-future uri :since since :key key :nomsg nomsg
                         :headers (hatena-star-http-headers)))
        (async
         (xhr-get-async uri :since since :key key :nomsg nomsg :oncomplete callback
                        :headers (hatena-star-http-headers)))
        (t
         (xhr-get uri :since since :key key :nomsg nomsg
                  :headers (hatena-star-http-headers)))
        ))


(defun make-json-bridge (filter)
  #'(lambda (res)
      (let ((status (xhr-status res))
            (body (xhr-response-text res)))
        (if (<= 200 status 299)
            (funcall filter (json-decode body :strict nil))
          (progn
            (trace-output (concat "JSON request failed (~A)~%"
                                  "~A~%"
                                  "----~%"
                                  "~A~&"
                                  "----~%")
                          status
                          (xhr-requested-uri res)
                          body)
            nil)))))


(provide "hatena-star/api/http")

;;;; End
