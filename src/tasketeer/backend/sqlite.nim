import std / [logging, with, strutils, strformat]

import norm / [sqlite]
import print

import ../config

addHandler newConsoleLogger(fmtStr = "")

var dbConn*: DbConn

method add*(backend: SqliteBackend, t: var Task): int =
  with dbConn:
    insert t

method delete*(backend: SqliteBackend, t: var Task): int =
  with dbConn:
    delete t

method modify*(backend: SqliteBackend, task: var Task,
    modifiedTask: ModifiedTask): int =
  var modified = false
  if modifiedTask.description.isSome:
    task.description = modifiedTask.description.get
    modified = true
  if modifiedTask.tags.isSome:
    task.tags = modifiedTask.tags.get
    modified = true
  if modifiedTask.status.isSome:
    task.status = int(modifiedTask.status.get)
    modified = true
  if modified:
    with dbConn:
      update task

method get*(backend: SqliteBackend, filter: Filter): Option[Tasks] =
  var queries: tuple[description: string, tags: string, status: string, id: string]
  var values: seq[DbValue]
  if filter.id.isSome:
    queries.id = "Task.id = ?"
    values.add dbValue(filter.id.get)
  else:
    if filter.description.isSome:
      queries.description = "Task.description LIKE ?"
      values.add dbValue(&"%{filter.description.get}%")
    if filter.tags.isSome:
      queries.tags = "Task.tags LIKE ?"
      values.add dbValue(&"%{filter.tags.get}%")
    if filter.status.isSome:
      queries.status = "Task.status = ?"
      values.add dbValue(filter.status.get)


  try:
    var selection = @[newTask()]
    if values.len == 0:
      with dbConn:
        selectAll(selection)
    else:
      var query: string
      if not queries.id.isEmptyOrWhitespace:
        query = queries.id
      elif not queries.description.isEmptyOrWhitespace or
          not queries.tags.isEmptyOrWhitespace:
        if not queries.description.isEmptyOrWhitespace and
            not queries.tags.isEmptyOrWhitespace:
          query &= &"({queries.description} OR {queries.tags})"
        elif not queries.description.isEmptyOrWhitespace:
          query &= queries.description
        elif not queries.tags.isEmptyOrWhitespace:
          query &= queries.tags
        if not queries.status.isEmptyOrWhitespace:
          query &= &" AND {queries.status}"
      else:
        query &= queries.status

      # print queries
      # print query
      # print values
      with dbConn:
        select(selection, query, values)
    return some selection
  except NotFoundError:
    return none Tasks

method init*(backend: SqliteBackend): int =
  try:
    dbConn = open(conf.dbPath.get, "", "", "")
    dbConn.createTables(newTask())
    return 0
  except DbError as e:
    print e.msg
    return 1

# when isMainModule:
#   var
#     test = newTask(some "testtask")
#     # selection = newTask()
#   var selection = get(Filter())
#   # with dbConn:
#   #   # insert test
#   #   select selection, "Task.description LIKE ?", "test%"
#   discard modify(selection.get()[0], ModifiedTask(status: some Done,
#       description: some none string))
#   print get(Filter())
#   # with dbConn:
#   #   # insert test
#   #   select selection, "Task.description LIKE ?", "test%"
#   # print selection
#   # print test
