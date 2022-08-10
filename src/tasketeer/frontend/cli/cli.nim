import std / [options, strutils, strformat]

import nancy
import termstyle
import cligen
import cligen/argcvt
import results

import ../../globals
import dataProvider

import print

template backendError(tTasks: R, body: untyped) =
  if tTasks.isErr:
    stderr.writeLine conf.backend & " backend error: " & tTasks.error
    body

template backendError(tTasks: R) =
  if tTasks.isErr:
    stderr.writeLine conf.backend & " backend error: " & tTasks.error

proc parseFilter(filter: seq[string]): Option[Filter] =
  if filter.len == 0:
    none Filter
  elif filter.len == 1:
    let s = filter[0]
    try:
      let id = s.parseInt.int64
      some Filter(id: some id)
    except ValueError:
      try:
        let status = parseEnum[TaskStatus](s)
        some Filter(status: some status)
      except ValueError:
        some Filter(description: some s, tags: some s)
  elif filter.len == 2:
    let s = filter[0]
    let t = filter[1]
    try:
      let status = parseEnum[TaskStatus](s)
      some Filter(description: some t, tags: some t,
          status: some status)
    except ValueError:
      some Filter(description: some s, tags: some s)
  else:
    none Filter

proc `$`(f: Filter): string =
  result = "used these filters:"
  for k, v in fieldPairs(f):
    if v.isSome:
      result &= " | " & k & " = " & $(v.get)
  result &= " | "

proc showTasks(tasks: R, big = true): int =
  backendError tasks:
    return 1
  if tasks.value.len == 0:
    stderr.writeLine "no tasks found"
    return 1

  var table: TerminalTable
  if big: table.add ""
  table.add(
    bold red "id:",
    bold blue "description:",
    bold green "tags:",
    bold yellow "status:"
  )
  if big: table.add ""
  for task in tasks.value:
    table.add $task.id, task.description, task.tags.join(","),
        $TaskStatus(task.status)
  if big: table.add ""
  table.echoTable(80, 2)

# ===============================================================================
# cli commands

proc add(descAndTags: seq[string]): int =
  ## adds new task. Usage: task add <description> [<tag> ...]
  if descAndTags.len < 1:
    stderr.writeLine """
Missing these REQUIRED parameters:
  description
Run command with --help for more details.
"""
    return 1

  var task = newTask(descAndTags[0], descAndTags[
      1..<descAndTags.len])
  var r = addTask(task)
  if r.isOk: echo "added Task:"
  showTasks(r, big = false)


proc new(descAndTags: seq[string]): int =
  ## like `add`
  add(descAndTags)

proc remove(filter: seq[string]): int =
  ## removes tasks according to filter
  let f = parseFilter(filter)
  if f.isSome:
    echo f.get
    return showTasks(deleteTasks(f.get))
  else:
    stderr.writeLine """
Missing these REQUIRED parameters:
  filter
Run command with --help for more details.
"""
    return 1

proc delete(filter: seq[string]): int =
  ## like `remove`
  remove(filter)

proc list(filter: seq[string]): int =
  ## lists tasks according to filter
  let f = parseFilter(filter)
  if f.isSome:
    echo f.get
    return showTasks(getFilteredTasks(f.get))
  else:
    return showTasks(getAllTasks())

proc modify(filter: seq[string], description = none string, tags = none seq[
    string], status = none TaskStatus): int =
  ## change fields of filtered tasks

  if description.isNone and tags.isNone and status.isNone:
    stderr.writeLine """
Missing these REQUIRED parameters:
  description OR tags OR status
Run command with --help for more details.
"""
    return 1

  let f = parseFilter(filter)
  let u = newUpdatedTask(description, tags, status)
  if f.isSome:
    echo f.get
    return showTasks(updateTasks(f.get, u))
  else:
    stderr.writeLine """
Missing these REQUIRED parameters:
  filter
Run command with --help for more details.
"""
    return 1

proc update(filter: seq[string], description = none string, tags = none seq[
    string], status = none TaskStatus): int =
  ## like modify
  modify(filter, description, tags, status)

proc init =
  # for cligen options compatibility
  proc argParse[T](dst: var Option[T], dfl: Option[T],
                   a: var ArgcvtParams): bool =
    var uw: T # An unwrapped value
    if argParse(uw, (if dfl.isSome: dfl.get else: uw), a):
      dst = option(uw)
      return true

  # for cligen options compatibility
  proc argHelp[T](dfl: Option[T], a: var ArgcvtParams): seq[string] =
    @[a.argKeys, $T, (if dfl.isSome: $dfl.get else: "NONE")]

  dispatchMulti(
    [list],
    [cli.add],
    [cli.new],
    [cli.remove],
    [cli.delete],
    [modify],
    [update],
  )

when isMainModule:
  import ../../backend/backendInterface
  let r = backendInterface.init(conf)
  if r.isOk: init()
  else: backendError r
