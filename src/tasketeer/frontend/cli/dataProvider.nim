import ../../backend/backendInterface
import ../../globals
import std / [options]

proc getAllTasks*(): Option[Tasks] =
  backendInterface.get(Filter())

proc getFilteredTasks*(filter: Filter): Option[Tasks] =
  backendInterface.get(filter)

proc addTask*(task: var Task): int =
  backendInterface.add(task)

proc deleteTasks*(filter: Filter): int =
  var tasks = backendInterface.get(filter)
  if tasks.isSome:
    result = 0
    for i in 0..<tasks.get.len:
      result = backendInterface.delete(tasks.get()[i])
      if result == 1: return
  else:
    result = 1

proc modifyTasks*(filter: Filter, modifiedTask: ModifiedTask): int =
  var tasks = backendInterface.get(filter)
  if tasks.isSome:
    result = 0
    for i in 0..<tasks.get.len:
      result = backendInterface.modify(tasks.get()[i], modifiedTask)
      if result == 1: return
  else:
    result = 1

