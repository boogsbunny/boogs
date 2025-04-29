(define-module (boogs packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages geo)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages haskell-xyz)
  #:use-module (gnu packages image)
  #:use-module (gnu packages kerberos)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages protobuf)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages textutils)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages web)
  #:use-module (guix build-system font)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system zig)
  #:use-module (guix channels)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  ;; #:use-module (nonguix build-system binary)
  ;; #:use-module ((nonguix licenses) :prefix license:)
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

(define-public font-iosevka-term-nerd-font
  (let ((version "v3.3.0"))
    (package
      (name "font-iosevka-term-nerd-font")
      (version version)
      (source
       (origin
         (method url-fetch)
         (uri
          (string-append
           "https://github.com/ryanoasis/nerd-fonts/releases/download/"
           version
           "/IosevkaTerm.tar.xz"))
         (sha256
          (base32
           "02xpmzwl38cz6l4jzf5wk41kv8f6i7ffg1wzpj7hk86j3qys98jw"))))
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

(define-public ghostty
  (let* ((version "1.0.1")
         (commit (string-append "v" version)))
    (package
      (name "ghostty")
      (version version)
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/ghostty-org/ghostty")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "05czkg0f6ixjgabi6w1wa8jklr345crbihmci8lidy0bx8swa986"))))
      (build-system zig-build-system)
      (arguments
       (list #:tests? #f
             #:install-source? #f
             #:zig-release-type "fast"
             #:zig-build-flags
             #~(list "-Dcpu=baseline"
                     "--prefix"
                     "."
                     "--system"
                     (string-append (getenv "TMPDIR") "/source/zig-cache")
                     "--search-prefix"
                     (ungexp (this-package-input "libadwaita"))
                     "--search-prefix"
                     (string-append (getenv "TMPDIR") "/source/bzip2"))
             #:modules
             '((guix build zig-build-system)
               (guix build utils)
               (ice-9 match))
             #:phases
             #~(modify-phases %standard-phases
                 (replace 'unpack-dependencies
                   (lambda _
                     (mkdir-p "bzip2/lib")
                     (symlink
                      (string-append #$(this-package-input "bzip2")
                                     "/lib/libbz2.so")
                      "bzip2/lib/libbzip2.so")))
                 (add-after 'install 'fix-terminfo
                   (lambda _
                     (let* ((tic (string-append #$(this-package-native-input "ncurses") "/bin/tic"))
                            (terminfo-dir (string-append #$output "/share/terminfo"))
                            (terminfo-ghostty (string-append terminfo-dir "/ghostty.terminfo")))
                       (invoke tic "-x" "-s" "-o" terminfo-dir terminfo-ghostty))))
                 (add-after 'unpack 'unpack-zig
                   (lambda _
                     (for-each
                      (match-lambda
                        ((dst src)
                         (let* ((dest (string-append "zig-cache/" dst)))
                           (mkdir-p dest)
                           (if (string-contains src ".tar.gz")
                               (invoke "tar" "-xf" src "-C" dest "--strip-components=1")
                               (copy-recursively src dest)))))
                      `(("12200df4ebeaed45de26cb2c9f3b6f3746d8013b604e035dae658f86f586c8c91d2f"
                         #$(origin
                             (method git-fetch)
                             (uri (git-reference
                                   (url "https://github.com/rockorager/libvaxis")
                                   (commit "6d729a2dc3b934818dffe06d2ba3ce02841ed74b")))
                             (file-name "vaxis")
                             (sha256
                              (base32 "157lcj4xc1xavy0k04wmbklc3j28mmnyy3fpah2h9qdjy3sznmvw"))))
                        ("1220c72c1697dd9008461ead702997a15d8a1c5810247f02e7983b9f74c6c6e4c087"
                         #$(origin
                             (method git-fetch)
                             (uri (git-reference
                                   (url "https://github.com/rockorager/libvaxis")
                                   (commit "dc0a228a5544988d4a920cfb40be9cd28db41423")))
                             (file-name "vaxis")
                             (sha256
                              (base32 "1cnc82d5rm1iy1nzr6b75w4ffx70r5qi17m9dsjm5xy0xa67hqs1"))))
                        ("1220dd654ef941fc76fd96f9ec6adadf83f69b9887a0d3f4ee5ac0a1a3e11be35cf5"
                         #$(origin
                             (method git-fetch)
                             (uri (git-reference
                                   (url "https://github.com/zigimg/zigimg")
                                   (commit "3a667bdb3d7f0955a5a51c8468eac83210c1439e")))
                             (file-name "zigimg")
                             (sha256
                              (base32 "1ajcy7gawy3i98gpj07m9m6lqd089jl1kgskj4i0wypjgmhggdx0"))))
                        ("1220edc3b8d8bedbb50555947987e5e8e2f93871ca3c8e8d4cc8f1377c15b5dd35e8"
                         #$(origin
                             ; "zf"
                             (method url-fetch)
                             (uri "https://github.com/natecraddock/zf/archive/ed99ca18b02dda052e20ba467e90b623c04690dd.tar.gz")
                             (sha256
                              (base32 "1wgbw7x3mfpgijnqgi6q1xa56lp8lzzm1gh8npdzhhfmip4yp0py"))))
                        ("12206029de146b685739f69b10a6f08baee86b3d0a5f9a659fa2b2b66c9602078bbf"
                         #$(origin
                             ; "libxev"
                             (method url-fetch)
                             (uri "https://github.com/mitchellh/libxev/archive/db6a52bafadf00360e675fefa7926e8e6c0e9931.tar.gz")
                             (sha256
                              (base32 "1m50rgpy5h1fgp4p3h12na2w0c8kjqwcid7x6qip4rp48z1gjr70"))))
                        ("12206ed982e709e565d536ce930701a8c07edfd2cfdce428683f3f2a601d37696a62"
                         #$(origin
                             ; "mach_glfw"
                             (method url-fetch)
                             (uri "https://github.com/mitchellh/mach-glfw/archive/37c2995f31abcf7e8378fba68ddcf4a3faa02de0.tar.gz")
                             (sha256
                              (base32 "1nghcw6hj2dnwvl7sfhpxz0kwjk4nvqmq5cfb63z1wqjcnywh58y"))))
                        ("1220e17e64ef0ef561b3e4b9f3a96a2494285f2ec31c097721bf8c8677ec4415c634"
                         #$(origin
                             ; "zig_objc"
                             (method url-fetch)
                             (uri "https://github.com/mitchellh/zig-objc/archive/9b8ba849b0f58fe207ecd6ab7c147af55b17556e.tar.gz")
                             (sha256
                              (base32 "1m0z955wwyiwg5rnlsw0f3a2pllpxxgzygf8msrppnwk3mpciq8z"))))
                        ("12205a66d423259567764fa0fc60c82be35365c21aeb76c5a7dc99698401f4f6fefc"
                         #$(origin
                             ; "zig_js"
                             (method url-fetch)
                             (uri "https://github.com/mitchellh/zig-js/archive/d0b8b0a57c52fbc89f9d9fecba75ca29da7dd7d1.tar.gz")
                             (sha256
                              (base32 "0gaqqfb125pj62c05z2cpzih0gcm3482cfln50d41xf2aq4mw8vz"))))
                        ("12204bce50526caa10ab3a4b3666b96c23c6b3eaf7eaa7b0cd402034b60a9a6d7eb4"
                         #$(origin
                             ; "ziglyph"
                             (method url-fetch)
                             (uri "https://deps.files.ghostty.org/ziglyph-b89d43d1e3fb01b6074bc1f7fc980324b04d26a5.tar.gz")
                             (sha256
                              (base32 "1ngkyc81gqqfkgccxx4hj4w4kb3xk0ng7z73bwihbwbdw7rvvivj"))))
                        ("1220061d44ec37e6a240b31061c87cece7026d3dde885125e670f0f2d2811f40c122"
                         #$(origin
                             ; "cimgui"
                             (method url-fetch)
                             (uri "https://github.com/ocornut/imgui/archive/e391fe2e66eb1c96b1624ae8444dc64c23146ef4.tar.gz")
                             (sha256
                              (base32 "0q3qxycyl0z64mxf5j24c0g0yhif3mi7qf183rwan4fg0hgd0px0"))))
                        ("12207a40cc01f66b8c52cbb76afb5b6283fea3da31dca6e4e8d18138335fadc3bb23"
                         #$(origin
                             ; "fontconfig"
                             (method url-fetch)
                             (uri "https://deps.files.ghostty.org/fontconfig-2.14.2.tar.gz")
                             (sha256
                              (base32 "0mcarq6v9k7k9a8is23vq9as0niv0hbagwdabknaq6472n9dv8iv"))))
                        ("1220f1477c6fa679e0dc687894b2a3dac7b8ac93d0f41281ab7f90464699a7706823"
                         #$(origin
                             ; "freetype"
                             (method url-fetch)
                             (uri "https://github.com/freetype/freetype/archive/refs/tags/VER-2-13-2.tar.gz")
                             (sha256
                              (base32 "035r5bypzapa1x7za7lpvpkz58fxynz4anqzbk8705hmspsh2wj2"))))
                        ("12206a836ac8a36e16e2aeeb5e0f728f9d1e3788908f07dc87e8eb65f2ed515bff99"
                         #$(origin
                             ; "harfbuzz"
                             (method url-fetch)
                             (uri "https://github.com/harfbuzz/harfbuzz/archive/refs/tags/8.4.0.tar.gz")
                             (sha256
                              (base32 "0mk574w6i1zb4454iawvvhsns0hkh80px36fs559819vh64s074z"))))
                        ("1220ed91fa4ba9349e07733e67d6f3b0bece14636fc593954cedcca7c79d316cd62f"
                         #$(origin
                             ; "highway"
                             (method url-fetch)
                             (uri "https://github.com/google/highway/archive/refs/tags/1.1.0.tar.gz")
                             (sha256
                              (base32 "1jgpcqc3s6z8qjy7ghy4089p9wp3fd188w7ck05yg25m752qnjim"))))
                        ("1220a1a2a91d0bf09bb12f2bc82a57ff04fa326eed303f5ccdeb665c152f2ade0fe5"
                         #$(origin
                             ; "libpng"
                             (method url-fetch)
                             (uri "https://github.com/glennrp/libpng/archive/refs/tags/v1.6.43.tar.gz")
                             (sha256
                              (base32 "0fm0y7543w2gx5sz3zg9i46x1am51c77a554r0zqwpphdjs9bk7y"))))
                        ("122033bb26ba72ff93251e11a3e95f47ea2b714651fb85896756d03126be6f1442fe"
                         #$(origin
                             ; "oniguruma"
                             (method url-fetch)
                             (uri "https://github.com/kkos/oniguruma/archive/refs/tags/v6.9.9.tar.gz")
                             (sha256
                              (base32 "187jk4fxdkzc0wrcx4kdy4v6p1snwmv8r97i1d68yi3q5qha26h0"))))
                        ("122035462ad51b06d93f1b322092e5edbda3ca9f5c4447148d0cd9dda975f71d742d"
                         #$(origin
                             ; "sentry"
                             (method url-fetch)
                             (uri "https://github.com/getsentry/sentry-native/archive/refs/tags/0.7.8.tar.gz")
                             (sha256
                              (base32 "1pqqqcin8nw398rvn187dfqlab4vikdssiry14qqs6nnr1y4kiia"))))
                        ("1220d4d18426ca72fc2b7e56ce47273149815501d0d2395c2a98c726b31ba931e641"
                         #$(origin
                             ; "utfcpp"
                             (method url-fetch)
                             (uri "https://github.com/nemtrif/utfcpp/archive/refs/tags/v4.0.5.tar.gz")
                             (sha256
                              (base32 "1ksrdf7dy4csazhddi64xahks8jzf4r8phgkjg9hfxp722iniipz"))))
                        ("1220de0ea53b73c622c189e07734f4b69b4758b22ae1a2913a6ad38275d768194495"
                         #$(origin
                             ; "wuffs"
                             (method url-fetch)
                             (uri "https://github.com/google/wuffs/archive/refs/tags/v0.4.0-alpha.8.tar.gz")
                             (sha256
                              (base32 "0i7k5ffigicibrv2kw3psng0awz308wk9bpdgmgrcfm2hqlyjxrz"))))
                        ("12204f748d3be31b2827ecde760c50575a64e434c140dad85987f2ccfc3275419a72"
                         #$(origin
                             ; "zlib"
                             (method url-fetch)
                             (uri "https://github.com/madler/zlib/archive/refs/tags/v1.3.1.tar.gz")
                             (sha256
                              (base32 "0p6h2i9ajdp46lckdpibfqy4vz5nh5r22bqq96mp41k0ydiqis0p"))))
                        ("1220c99ca13f2a9716cdb0f4f6ac71522eae92b73b44b7692c87df951bcef51808b5"
                         #$(origin
                             ; "glslang"
                             (method url-fetch)
                             (uri "https://github.com/KhronosGroup/glslang/archive/refs/tags/14.2.0.tar.gz")
                             (sha256
                              (base32 "1dcpm70fhxk07vk37f5l0hb9gxfv6pjgbqskk8dfbcwwa2xyv8hl"))))
                        ("122084b1e02a96693a540b2f9c9dbf55fbfd188e262b94d5a2ab4770d5b6d0ba5c59"
                         #$(origin
                             ; "spirv_cross"
                             (method url-fetch)
                             (uri "https://github.com/KhronosGroup/SPIRV-Cross/archive/476f384eb7d9e48613c45179e502a15ab95b6b49.tar.gz")
                             (sha256
                              (base32 "1qspcsx56v0mddarb6f05i748wsl2ln3d8863ydsczsyqk7nyaxm"))))
                        ("1220c48facc56a6ae59edd98fcda7789fb457dee41eff875ee3fe84f51fc64c5aab6"
                         #$(origin
                             ; "iterm2_themes"
                             (method url-fetch)
                             (uri "https://github.com/mbadolato/iTerm2-Color-Schemes/archive/d6c42066b3045292e0b1154ad84ff22d6863ebf7.tar.gz")
                             (sha256
                              (base32 "1xqg9j1pfzc1k6dv5pvypjvwn47crk9l1gdlnh168ghfz7faraxk"))))
                        ("12201f0d542e7541cf492a001d4d0d0155c92f58212fbcb0d224e95edeba06b5416a"
                         #$(origin
                             ; "z2d"
                             (method url-fetch)
                             (uri "https://github.com/vancluever/z2d/archive/4638bb02a9dc41cc2fb811f092811f6a951c752a.tar.gz")
                             (sha256
                              (base32 "1xsxh7xkyl7c9n75840chg7a6hs0gqcr155g1mrgbzjfhkkhji9z"))))
                        ("1220bc6b9daceaf7c8c60f3c3998058045ba0c5c5f48ae255ff97776d9cd8bfc6402"
                         #$(origin
                             ; "imgui"
                             (method url-fetch)
                             (uri "https://github.com/ocornut/imgui/archive/e391fe2e66eb1c96b1624ae8444dc64c23146ef4.tar.gz")
                             (sha256
                              (base32 "0q3qxycyl0z64mxf5j24c0g0yhif3mi7qf183rwan4fg0hgd0px0"))))
                        ("12201149afb3326c56c05bb0a577f54f76ac20deece63aa2f5cd6ff31a4fa4fcb3b7"
                         #$(origin
                             ; "fontconfig"
                             (method url-fetch)
                             (uri "https://deps.files.ghostty.org/fontconfig-2.14.2.tar.gz")
                             (sha256
                              (base32 "0mcarq6v9k7k9a8is23vq9as0niv0hbagwdabknaq6472n9dv8iv"))))
                        ("122032442d95c3b428ae8e526017fad881e7dc78eab4d558e9a58a80bfbd65a64f7d"
                         #$(origin
                             ; "libxml2"
                             (method url-fetch)
                             (uri "https://github.com/GNOME/libxml2/archive/refs/tags/v2.11.5.tar.gz")
                             (sha256
                              (base32 "05b2kbccbkb5pkizwx2s170lcqvaj7iqjr5injsl5sry5sg0aa3c"))))
                        ("1220fb3b5586e8be67bc3feb34cbe749cf42a60d628d2953632c2f8141302748c8da"
                         #$(origin
                             ; "spirv_cross"
                             (method url-fetch)
                             (uri "https://github.com/KhronosGroup/SPIRV-Cross/archive/476f384eb7d9e48613c45179e502a15ab95b6b49.tar.gz")
                             (sha256
                              (base32 "1qspcsx56v0mddarb6f05i748wsl2ln3d8863ydsczsyqk7nyaxm"))))
                        ("1220c15e72eadd0d9085a8af134904d9a0f5dfcbed5f606ad60edc60ebeccd9706bb"
                         #$(origin
                             ; "oniguruma"
                             (method url-fetch)
                             (uri "https://github.com/kkos/oniguruma/archive/refs/tags/v6.9.9.tar.gz")
                             (sha256
                              (base32 "187jk4fxdkzc0wrcx4kdy4v6p1snwmv8r97i1d68yi3q5qha26h0"))))
                        ("12205c83b8311a24b1d5ae6d21640df04f4b0726e314337c043cde1432758cbe165b"
                         #$(origin
                             ; "highway"
                             (method url-fetch)
                             (uri "https://github.com/google/highway/archive/refs/tags/1.1.0.tar.gz")
                             (sha256
                              (base32 "1jgpcqc3s6z8qjy7ghy4089p9wp3fd188w7ck05yg25m752qnjim"))))
                        ("1220b81f6ecfb3fd222f76cf9106fecfa6554ab07ec7fdc4124b9bb063ae2adf969d"
                         #$(origin
                             ; "freetype"
                             (method url-fetch)
                             (uri "https://github.com/freetype/freetype/archive/refs/tags/VER-2-13-2.tar.gz")
                             (sha256
                              (base32 "035r5bypzapa1x7za7lpvpkz58fxynz4anqzbk8705hmspsh2wj2"))))
                        ("1220aa013f0c83da3fb64ea6d327f9173fa008d10e28bc9349eac3463457723b1c66"
                         #$(origin
                             ; "libpng"
                             (method url-fetch)
                             (uri "https://github.com/glennrp/libpng/archive/refs/tags/v1.6.43.tar.gz")
                             (sha256
                              (base32 "0fm0y7543w2gx5sz3zg9i46x1am51c77a554r0zqwpphdjs9bk7y"))))
                        ("1220b8588f106c996af10249bfa092c6fb2f35fbacb1505ef477a0b04a7dd1063122"
                         #$(origin
                             ; "harfbuzz"
                             (method url-fetch)
                             (uri "https://github.com/harfbuzz/harfbuzz/archive/refs/tags/8.4.0.tar.gz")
                             (sha256
                              (base32 "0mk574w6i1zb4454iawvvhsns0hkh80px36fs559819vh64s074z"))))
                        ("1220fed0c74e1019b3ee29edae2051788b080cd96e90d56836eea857b0b966742efb"
                         #$(origin
                             ; "zlib"
                             (method url-fetch)
                             (uri "https://github.com/madler/zlib/archive/refs/tags/v1.3.1.tar.gz")
                             (sha256
                              (base32 "0p6h2i9ajdp46lckdpibfqy4vz5nh5r22bqq96mp41k0ydiqis0p"))))
                        ("12201278a1a05c0ce0b6eb6026c65cd3e9247aa041b1c260324bf29cee559dd23ba1"
                         #$(origin
                             ; "glslang"
                             (method url-fetch)
                             (uri "https://github.com/KhronosGroup/glslang/archive/refs/tags/14.2.0.tar.gz")
                             (sha256
                              (base32 "1dcpm70fhxk07vk37f5l0hb9gxfv6pjgbqskk8dfbcwwa2xyv8hl"))))
                        ("1220446be831adcca918167647c06c7b825849fa3fba5f22da394667974537a9c77e"
                         #$(origin
                             ; "sentry"
                             (method url-fetch)
                             (uri "https://github.com/getsentry/sentry-native/archive/refs/tags/0.7.8.tar.gz")
                             (sha256
                              (base32 "1pqqqcin8nw398rvn187dfqlab4vikdssiry14qqs6nnr1y4kiia"))))
                        ("12200984439edc817fbcbbaff564020e5104a0d04a2d0f53080700827052de700462"
                         #$(origin
                             ; "wuffs"
                             (method url-fetch)
                             (uri "https://github.com/google/wuffs/archive/refs/tags/v0.4.0-alpha.8.tar.gz")
                             (sha256
                              (base32 "0i7k5ffigicibrv2kw3psng0awz308wk9bpdgmgrcfm2hqlyjxrz"))))
                        ("12207831bce7d4abce57b5a98e8f3635811cfefd160bca022eb91fe905d36a02cf25"
                         #$(origin
                             ; "ziglyph"
                             (method url-fetch)
                             (uri "https://deps.files.ghostty.org/ziglyph-b89d43d1e3fb01b6074bc1f7fc980324b04d26a5.tar.gz")
                             (sha256
                              (base32 "1ngkyc81gqqfkgccxx4hj4w4kb3xk0ng7z73bwihbwbdw7rvvivj"))))
                        ("1220cc25b537556a42b0948437c791214c229efb78b551c80b1e9b18d70bf0498620"
                         #$(origin
                             ; "iterm2_themes"
                             (method url-fetch)
                             (uri "https://github.com/mbadolato/iTerm2-Color-Schemes/archive/e030599a6a6e19fcd1ea047c7714021170129d56.tar.gz")
                             (sha256
                              (base32 "14d0axwa2hadz39k4vm7gdaqhngqcw2nd2dvfz89wzfd987s6lc4"))))
                        ("122055beff332830a391e9895c044d33b15ea21063779557024b46169fb1984c6e40"
                         #$(origin
                             ; "zg"
                             (method url-fetch)
                             (uri "https://codeberg.org/atman/zg/archive/v0.13.2.tar.gz")
                             (sha256
                              (base32 "1mnc261y9dc2z69pbv65dx62zr3bnpykkmb2c64x5ayqnr7n27yv"))))
                        ("1220736fa4ba211162c7a0e46cc8fe04d95921927688bff64ab5da7420d098a7272d"
                         #$(origin
                             ; "glfw"
                             (method url-fetch)
                             (uri "https://github.com/mitchellh/glfw/archive/b552c6ec47326b94015feddb36058ea567b87159.tar.gz")
                             (sha256
                              (base32 "0da2qj9jlsnwcarc768s08zyx2fnlkvmrvhwaxm23dr6wh05bq11"))))
                        ("12202adbfecdad671d585c9a5bfcbd5cdf821726779430047742ce1bf94ad67d19cb"
                         #$(origin
                             ; "xcode_frameworks"
                             (method url-fetch)
                             (uri "https://github.com/mitchellh/xcode-frameworks/archive/69801c154c39d7ae6129ea1ba8fe1afe00585fc8.tar.gz")
                             (sha256
                              (base32 "0fnrswx0ahc59cz37qqm9z11021w5h7y3zpxkc4vbrqbrbcwizwq"))))
                        ("122004bfd4c519dadfb8e6281a42fc34fd1aa15aea654ea8a492839046f9894fa2cf"
                         #$(origin
                             ; "vulkan_headers"
                             (method url-fetch)
                             (uri "https://github.com/mitchellh/vulkan-headers/archive/04c8a0389d5a0236a96312988017cd4ce27d8041.tar.gz")
                             (sha256
                              (base32 "0mgqhrvavvrm3nm4yihyi4slr125mma9z16f72j5n730wx3fpv1b"))))
                        ("1220b3164434d2ec9db146a40bf3a30f490590d68fa8529776a3138074f0da2c11ca"
                         #$(origin
                             ; "wayland_headers"
                             (method url-fetch)
                             (uri "https://github.com/mitchellh/wayland-headers/archive/5f991515a29f994d87b908115a2ab0b899474bd1.tar.gz")
                             (sha256
                              (base32 "00jx7w2vz1bdddpx239hkg76jqjjwmflsm8px5nlcam7k0nsan5q"))))
                        ("122089c326186c84aa2fd034b16abc38f3ebf4862d9ae106dc1847ac44f557b36465"
                         #$(origin
                             ; "x11_headers"
                             (method url-fetch)
                             (uri "https://github.com/mitchellh/x11-headers/archive/2ffbd62d82ff73ec929dd8de802bc95effa0ef88.tar.gz")
                             (sha256
                              (base32 "1rrvyidabdrkvax5s0mz0i122gc0z5fvl12w6wcf7z6qcip7c58j"))))
                        ("12207fd37bb8251919c112dcdd8f616a491857b34a451f7e4486490077206dc2a1ea"
                         #$(origin
                             ; "breakpad"
                             (method url-fetch)
                             (uri "https://github.com/getsentry/breakpad/archive/b99f444ba5f6b98cac261cbb391d8766b34a5918.tar.gz")
                             (sha256
                              (base32 "1nbadlml3r982bz1wyp17w33hngzkb07f47nrrk0g68s7na9ijkc")))))))))))
      (native-inputs
       (list `(,glib "bin")
             ncurses
             pandoc
             pkg-config
             tar))
      (inputs
       (list bzip2
             expat
             fontconfig
             freetype
             glslang
             harfbuzz
             libadwaita
             libglvnd
             libpng
             libx11
             libxcursor
             libxi
             libxrandr
             oniguruma
             zlib))
      (native-search-paths
       ;; FIXME: This should only be located in 'ncurses'.  Nonetheless it is
       ;; provided for usability reasons.  See <https://bugs.gnu.org/22138>.
       (list (search-path-specification
              (variable "TERMINFO_DIRS")
              (files '("share/terminfo")))))
      (home-page "https://www.ghossty.org/")
      (synopsis "Fast, feature-rich, and cross-platform terminal
  emulator that uses platform-native UI and GPU acceleration.")
      (description
       "Ghostty is a terminal emulator that differentiates itself by
  being fast, feature-rich, and native. While there are many excellent
  terminal emulators available, they all force you to choose between
  speed, features, or native UIs. Ghostty provides all three.")
      (license license:expat))))

(define-public postgis
  (package
    (name "postgis")
    (version "3.4.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://download.osgeo.org/postgis/source/postgis-"
                                  version ".tar.gz"))
              (sha256
               (base32
                "17dgk2bqjpg03jfqazv0hr0la97kax36q2dkci0kakc8dh5bdsdf"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:make-flags
       (list (string-append "datadir=" (assoc-ref %outputs "out") "/share")
             (string-append "docdir="(assoc-ref %outputs "out") "/share/doc")
             (string-append "pkglibdir="(assoc-ref %outputs "out") "/lib")
             (string-append "bindir=" (assoc-ref %outputs "out") "/bin"))
       #:phases
       (modify-phases %standard-phases
         (add-before 'build 'fix-install-path
           (lambda* (#:key outputs #:allow-other-keys)
             (substitute* '("raster/loader/Makefile" "raster/scripts/python/Makefile")
               (("\\$\\(DESTDIR\\)\\$\\(PGSQL_BINDIR\\)")
                (string-append (assoc-ref outputs "out") "/bin"))))))))
    (inputs
     (list gdal
           geos
           giflib
           json-c
           libjpeg-turbo
           libxml2
           openssl
           pcre
           postgresql
           protobuf-c
           proj))
    (native-inputs
     (list perl pkg-config))
    (home-page "https://postgis.net")
    (synopsis "Spatial database extender for PostgreSQL")
    (description "PostGIS is a spatial database extender for PostgreSQL
object-relational database.  It adds support for geographic objects allowing
location queries to be run in SQL.  This package provides a PostgreSQL
extension.")
    (license (list
               ;; General license
               license:gpl2+
               ;; loader/dbfopen, safileio.*, shapefil.h, shpopen.c
               license:expat
               ;; loader/getopt.*
               license:public-domain
               ;; doc/xsl
               license:bsd-3 ; files only say "BSD"
               ;; doc
               license:cc-by-sa3.0))))

;; (define-public zoom
;;   (package
;;     (name "zoom")
;;     (version "6.2.11.5069")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri (string-append "https://cdn.zoom.us/prod/" version "/zoom_x86_64.tar.xz"))
;;        (file-name (string-append name "-" version "-x86_64.tar.xz"))
;;        (sha256
;;         (base32 "09l9jfmld1dlinkgdgf8ra549rw1hwis3b5cly49a2gvz1sfr8lc"))))
;;     (supported-systems '("x86_64-linux"))
;;     (build-system binary-build-system)
;;     (arguments
;;      (list #:validate-runpath? #f ; TODO: fails on wrapped binary and included other files
;;            #:patchelf-plan
;;            ;; Note: it seems like some (all?) of these only do anything in
;;            ;; LD_LIBRARY_PATH, or at least needed there as well.
;;            #~(let ((libs '("alsa-lib"
;;                            "at-spi2-atk"
;;                            "at-spi2-core"
;;                            "atk"
;;                            "cairo"
;;                            "cups"
;;                            "dbus"
;;                            "eudev"
;;                            "expat"
;;                            "fontconfig-minimal"
;;                            "gcc"
;;                            "glib"
;;                            "gtk+"
;;                            "libdrm"
;;                            "libx11"
;;                            "libxcb"
;;                            "libxcomposite"
;;                            "libxcursor"
;;                            "libxdamage"
;;                            "libxext"
;;                            "libxfixes"
;;                            "libxkbcommon"
;;                            "libxkbfile"
;;                            "libxrandr"
;;                            "libxshmfence"
;;                            ;; "libxi"
;;                            ;; "libxtst"
;;                            ;; "libxinerama"
;;                            ;; "libxscrnsaver"
;;                            "libxtst"
;;                            "mesa"
;;                            "nspr"
;;                            "pango"
;;                            "pulseaudio"
;;                            "qtbase"
;;                            "qtsvg"
;;                            "xcb-util-image"
;;                            "xcb-util-keysyms"
;;                            "zlib")))
;;                `(("lib/zoom/ZoomLauncher"
;;                  ,libs)
;;                 ("lib/zoom/zoom"
;;                  ,libs)
;;                 ("lib/zoom/zopen"
;;                  ,libs)
;;                 ("lib/zoom/aomhost"
;;                  ,libs)))
;;            #:phases
;;            #~(modify-phases %standard-phases
;;                (replace 'unpack
;;                  (lambda* (#:key source #:allow-other-keys)
;;                    (invoke "tar" "xvf" source)
;;                    ;; Use the more standard lib directory for everything.
;;                    (mkdir-p "lib")
;;                    (rename-file "zoom/" "lib/zoom")))
;;                (add-after 'install 'wrap-where-patchelf-does-not-work
;;                  (lambda _
;;                    (wrap-program (string-append #$output "/lib/zoom/zopen")
;;                      `("LD_LIBRARY_PATH" prefix
;;                        ,(list #$@(map (lambda (pkg)
;;                                         (file-append (this-package-input pkg) "/lib"))
;;                                       '("fontconfig-minimal"
;;                                         "freetype"
;;                                         "gcc"
;;                                         "glib"
;;                                         "libxcomposite"
;;                                         "libxdamage"
;;                                         "libxkbcommon"
;;                                         "libxkbfile"
;;                                         "libxrandr"
;;                                         "libxrender"
;;                                         "zlib")))))
;;                    (wrap-program (string-append #$output "/lib/zoom/zoom")
;;                      '("QML2_IMPORT_PATH" = ())
;;                      `("QT_PLUGIN_PATH" prefix
;;                        (,(string-append #$(this-package-input "qtsvg") "/lib/qt5/plugins")))
;;                      ;; '("QT_PLUGIN_PATH" = ())
;;                      '("QT_SCREEN_SCALE_FACTORS" = ())
;;                      '("QT_QPA_PLATFORM" = ("xcb"))
;;                      `("PULSE_SERVER" = ("unix:/run/user/${UID}/pulse/native"))
;;                      `("PULSE_COOKIE" = ("${XDG_RUNTIME_DIR}/pulse/cookie"))
;;                      ;; `("DISPLAY" = (":0"))
;;                      `("XAUTHORITY" = ("${HOME}/.Xauthority"))
;;                      `("FONTCONFIG_PATH" ":" prefix
;;                        (,(string-join
;;                           (list
;;                            (string-append #$(this-package-input "fontconfig-minimal") "/etc/fonts")
;;                            #$output)
;;                           ":")))
;;                      `("LD_LIBRARY_PATH" prefix
;;                        ,(list (string-append #$(this-package-input "nss") "/lib/nss")
;;                               (string-append #$(this-package-input "qtbase") "/lib")
;;                               (string-append #$output "/lib/zoom/Qt/lib")
;;                               #$@(map (lambda (pkg)
;;                                         (file-append (this-package-input pkg) "/lib"))
;;                                       ;; TODO: Reuse this long list as it is
;;                                       ;; needed for aomhost.  Or perhaps
;;                                       ;; aomhost has a shorter needed list,
;;                                       ;; but untested.
;;                                       '("alsa-lib"
;;                                         "atk"
;;                                         "at-spi2-atk"
;;                                         "at-spi2-core"
;;                                         "cairo"
;;                                         "cups"
;;                                         "dbus"
;;                                         "eudev"
;;                                         "expat"
;;                                         "gcc"
;;                                         "glib"
;;                                         "mesa"
;;                                         "mit-krb5"
;;                                         "nspr"
;;                                         "libxcb"
;;                                         "libxcomposite"
;;                                         "libxdamage"
;;                                         "libxext"
;;                                         "libxkbcommon"
;;                                         "libxkbfile"
;;                                         "libxrandr"
;;                                         "libxshmfence"
;;                                         ;; "libxi"
;;                                         ;; "libxtst"
;;                                         ;; "libxinerama"
;;                                         ;; "libxscrnsaver"
;;                                         "pango"
;;                                         "pulseaudio"
;;                                         "qtbase"
;;                                         "qtsvg"
;;                                         "xcb-util"
;;                                         "xcb-util-image"
;;                                         "xcb-util-keysyms"
;;                                         "xcb-util-wm"
;;                                         "xcb-util-renderutil"
;;                                         "zlib")))))
;;                    (wrap-program (string-append #$output "/lib/zoom/aomhost")
;;                      `("FONTCONFIG_PATH" ":" prefix
;;                        (,(string-join
;;                           (list
;;                            (string-append #$(this-package-input "fontconfig-minimal") "/etc/fonts")
;;                            #$output)
;;                           ":")))
;;                      `("LD_LIBRARY_PATH" prefix
;;                        ,(list (string-append #$(this-package-input "nss") "/lib/nss")
;;                               #$@(map (lambda (pkg)
;;                                         (file-append (this-package-input pkg) "/lib"))
;;                                       '("alsa-lib"
;;                                         "atk"
;;                                         "at-spi2-atk"
;;                                         "at-spi2-core"
;;                                         "cairo"
;;                                         "cups"
;;                                         "dbus"
;;                                         "eudev"
;;                                         "expat"
;;                                         "gcc"
;;                                         "glib"
;;                                         "mesa"
;;                                         "mit-krb5"
;;                                         "nspr"
;;                                         "libxcb"
;;                                         "libxcomposite"
;;                                         "libxdamage"
;;                                         "libxext"
;;                                         "libxkbcommon"
;;                                         "libxkbfile"
;;                                         "libxrandr"
;;                                         "libxshmfence"
;;                                         "pango"
;;                                         "pulseaudio"
;;                                         "qtbase"
;;                                         "qtsvg"
;;                                         "xcb-util"
;;                                         "xcb-util-image"
;;                                         "xcb-util-keysyms"
;;                                         "xcb-util-wm"
;;                                         "xcb-util-renderutil"
;;                                         "zlib")))))))
;;                (add-after 'wrap-where-patchelf-does-not-work 'rename-binary
;;                  ;; IPC (for single sign-on and handling links) fails if the
;;                  ;; name does not end in "zoom," so rename the real binary.
;;                  ;; Thanks to the Nix packagers for figuring this out.
;;                  (lambda _
;;                    (rename-file (string-append #$output "/lib/zoom/.zoom-real")
;;                                 (string-append #$output "/lib/zoom/.zoom"))
;;                    (substitute* (string-append #$output "/lib/zoom/zoom")
;;                      (("zoom-real")
;;                       "zoom"))))
;;                (add-after 'rename-binary 'symlink-binaries
;;                  (lambda _
;;                    (delete-file (string-append #$output "/environment-variables"))
;;                    (mkdir-p (string-append #$output "/bin"))
;;                    (symlink (string-append #$output "/lib/zoom/aomhost")
;;                             (string-append #$output "/bin/aomhost"))
;;                    (symlink (string-append #$output "/lib/zoom/zoom")
;;                             (string-append #$output "/bin/zoom"))
;;                    (symlink (string-append #$output "/lib/zoom/zopen")
;;                             (string-append #$output "/bin/zopen"))
;;                    (symlink (string-append #$output "/lib/zoom/ZoomLauncher")
;;                             (string-append #$output "/bin/ZoomLauncher"))))
;;                (add-after 'symlink-binaries 'create-desktop-file
;;                  (lambda _
;;                    (let ((apps (string-append #$output "/share/applications")))
;;                      (mkdir-p apps)
;;                      (make-desktop-entry-file
;;                       (string-append apps "/zoom.desktop")
;;                       #:name "Zoom"
;;                       #:generic-name "Zoom Client for Linux"
;;                       #:exec (string-append #$output "/bin/ZoomLauncher %U")
;;                       #:mime-type (list
;;                                    "x-scheme-handler/zoommtg"
;;                                    "x-scheme-handler/zoomus"
;;                                    "x-scheme-handler/tel"
;;                                    "x-scheme-handler/callto"
;;                                    "x-scheme-handler/zoomphonecall"
;;                                    "application/x-zoom")
;;                       #:categories '("Network" "InstantMessaging"
;;                                      "VideoConference" "Telephony")
;;                       #:startup-w-m-class "zoom"
;;                       #:comment
;;                       '(("en" "Zoom Video Conference")
;;                         (#f "Zoom Video Conference")))))))))
;;     (native-inputs (list tar))
;;     (inputs (list alsa-lib
;;                   at-spi2-atk
;;                   at-spi2-core
;;                   atk
;;                   bash-minimal
;;                   cairo
;;                   cups
;;                   dbus
;;                   eudev
;;                   expat
;;                   fontconfig
;;                   freetype
;;                   `(,gcc "lib")
;;                   glib
;;                   gtk+
;;                   libdrm
;;                   librsvg
;;                   libx11
;;                   libxcb
;;                   libxcomposite
;;                   libxdamage
;;                   libxext
;;                   libxfixes
;;                   libxkbcommon
;;                   libxkbfile
;;                   libxrandr
;;                   libxrender
;;                   libxshmfence
;;                   ;; libxi
;;                   ;; libxtst
;;                   ;; libxinerama
;;                   ;; libxscrnsaver
;;                   mesa
;;                   mit-krb5
;;                   nspr
;;                   nss
;;                   pango
;;                   pulseaudio
;;                   qtbase
;;                   qtsvg
;;                   xcb-util
;;                   xcb-util-image
;;                   xcb-util-keysyms
;;                   xcb-util-renderutil
;;                   xcb-util-wm
;;                   zlib))
;;     (home-page "https://zoom.us/")
;;     (synopsis "Video conference client")
;;     (description "The Zoom video conferencing and messaging client.  Zoom must be run via an
;; app launcher to use its .desktop file, or with @code{ZoomLauncher}.")
;;     (license (license:nonfree "https://explore.zoom.us/en/terms/"))))
