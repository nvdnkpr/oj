
command.coffee
==============================================================================

  Dependencies

    _ = require 'underscore'
    commander = require 'commander'
    oj = require './server'

    module.exports = ->

  Usage

      commander.version(oj.version)
        .usage('[options] <file> <dir> ...')
        .option('-m, --minify', 'Turn on minification (default: off)', false)
        .option('-w, --watch', 'Turn on watch mode (default: off)', false)
        .option('-o, --output <dir>', 'Directory to output all files to (default: ./www)', path.join process.cwd(), 'www')
        .option('-v, --verbose <level>', 'Turn on verbose level 0-3 (default: 1)', 1)
        .option('-e, --exclude <modules>', 'List of modules to exclude (jquery,oj,...)', splitAndTrim, [])
        # .option('--include [modules]', 'List of modules to include (underscore,backbone,...)', splitAndTrim, [])

        .option('--html', 'Include html in the output (default: included)')
        .option('--css', 'Include css in the output (default: included)')
        .option('--js', 'Include page js in the output (default: included)')
        .option('--modules', 'Include modules in output (default: included)')
        .option('--no-modules', 'Exclude modules in output (default: included)')

        .option('--modules-dir <dir>', 'Compile files in this dir with --modules (default: ./modules)', null)
        .option('--css-dir <dir>', 'Compile files in this dir with --css (default: unset)', null)

  Custom help

      commander.on '--help', ->
        console.log """
          Examples:

            Compile a single file and watch for changes

                oj file_name.oj --watch

            Compile current directory with minification

                oj . --minify

            Compile the included modules to a seperate .js file (no html, css, js)

                oj file.oj --modules

            Compile to just html (no js, css or included modules)

                oj file.oj --html

            Compile to just .css file (no js, html or included modules)

                oj file.oj --css

            Compile files in ./modules to a stand alone module js file. Omit modules everywhere else.
            (Important: Remember to <script> link your module.js files!)

                oj . --no-modules --module-dir ./modules

        """.replace(/^(.*)/gm, "  $1") # indent 2 spaces

  Parse args and run command

      commander.parse(process.argv)

  Hand parse boolean arguments because Commander sucks at them

      commander.html = (process.argv.indexOf '--no-html') == -1
      commander.css = (process.argv.indexOf '--no-css') == -1
      commander.js = (process.argv.indexOf '--no-js') == -1
      commander.modules = (process.argv.indexOf '--no-modules') == -1

  No arguments shows usage

      if not _.isArray(commander.args) or commander.args.length == 0
        usage()

      options = _.pick commander, 'args', 'minify', 'output', 'verbose', 'watch', 'exclude', 'html', 'css', 'js', 'modules', 'modulesDir', 'cssDir'

  Execute command through oj module api

      oj.command options
      return

  Helper method to show usage

    usage = (code = 0) ->
      commander.help()
      process.exit code

  Helper method to split lists on comma

    splitAndTrim = (str) ->
      out = str.split(',')
      for o in out
        o.trim()

