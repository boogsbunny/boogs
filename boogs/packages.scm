(define-module (boogs packages)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system font)
  #:use-module (nonguix licenses)
  #:use-module (gnu packages gcc)
  #:use-module (srfi srfi-1))

(define-public gcc-unhidden
  (package
    (inherit gcc)
    (name "gcc-unhidden")
    (properties (alist-delete 'hidden? (package-properties gcc)))))

(define-public font-0xproto-nerd-font
  (let ((version "v3.3.0"))
    (package
      (name "font-0xproto-nerd-font")
      (version version)
      (source
       (origin
         (method url-fetch)
         (uri
          (string-append
           "https://github.com/ryanoasis/nerd-fonts/releases/download/"
           version
           "/0xProto.tar.xz"))
         (sha256
          (base32
           "043yp0wysizqxlwfi2cis9xs91z6gyikik8apga7341ay21xsayp"))))
      (build-system font-build-system)
      (arguments
       `(#:phases
         (modify-phases %standard-phases
           (add-before 'install 'make-files-writable
             (lambda _
               (for-each
                make-file-writable
                (find-files "." ".*\\.(otf|otc|ttf|ttc)$"))
               #t)))))
      (home-page "https://www.nerdfonts.com/")
      (synopsis "Iconic font aggregator, collection, and patcher")
      (description
       "Nerd Fonts is a project that patches developer targeted fonts
with a high number of glyphs (icons). Specifically to add a high number
of extra glyphs from popular 'iconic fonts' such as Font Awesome,
Devicons, Octicons, and others.")
      (license license:silofl1.1))))
