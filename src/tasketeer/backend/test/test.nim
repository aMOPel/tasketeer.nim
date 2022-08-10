import std / [options]
import ../../globals

proc add(t: Task): int {.cdecl, exportc, dynlib.} =
  echo "hi"
proc delete(t: Task): int {.cdecl, exportc, dynlib.} =
  echo "hi"
proc update(task: Task,
    updatedTask: UpdatedTask): int {.cdecl, exportc, dynlib.} =
  echo "hi"
proc query(filter: Filter): Option[Tasks] {.cdecl, exportc, dynlib.} =
  echo "hi"
proc init(config: Config): int {.cdecl, exportc, dynlib.} =
  echo "hi"

