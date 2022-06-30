import std / [options, logging, with, strutils, strformat]

import print
import nancy
import termstyle

import ../../globals

method showTasks*(frontend: CliFrontend, tasks: Tasks): int =
  var table: TerminalTable
  table.add ""
  table.add bold red "id:", bold blue "description:", bold green "tags:", bold yellow "status:"
  table.add ""
  for task in tasks:
    table.add $task.id, task.description.get(""), task.tags.get(""), $TaskStatus(task.status)
  table.add ""
  table.echoTable(80, 2)

# method showDeleted*(frontend: CliFrontend, task: Task)
