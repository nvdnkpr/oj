
# Include
# ------------------------------------------------------------------------------

fs = require 'fs'
cp = require 'child_process'
util = require 'util'
_ = require 'underscore'
{spawn, exec} = require 'child_process'
path = require 'path'
fs = require 'fs'
async = require 'async'
crypto = require 'crypto'
http = require 'http'
https = require 'https'

# Paths
# ------------------------------------------------------------------------------

CAKE_DIR = __dirname
WWW_DIR = path.join CAKE_DIR, 'www'
PAGES_DIR = path.join CAKE_DIR, 'pages'
LIB_DIR = path.join CAKE_DIR, 'lib'

# Tasks
# ------------------------------------------------------------------------------

task "build", "Build everything and run tests", ->
  invoke "build:js"
  invoke "build:docs"
  invoke "test"


task "build:js", "Compile coffee script files", ->
  launch 'coffee', ['--compile', '-o', LIB_DIR, 'src/oj.coffee']

task "build:js:watch", "Watch compile coffee script files", ->
  launch 'coffee', ['--compile', '--lint', '-o', LIB_DIR, '--watch', 'src']

task "ddd", "Build debug www", ->
  launch 'oj', ['--recursive', '--verbose', '1', '--debug', '--output', WWW_DIR, PAGES_DIR]

task "ddd:watch", "Watch debug www", ->
  launch 'oj', ['--recursive', '--watch', '--verbose', '1', '--debug', '--output', WWW_DIR, PAGES_DIR]

task "www", "Build www", ->
  launch 'oj', ['--recursive', '--output', WWW_DIR, PAGES_DIR]

task "www:watch", "Watch build www", ->
  launch 'oj', ['--watch', '--recursive', '-o', WWW_DIR, PAGES_DIR]

task "watch", "Watch all build targets", ->
  invoke 'build:js:watch'

task "build:docs", "Build documentation", ->
  invoke 'build:groc'

task "build:groc", "Build groc documentation", ->
  launch 'groc', ['--out', 'docs', 'src/*.coffee']

task "build:docco", "Build docco documentation", ->
  launch 'docco', ['src/*.coffee']

task "view:docs", "Open documentation in a browser", ->
  launch 'open', ['docs/oj.html']

task "docs", "Build and view docs", ->
  invoke 'build:docs'
  setTimeout (-> invoke 'view:docs'), 1000

task "test", "Run unit tests", ->
  exec "NODE_ENV=testing mocha", (err, output) ->
    throw err if err
    console.log output

task "test:watch", "Watch unit tests", ->
  launch 'mocha', ['--reporter', 'min', '--watch']

_modules =
  assert: 'https://raw.github.com/joyent/node/master/lib/assert.js',
  console: 'https://raw.github.com/joyent/node/master/lib/console.js',
  crypto: 'https://raw.github.com/joyent/node/master/lib/crypto.js',
  events: 'https://raw.github.com/joyent/node/master/lib/events.js',
  freelist: 'https://raw.github.com/joyent/node/master/lib/freelist.js',
  punycode: 'https://raw.github.com/joyent/node/master/lib/punycode.js',
  querystring: 'https://raw.github.com/joyent/node/master/lib/querystring.js'
  string_decoder: 'https://raw.github.com/joyent/node/master/lib/string_decoder.js',
  url: 'https://raw.github.com/joyent/node/master/lib/url.js',
  util: 'https://raw.github.com/joyent/node/master/lib/util.js',
  tty: 'https://raw.github.com/gist/2649813/01789078ef19464e8065416a3e95661f4c71b52f/tty.js'
  # Overriding path to remove util dependency
  # path: 'https://raw.github.com/joyent/node/master/lib/path.js',
task 'list', 'list node modules', ->
  console.log _.keys _modules

# Download all the built in node module files
task 'download', 'download node modules', ->
  moduleDir = path.join __dirname, 'modules'
  for module, url of _modules
    do (module, url) ->
      filepath = path.join moduleDir, "#{module}.js"

      console.log 'downloading: ', url
      download url, (err, data) ->

        console.log "saving: #{filepath} (#{data.length} characters)"
        save filepath, data, (err) ->
          throw err if err



