import std/[options]

import results

type
  TaskStatus* {.pure.} = enum
    Todo = "todo"
    Doing = "doing"
    Done = "done"

  Task* = tuple
    description: string
    tags: seq[string]
    status: TaskStatus
    id: int64

  UpdatedTask* = tuple
    description: Option[string]
    tags: Option[seq[string]]
    status: Option[TaskStatus]

  Tasks* = seq[Task]

  Filter* = object
    description*: Option[string]
    tags*: Option[string]
    status*: Option[TaskStatus]
    id*: Option[int64]

  Config* = ref object
    backend*: string
    dbPath*: Option[string]

  R* = Result[Tasks, string]

proc newTask*(description: string, tags: seq[string] = @[],
    status = Todo): Task =
  (description: description, tags: tags, status: status, id: 0i64)
proc newUpdatedTask*(description = none string, tags = none seq[string],
    status = none TaskStatus): UpdatedTask =
  (description: description, tags: tags, status: status)

var
  conf*: Config
