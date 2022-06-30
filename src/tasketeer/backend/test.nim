import ../globals
import std / [options]

method add*(backend: TestBackend, t: var Task): int =
  echo "hi"
method delete*(backend: TestBackend, t: var Task): int =
  echo "hi"
method modify*(backend: TestBackend, task: var Task,
    modifiedTask: ModifiedTask): int =
  echo "hi"
method get(backend: TestBackend, filter: Filter): Option[Tasks] =
  echo "hi"

