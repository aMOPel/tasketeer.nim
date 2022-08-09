import std / [options]
import ../../globals

proc add(t: var Task): int {.cdecl, exportc, dynlib.} =
  echo "hi"
proc delete(t: var Task): int {.cdecl, exportc, dynlib.} =
  echo "hi"
proc modify(task: var Task,
    modifiedTask: ModifiedTask): int {.cdecl, exportc, dynlib.} =
  echo "hi"
proc get(filter: Filter): Option[Tasks] {.cdecl, exportc, dynlib.} =
  echo "hi"
proc init(config: Config): int {.cdecl, exportc, dynlib.} =
  echo "hi"