# Utilities
# ------------------------------------------------------------------------------

optionsMode = (options, modes = ['production', 'staging', 'testing', 'development']) ->
  optionsCombine options, modes

optionsCombine = (options, choices) ->
  for choice in choices
    if options[choice]
      break
  choice

captialize = (str) ->
  "#{str.charAt(0).toUpperCase()}#{str.slice(1)}"

# envFromObject({FOO:'bar', FOO2:'bar2'}) => 'FOO=bar FOO2=bar2 '
envFromObject = (obj) ->
  out = ""
  for k,v of obj
    out += "#{k}=#{v} "
  out

# download: download the url to string
download = (url, cb) ->
  httpx = if startsWith(url, 'https:') then https else http
  options = require('url').parse url
  data = ""
  req = httpx.request options, (res) ->
    res.setEncoding "utf8"
    res.on "data", (chunk) ->
      data += chunk
    res.on "end", ->
      cb null, data, url
  req.end()

# Determine if string starts with other string
startsWith = (strInput, strStart) ->
  throw 'startsWith: argument error' unless (_.isString strInput) and (_.isString strStart)
  strInput.length >= strStart.length and strInput.lastIndexOf(strStart, 0) == 0

# Determine if string starts with other string
endsWith = (strInput, strEnd) ->
  throw 'endsWith: argument error' unless (_.isString strInput) and (_.isString strEnd)
  strInput.length >= strEnd.length and strInput.lastIndexOf(strEnd, strInput.length - strEnd.length) == strInput.length - strEnd.length

# Prepend string if necessary
prepend = (strInput, strStart) ->
  if (_.isString strInput) and (_.isString strStart) and not (startsWith strInput, strStart)
    return strStart + strInput
  strInput

# Prepend string if necessary
unprepend = (strInput, strStart) ->
  if _.isString(strInput) && _.isString(strStart) && startsWith(strInput, strStart)
    return strInput.slice strStart.length
  strInput

# mkdir: make a directory if it doesn't exist (mkdir -p)
mkdir = (dir, cb) ->
  fs.stat dir, (err, stats) ->
    if err?.code == 'ENOENT'
      fs.mkdir dir, cb
    else if stats.isDirectory
      cb(null)
    else
      throw "mkdir: #{dir} is not a directory"
      cb({code:"NotDir"})

# mkdirSync: make a directory syncronized if it doesn't exist (mkdir -p)
# Returns true if a new directory has been created but didn't exist before
mkdirSync = (dir) ->
  try
    stats = fs.statSync dir
    if not stats.isDirectory
      throw "mkdirSync: non-directory exists in location specified (#{dir})"
  catch err
    if err?.code == 'ENOENT'
      fs.mkdirSync dir
      return true
  false

# save: save file to path
save = (filepath, data, cb) ->
  cb ?= ->
  dir = path.dirname filepath
  # Ensure directory exists
  mkdir dir, (err) ->
    # Write file into directory
    fs.writeFile filepath, data, cb

# load: load a file into a string
load = (filepath, cb) ->
  fs.readFile filepath, "utf8", cb

# Logging
# ------------------------------------------------------------------------------

code =
  reset: '\u001b[0m'
  black: '\u001b[30m'
  red: '\u001b[31m'
  green: '\u001b[32m'
  yellow: '\u001b[33m'
  blue: '\u001b[34m'
  magenta: '\u001b[35m'
  cyan: '\u001b[36m'
  gray: '\u001b[37m'

log = (message, color, explanation) -> console.log code[color] + message + code.reset + ' ' + (explanation or '')
error = (message, explanation) -> log message, 'red', explanation
info = (message, explanation) -> log message, 'cyan', explanation
warn = (message, explanation) -> log message, 'yellow', explanation

launch = (cmd, args=[], options, callback = ->) ->
  # Options is optional (may be cb instead)
  if _.isFunction options
    callback = options
    options = {}

  # Info output command being run
  info "[#{envFromObject options?.env}#{cmd} #{args.join ' '}]"

  # cmd = which(cmd) if which
  app = spawn cmd, args, options
  app.stdout.pipe(process.stdout)
  app.stderr.pipe(process.stderr)
  app.on 'exit', (status) -> callback() if status is 0
