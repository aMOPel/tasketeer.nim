import ../globals
import std / [options]


method showTasks*(frontend: FrontendImpl, tasks: Tasks): int {.base.} =
  raise newException(CatchableError, "Method without implementation override")
method init*(frontend: FrontendImpl): int {.base.} =
  raise newException(CatchableError, "Method without implementation override")
