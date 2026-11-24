Source map emission is unavailable on the baseline compiler.
The implementation in #2051 covers map contents and source locations.

  $ . ./setup.sh
  $ echo 'let value = 1' > input.ml
  $ melc -mel-source-map file -o input.js input.ml 2>error
  [124]
  $ tail -n 1 error
  melc: unknown option '--mel-source-map'
