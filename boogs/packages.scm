(define-module (boogs packages)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:select (gpl3+))
  #:use-module (gnu packages gcc)
  #:use-module (srfi srfi-1))

(define-public gcc-unhidden
  (package
    (inherit gcc)
    (name "gcc-unhidden")
    (properties (alist-delete 'hidden? (package-properties gcc)))))
