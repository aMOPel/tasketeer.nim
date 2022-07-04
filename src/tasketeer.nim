import tasketeer/glue

# needs to be imported to assign initProc in cliImpl at the right time
import tasketeer/frontend/cli/cliCommands

import tasketeer/frontend/frontendInterface
import tasketeer/backend/backendInterface

# TODO: priorities
# TODO: due date
# TODO: dependencies
# TODO: export

when isMainModule:
  discard backend.init
  discard frontend.init
