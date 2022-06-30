import std / [json, options]
import globals

type
  Config* = ref object
    backend*: Backend
    frontend*: Frontend
    dbPath*: Option[string]

var
  conf*: Config

try:
  let configString = readFile("config.json")
  conf = parseJson(configString).to(Config)
except IOError:
  echo "config file not found"

# import print
# initConfig()
# print config
