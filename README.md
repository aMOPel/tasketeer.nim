# Tasketeer.nim

## Usage

Currently the paths are relative, so you have to navigate to the project root.

Compile `src/tasketeer.nim`.

`nim c ./src/tasketeer.nim`

It should compile to `build/tasketeer` (using the args from `config.nims`).

Run it:

`./build/tasketeer`

It should spit out a help message for the CLI usage.
Quote:
>  --help-syntax or --helps gives general cligen syntax help.

>  Run "{help SUBCMD|SUBCMD --help}" to see help for just SUBCMD.

Also it should create a `task.db` file in the project root, which is a SQLite DB.

## Subcommands

The only thing that's not self explanatory (I think) is how the `filter` works.
You can specify it for various subcommands to filter which tasks to access.

A filter can be:
* 1 number, which will be interpreted as a task ID
* 1 string equal to a member of the enum `TaskStatus`
* 1 string __not__ equal to a member of the enum `TaskStatus`. It will then
  be be used to filter both in `description` and in `tags` using the `LIKE` operator
  from SQL
* 2 strings. It will try to parse the 1st one as a `TaskStatus` and use the rest
  as `description` and `tags` again. Mind that using `TaskStatus` and
  `description`/`tags` is implemented using the `AND` operator, since it makes
  sense, if you specify both, you probably want a task fitting the `status` and
  the text.
