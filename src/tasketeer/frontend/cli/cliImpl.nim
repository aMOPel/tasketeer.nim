import std / [options]

import nancy
import termstyle

method showTasks*(frontend: CliFrontend, tasks: Tasks): int =
  var table: TerminalTable
  table.add ""
  table.add(
    bold red "id:",
    bold blue "description:",
    bold green "tags:",
    bold yellow "status:"
  )
  table.add ""
  for task in tasks:
    table.add $task.id, task.description.get(""), task.tags.get(""),
        $TaskStatus(task.status)
  table.add ""
  table.echoTable(80, 2)

# this is injected from cliCommands to circumvent circular dependencies
# I chose this structure, so that the full implementation of the
# frontendInterface is in this file
var initProc*: proc (): int

method init*(frontend: CliFrontend): int =
  initProc()
# method showDeleted*(frontend: CliFrontend, task: Task)
