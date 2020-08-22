# al2-test-runner -- Alternative way of running rackunit tests

[![Build Status](https://dev.azure.com/alexharsanyi0641/racket-packages/_apis/build/status/alex-hhh.al2-test-runner?branchName=master)](https://dev.azure.com/alexharsanyi0641/racket-packages/_build/latest?definitionId=9&branchName=master)

This package provides an alternative way of running rackunit tests, providing
better visibility and improved reporting of test results. The `run-tests`
function is a drop-in replacement of the equivalent function from
`rackunit/textui`, providing the following benefits:

* Results from test runs are reported to the standard output, even if they are
  successful. This allows better visibility of what tests are actually run,
  along with their execution time

* Test results are written to an output file, using JUnit compatible
  format. This allows test results to be imported into various management
  tools for analyzing trends such as test durations and failure rates across
  different builds

* Tests can be explicitly skipped, and such tests are reported as skipped -
  this allows better visibility of what tests are not run, when compared to
  just commenting them out in the source code.

The package does not define another testing framework, instead it runs
rackunit tests which are organized in test-suites and test-cases.

You can install this [Racket](https://racket-lang.org) package using the
following command:

```
raco pkg install al2-test-runner
```

For more details, see [the
documentation](https://docs.racket-lang.org/manual@al2-test-runner/index.html)
for this package.
