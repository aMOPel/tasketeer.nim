import ../globals
import std / [strformat]
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

proc add*(t: Task): R
  {.cdecl, importc, dynlib: dllName().}
  ## implement this  in a dynamic lib
proc delete*(t: Task): R
  {.cdecl, importc, dynlib: dllName().}
  ## implement this  in a dynamic lib
proc update*(task: Task, updatedTask: UpdatedTask): R
  {.cdecl, importc, dynlib: dllName().}
  ## implement this  in a dynamic lib
proc query*(filter: Filter): R
  {.cdecl, importc, dynlib: dllName().}
  ## implement this  in a dynamic lib
proc init*(config: Config): R
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
