#lang info
(define collection "al2-test-runner")
(define deps '("base" "rackunit-lib"))
(define build-deps '("sandbox-lib" "racket-doc" "rackunit-doc" "scribble-lib"))
(define scribblings '(("scribblings/manual.scrbl" ())))
(define pkg-desc "alternate rackunit test runner")
(define version "0.0")
(define pkg-authors '(AlexHarsanyi@gmail.com))

