import std / [options, strutils]
import ../../globals

import cligen

import ../../glue

proc add*(descAndTags: seq[string]): int =
  ## adds new task. Usage: task add <description> [<tag> ...]
  var task = newTask(some descAndTags[0], some descAndTags[
      1..<descAndTags.len].join(","))
  result = addTask(task)

proc new*(descAndTags: seq[string]): int =
  ## like `add`
  add(descAndTags)

proc remove*(filter: seq[string]): int =
  ## removes tasks according to filter
  if filter.len == 0:
    1
  elif filter.len == 1:
    let s = filter[0]
    try:
      let id = s.parseInt
      deleteTasks(Filter(id: some id))
    except ValueError:
      try:
        let status = parseEnum[TaskStatus](s).int
        deleteTasks(Filter(status: some status))
      except ValueError:
        deleteTasks(Filter(description: some s, tags: some s))
  elif filter.len == 2:
    let s = filter[0]
    let t = filter[1]
    try:
      let status = parseEnum[TaskStatus](s).int
      deleteTasks(Filter(description: some t, tags: some t,
          status: some status))
    except ValueError:
      deleteTasks(Filter(description: some s, tags: some s))
  else:
    1

proc delete*(filter: seq[string]): int =
  ## like `remove`
  remove(filter)

proc list*(filter: seq[string]): int =
  ## lists tasks according to filter
  if filter.len == 0:
    showAllTasks()
  elif filter.len == 1:
    let s = filter[0]
    try:
      let id = s.parseInt
      showFilteredTasks(Filter(id: some id))
    except ValueError:
      try:
        let status = parseEnum[TaskStatus](s).int
        showFilteredTasks(Filter(status: some status))
      except ValueError:
        showFilteredTasks(Filter(description: some s, tags: some s))
  elif filter.len == 2:
    let s = filter[0]
    let t = filter[1]
    try:
      let status = parseEnum[TaskStatus](s).int
      showFilteredTasks(Filter(description: some t, tags: some t,
          status: some status))
    except ValueError:
      showFilteredTasks(Filter(description: some s, tags: some s))
  else:
    1

proc cstatus*(filter: seq[string], newValue: TaskStatus): int =
  ## change status of filtered tasks
  if filter.len == 0:
    1
  elif filter.len == 1:
    let s = filter[0]
    try:
      let id = s.parseInt
      modifyTasks(Filter(id: some id), ModifiedTask(status: some newValue))
    except ValueError:
      try:
        let filter_status = parseEnum[TaskStatus](s).int
        modifyTasks(Filter(status: some filter_status),
          ModifiedTask(status: some newValue))
      except ValueError:
        modifyTasks(Filter(description: some s, tags: some s),
          ModifiedTask(status: some newValue))
  elif filter.len == 2:
    let s = filter[0]
    let t = filter[1]
    try:
      let filter_status = parseEnum[TaskStatus](s).int
      modifyTasks(Filter(description: some t, tags: some t,
          status: some filter_status), ModifiedTask(status: some newValue))
    except ValueError:
      modifyTasks(Filter(description: some s, tags: some t),
          ModifiedTask(status: some newValue))
  else:
    1

proc cdescription*(filter: seq[string], newValue: string): int =
  ## change description of filtered tasks

  let nv = some newValue

  if newValue.len == 0:
    1
  elif filter.len == 0:
    1
  elif filter.len == 1:
    let s = filter[0]
    try:
      let id = s.parseInt
      modifyTasks(Filter(id: some id), ModifiedTask(description: some nv))
    except ValueError:
      try:
        let filter_status = parseEnum[TaskStatus](s).int
        modifyTasks(Filter(status: some filter_status),
          ModifiedTask(description: some nv))
      except ValueError:
        modifyTasks(Filter(description: some s, tags: some s),
          ModifiedTask(description: some nv))
  elif filter.len == 2:
    let s = filter[0]
    let t = filter[1]
    try:
      let filter_status = parseEnum[TaskStatus](s).int
      modifyTasks(Filter(description: some t, tags: some t,
          status: some filter_status), ModifiedTask(description: some nv))
    except ValueError:
      modifyTasks(Filter(description: some s, tags: some t),
          ModifiedTask(description: some nv))
  else:
    1

proc ctags*(filter: seq[string], newValue: seq[string]): int =
  ## change tags of filtered tasks

  let nv = if newValue.len == 0:
      none string
    else:
      some(newValue.join(","))

  if filter.len == 0:
    1
  elif filter.len == 1:
    let s = filter[0]
    try:
      let id = s.parseInt
      modifyTasks(Filter(id: some id), ModifiedTask(tags: some nv))
    except ValueError:
      try:
        let filter_status = parseEnum[TaskStatus](s).int
        modifyTasks(Filter(status: some filter_status),
          ModifiedTask(tags: some nv))
      except ValueError:
        modifyTasks(Filter(description: some s, tags: some s),
          ModifiedTask(tags: some nv))
  elif filter.len == 2:
    let s = filter[0]
    let t = filter[1]
    try:
      let filter_status = parseEnum[TaskStatus](s).int
      modifyTasks(Filter(description: some t, tags: some t,
          status: some filter_status), ModifiedTask(tags: some nv))
    except ValueError:
      modifyTasks(Filter(description: some s, tags: some t),
          ModifiedTask(tags: some nv))
  else:
    1

import ../frontendInterface
initProc = proc (): int =
  # import cligen/argcvt
  # proc argParse[T](dst: var Option[T], dfl: Option[T],
  #                  a: var ArgcvtParams): bool =
  #   var uw: T           # An unwrapped value
  #   if argParse(uw, (if dfl.isSome: dfl.get else: uw), a):
  #     dst = option(uw)
  #     return true
  #
  # proc argHelp[T](dfl: Option[T], a: var ArgcvtParams): seq[string] =
  #   @[a.argKeys, $T, (if dfl.isSome: $dfl.get else: "NONE")]

  dispatchMulti([list], [cliCommands.add], [cliCommands.new], [
      cliCommands.remove], [cliCommands.delete], [cstatus], [cdescription], [ctags])
