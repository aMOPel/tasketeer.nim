import std/[options]

import norm / [model]

type
  TaskStatus* {.pure.} = enum
    Todo = "todo"
    Doing = "doing"
    Done = "done"

  Task* = ref object of Model
    description*: Option[string]
    tags*: Option[string]
    status*: int

  ModifiedTask* = ref object of Model
    description*: Option[Option[string]]
    tags*: Option[Option[string]]
    status*: Option[TaskStatus]

  Tasks* = seq[Task]

  Filter* = ref object
    description*: Option[string]
    tags*: Option[string]
    status*: Option[int]
    id*: Option[int]

  Config* = ref object
    backend*: string
    dbPath*: Option[string]


proc newTask*(description = none string, tags = none string,
    status = Todo): Task =
  Task(description: description, tags: tags, status: int(status))

var
  conf*: Config
