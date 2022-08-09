import ../globals
import std / [options, strformat]
import jsony

var cache: string

proc dllName(): string =
  ## get the name of the dynamic lib file for the backend
  try:
    if cache == "":
      let configString = readFile("config.json")
      var tempconfig = configString.fromJson(Config)
      globals.conf = tempconfig
      cache = tempconfig.backend
    result = &"./build/lib{cache}.so"
  except IOError:
    echo "config file not found"

proc add*(t: var Task): int
  {.cdecl, importc, dynlib: dllName().}
  ## implement this  in a dynamic lib
proc delete*(t: var Task): int
  {.cdecl, importc, dynlib: dllName().}
  ## implement this  in a dynamic lib
proc modify*(task: var Task, modifiedTask: ModifiedTask): int
  {.cdecl, importc, dynlib: dllName().}
  ## implement this  in a dynamic lib
proc get*(filter: Filter): Option[Tasks]
  {.cdecl, importc, dynlib: dllName().}
  ## implement this  in a dynamic lib
proc init*(config: Config): int
  {.cdecl, importc, dynlib: dllName().}
  ## implement this  in a dynamic lib

# when isMainModule:
#   import print
#   discard init(conf)
#   var f = Filter()
#   var r = get(f)
#   if r.isSome:
#     for t in r.get:
#       print t
