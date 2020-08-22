#lang scribble/manual
@require[scribble/eval racket/sandbox
         @for-label[al2-test-runner racket/base rackunit
                    (except-in rackunit/text-ui run-tests)]]

@(define my-evaluator
(parameterize ([sandbox-input #f]
               [sandbox-output 'string]
               [sandbox-error-output 'string]
               ;; We write out this file...
               [sandbox-path-permissions '((write "my-package-test-results.xml"))])
 (make-evaluator 'racket/base)))

@title{al2-test-runner -- Alternative way of running rackunit test suites}
@author{Alex Harsányi}

@defmodule[al2-test-runner]

This package provides an alternative way of running @racket[rackunit] tests,
providing better visibility and improved reporting of test results.  The
@racket[run-tests] function is a drop-in replacement of the equivalent
function from @racket[rackunit/textui], providing the following benefits:

@itemlist[

  @item{Results from test runs are reported to the standard output, even if
        they are successful.  This allows better visibility of what tests are
        actually run, along with their execution time}

  @item{Test results are written to an output file, using JUnit compatible
        format.  This allows test results to be imported into various
        management tools for analyzing trends such as test durations and
        failure rates across different builds}

  @item{Tests can be explicitly skipped, and such tests are reported as
        skipped -- this allows better visibility of what tests are not run,
        when compared to just commenting them out in the source code.}
]

The package does not define another testing framework, instead it runs
@racket[rackunit] tests which are organized in @racket[test-suite]s and
@racket[test-case]s.

@section{Motivating Example}

When working on an application or package, you might disable a broken test
temporarily, but once you do, there is no longer an indication that the test
has been disabled.  The test suite passes, and if there is a large number of
tests, it is easy to miss that some were disabled:

@#reader scribble/comment-reader
(interaction #:eval my-evaluator
(require rackunit rackunit/text-ui)
(define a-test-suite
  (test-suite "A Test Suite"
    (test-case "First Test Case" (check-equal? 1 1))
    ;; (test-case "Second Test Case" (check-equal? 1 0))
    (test-case "Third Test Case" (check-equal? 1 1))))

(run-tests a-test-suite 'verbose))

The commented out test might be easy to spot in the previous example, but in a
bigger application with many tests, it is easy to miss.  The
@racket[al2-test-runner] package provides an alternative: the test can be
disabled by adding it to the exclusion list in @racket[run-tests].  The test
is still known to the test system and it is now reported as skipped.

@#reader scribble/comment-reader
(interaction
#:eval my-evaluator
(require rackunit al2-test-runner)
(define a-test-suite
  (test-suite "A Test Suite"
    (test-case "First Test Case" (check-equal? 1 1))
    (test-case "Second Test Case" (check-equal? 1 0))
    (test-case "Third Test Case" (check-equal? 1 1))))

(run-tests
  #:package "my-package"
  #:results-file "my-package-test-results.xml"
  ;; Second test case is broken, will fix it later
  #:exclude '(("A Test Suite" "Second Test Case"))
  a-test-suite))

In addition, this version of @racket[run-tests] will print out all the tests
that are run along with their pass/fail status and will also write this
information to a file, in standard JUnit test format.  This file can be
imported in various test management systems.

@section{API Documentation}

@defproc[(run-tests (#:package package string? "unnamed package")
                    (#:results-file results-file (or/c path-string? #f) #f)
                    (#:only only (or/c #f (listof (listof string?))) #f)
                    (#:exclude exclude (or/c #f (listof (listof string?))) #f)
                    (test-suite test-suite?) ...) any/c]{

  Run the tests in @racket[test-suite]s and report the results to the standard
  output.  For each test case, the name followed by the strings "ok",
  "failed", "error" or "skipped" is printed, along with the time in
  milliseconds it took to execute the test.

  @racket[package] is a string that is used as a package name when results are
  written to file.  JUnit tests are grouped into packages, and the XML file
  format expects that, but there is no higher construct than a
  @racket[test-suite] in @racket[rackunit], so the package name needs to be
  provided as a parameter to @racket[run-tests].

  When @racket[results-file] is specified, the test results are written to the
  specified file in JUnit XML format.  If a file name is not specified, the
  results are not written to file.

  When @racket[only] is present, it needs to be a list of test suite names
  followed by test case names, and only these tests will be run.  This is
  intended to be used when debugging a single test in a larger test suite.
  Tests that are not run will be reported as skipped.

  Here is an example of how to run only one test case in the test suite:

@interaction[#:eval my-evaluator
(require rackunit al2-test-runner)
(define a-test-suite
  (test-suite "A Test Suite"
    (test-case "First Test Case" (check-equal? 1 1))
    (test-case "Second Test Case" (check-equal? 1 1))
    (test-case "Third Test Case" (check-equal? 1 1))))

(run-tests
  #:package "my-package"
  #:results-file "my-package-test-results.xml"
  #:only '(("A Test Suite" "First Test Case"))
  a-test-suite)]

  When @racket[exclude] is preset, it needs to be a list of test case names
  followed by test suite names.  These tests will not be executed, and instead
  will be reported as skipped both on the standard output and in the output
  file.  Note that tests can also be skipped using @racket[skip-test].  This
  is indented for disabling tests which do not pass and they cannot be fixed
  immediately.

  Here is an example, that will not run "A Test Case":

@interaction[#:eval my-evaluator
(require rackunit al2-test-runner)
(define a-test-suite
  (test-suite "A Test Suite"
    (test-case "First Test Case" (check-equal? 1 1))
    (test-case "Second Test Case" (check-equal? 1 1))
    (test-case "Third Test Case" (check-equal? 1 1))))

(run-tests
  #:package "my-package"
  #:results-file "my-package-test-results.xml"
  #:exclude '(("A Test Suite" "First Test Case"))
  a-test-suite)]

}

@defproc[(skip-test) any/c]{

  This function can be used inside test cases to skip a test because some
  required testing condition cannot be met.  It can be used, for example, when
  tests require test data files and these data files are not available and it
  is a better indicator that a test suite did not actually fail but it didn't
  pass either.

  Here is an example where the second test case is skipped:

@interaction[#:eval my-evaluator
(require rackunit al2-test-runner)
(define a-test-suite
  (test-suite "A Test Suite"
    (test-case "First Test Case" (check-equal? 1 1))
    (test-case "Second Test Case" (unless (= 1 0) (skip-test)))
    (test-case "Third Test Case" (check-equal? 1 1))))

(run-tests
  #:package "my-package"
  #:results-file "my-package-test-results.xml"
  a-test-suite)]

}
