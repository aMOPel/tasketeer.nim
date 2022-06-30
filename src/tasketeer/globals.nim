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

  Backend* {.pure.} = enum
    Sqlite
    Test
  Frontend* {.pure.} = enum
    Cli
    Test


  BackendImpl* = ref object of RootObj
  SqliteBackend* = ref object of BackendImpl
  TestBackend* = ref object of BackendImpl

  FrontendImpl* = ref object of RootObj
  CliFrontend* = ref object of FrontendImpl
  TestFrontend* = ref object of FrontendImpl


proc newTask*(description = none string, tags = none string,
    status = Todo): Task =
  Task(description: description, tags: tags, status: int(status))
