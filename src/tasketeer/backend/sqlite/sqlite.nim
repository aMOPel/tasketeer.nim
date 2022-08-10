import std / [logging, with, strformat, strutils, options, macros]

import results
import norm / [sqlite]
import norm / [model]
import ../../globals
import print

addHandler newConsoleLogger(fmtStr = "")

type
  DbTask = ref object of Model
    description: string
    tags: Option[string]
    status: TaskStatus

var
  dbConn: DbConn

proc newDbTask(description: string, tags = none string,
    status = Todo): DbTask =
  DbTask(description: description, tags: tags, status: status)

proc fromTuple(t: Task): DbTask =
  if t.id == 0:
    DbTask(description: t.description, tags: some t.tags.join(","), status: t.status)
  else:
    DbTask(description: t.description, tags: some t.tags.join(","), status: t.status, id: t.id)
proc toTuple(t: DbTask): Task =
  let tagsStr = t.tags.get("")
  (description: t.description,
  tags: if tagsStr == "": @[] else: tagsStr.split(','), status: t.status, id: t.id)

proc toTuples(ts: seq[DbTask]): Tasks =
  for t in ts:
    result.add t.toTuple

func dbType*(T: typedesc[enum]): string = "STRING"
func dbValue*(val: enum): DbValue = DbValue(kind: dvkString, s: $val)
func to*(dbVal: DbValue, T: typedesc[enum]): T = parseEnum[T](dbVal.s)

macro `[]=`(o: untyped; k: static[string]; v: untyped) =
  let i = k.ident
  quote do:
    `o`.`i` = `v`

proc override(task: var Task, updatedTask: UpdatedTask): bool =
  for k, v in fieldPairs(updatedTask):
    if v.isSome:
      task[k] = v.get
      result = true

# ===============================================================================
# export as dynlib

proc add(t: Task): R {.cdecl, exportc, dynlib.} =
  var dbTask = t.fromTuple
  try:
    dbConn.transaction:
      dbConn.insert dbTask
    result.ok @[dbTask.toTuple]
  except DbError as e:
    result.err e.msg

proc delete(t: Task): R {.cdecl, exportc, dynlib.} =
  var dbTask = t.fromTuple
  try:
    dbConn.transaction:
      dbConn.delete dbTask
    # return deleted Task
    result.ok @[t]
  except DbError as e:
    result.err e.msg

proc update(t: Task,
    updatedTask: UpdatedTask): R {.cdecl, exportc, dynlib.} =
  var task = t
  var updated = override(task, updatedTask)
  if updated:
    var dbTask = task.fromTuple
    try:
      dbConn.transaction:
        dbConn.update dbTask
      result.ok @[dbTask.toTuple]
    except DbError as e:
      result.err e.msg

proc query(filter: Filter): R {.cdecl, exportc, dynlib.} =

  var queries: tuple[description: string, tags: string, status: string, id: string]
  var values: seq[DbValue]
  if filter.id.isSome:
    queries.id = "DbTask.id = ?"
    values.add dbValue(filter.id.get)
  else:
    if filter.description.isSome:
      queries.description = "DbTask.description LIKE ?"
      values.add dbValue(&"%{filter.description.get}%")
    if filter.tags.isSome:
      queries.tags = "DbTask.tags LIKE ?"
      values.add dbValue(&"%{filter.tags.get}%")
    if filter.status.isSome:
      queries.status = "DbTask.status = ?"
      values.add dbValue($filter.status.get)

  try:
    var selection = @[newDbTask("")]
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

      with dbConn:
        select(selection, query, values)
    result.ok selection.toTuples
  except NotFoundError as e:
    result.err e.msg

proc init(config: Config): R {.cdecl, exportc, dynlib.} =
  if config.dbPath.isNone:
    result.err "dbPath not specified in config"
    return
  if config.dbPath.get == "":
    result.err "dbPath empty in config"
    return

  try:
    dbConn = open(config.dbPath.get, "", "", "")
    dbConn.createTables(newDbTask(""))
    result.ok @[]
  except DbError as e:
    result.err e.msg

