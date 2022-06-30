import print
import backend/backendInterface
import backend/sqlite
import backend/test as btest
import frontend/frontendInterface
import frontend/cli/cliImpl
import frontend/test as ftest

import config

let
  backend* = case conf.backend:
    of Sqlite:
      new SqliteBackend
    of Backend.Test:
      new TestBackend
  frontend* = case conf.frontend:
    of Cli:
      new CliFrontend
    of Frontend.Test:
      new TestFrontend

proc showAllTasks*(): int =
  let tasks = backend.get(Filter())
  if tasks.isSome:
    frontend.showTasks(tasks.get)
  else:
    1

proc addTask*(task: var Task): int =
  backend.add(task)

proc showFilteredTasks*(filter: Filter): int =
  let tasks = backend.get(filter)
  if tasks.isSome:
    frontend.showTasks(tasks.get)
  else:
    1

proc deleteTasks(filter: Filter): int =
  var tasks = backend.get(filter)
  if tasks.isSome:
    result = 0
    for i in 0..<tasks.get.len:
      result = backend.delete(tasks.get()[i])
      if result == 1: return
  else:
    result = 1

proc modifyTasks(filter: Filter, modifiedTask: ModifiedTask): int =
  var tasks = backend.get(filter)
  if tasks.isSome:
    result = 0
    for i in 0..<tasks.get.len:
      result = backend.modify(tasks.get()[i], modifiedTask)
      if result == 1: return
  else:
    result = 1

