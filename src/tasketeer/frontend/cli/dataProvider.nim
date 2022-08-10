import ../../backend/backendInterface
import ../../globals
import results

proc getAllTasks*(): R =
  backendInterface.query(Filter())

proc getFilteredTasks*(filter: Filter): R =
  backendInterface.query(filter)

proc addTask*(task: Task): R =
  backendInterface.add(task)

proc deleteTasks*(filter: Filter): R =
  var results = ?backendInterface.query(filter)
  for i in 0..<results.len:
    discard ?backendInterface.delete(results[i])
  result.ok results

proc updateTasks*(filter: Filter, updatedTask: UpdatedTask): R =
  var queryResults = ?backendInterface.query(filter)
  var updatedResults: Tasks
  for i in 0..<queryResults.len:
    updatedResults.add ?backendInterface.update(queryResults[i], updatedTask)
  result.ok updatedResults

