import ../globals
import std / [options]

method add*(backend: BackendImpl, t: var Task): int {.base.} =
  raise newException(CatchableError, "Method without implementation override")
method delete*(backend: BackendImpl, t: var Task): int {.base.} =
  raise newException(CatchableError, "Method without implementation override")
method modify*(backend: BackendImpl, task: var Task,
    modifiedTask: ModifiedTask): int {.base.} =
  raise newException(CatchableError, "Method without implementation override")
method get*(backend: BackendImpl, filter: Filter): Option[Tasks] {.base.} =
  raise newException(CatchableError, "Method without implementation override")

