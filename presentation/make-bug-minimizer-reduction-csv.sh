#!/usr/bin/env bash

{ true                                                | ./compute-lines.sh;
  cat test-suite-coq-bug-finder.txt                   | ./compute-lines.sh --no-header test-suite;
  cat ../notebook/presentation/minimization_pairs.csv | ./compute-lines.sh --no-header ci-minimization;
} > coq-bug-finder-reduction.csv
