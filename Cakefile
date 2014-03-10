fs = require 'fs'
path = require 'path'
{spawn, exec} = require 'child_process'

# Flag for debugging the Cakefile
DEBUG_MODE = false

# Add to list any modules that cannot be found
missingModules = []
tryRequire = (moduleName) ->
  try
    module = require moduleName
    return module
  catch e
    console.error("Missing module #{moduleName}")
    missingModules.push(moduleName)
    return null

# Dependencies
coffeelint = null
Rehab = null
getDependencies = ->
  colors = tryRequire('colors')
  coffeelint = tryRequire('coffeelint')
  Rehab = tryRequire('rehab')
getDependencies()

PLATFORM = process.platform

Platform =
  WINDOWS: 'win32'
  LINUX: 'linux'

SLASH = if PLATFORM is Platform.WINDOWS then '\\' else '/'
COMMAND_SUFFIX = if PLATFORM is Platform.WINDOWS then '.cmd' else ''

# Constants
PUBLIC_JS = "public#{SLASH}js"
APP_JS = "#{PUBLIC_JS}#{SLASH}app.js"
VENDOR_JS = "#{PUBLIC_JS}#{SLASH}vendor.js"
SRC_DIR = ".#{SLASH}app#{SLASH}src"
VENDOR_DIR = ".#{SLASH}vendor"
VENDOR_SCRIPTS = "#{VENDOR_DIR}#{SLASH}scripts"
VENDOR_DEBUG_SCRIPTS = "#{VENDOR_DIR}#{SLASH}debug_scripts"
VENDOR_STYLES = "#{VENDOR_DIR}#{SLASH}stylesheets"
NODE_DIR = ".#{SLASH}node_modules"
NODE_BIN_DIR = "#{NODE_DIR}#{SLASH}.bin"

Commands =
  COFFEESCRIPT: "coffee#{COMMAND_SUFFIX}"

# List of external third-party JavaScript files that need to be combined in a
# particular order
VENDOR_JS_FILES = [
  'jquery-1.10.2.min.js'
  # 'soundjs-0.4.0.min.js'
  # 'soundjs.flashplugin-0.4.0.min.js'
]

# Flag to make sure we aren't calling build multiple times at once
BUILDING = false
WATCHING = false
BUILD_PASSED = true

coffeeLintConfig =
  no_tabs:
    level: 'error'
  no_trailing_whitespace:
    level: 'error'
  max_line_length:
    value: 85
    level: 'error'
  camel_case_classes:
    level: 'error'
  indentation:
    value: 2
    level: 'error'
  no_implicit_braces:
    level: 'ignore'
  no_trailing_semicolons:
    level: 'error'
  no_plusplus:
    level: 'ignore'
  no_throwing_strings:
    level: 'error'
  no_backticks:
    level: 'warn'
  line_endings:
    value: 'unix'
    level: 'ignore'

# "Enum" of message levels
MessageLevel =
  INFO: 'info'
  WARN: 'warn'
  ERROR: 'error'

###############################################################################
# Helper functions

# Print to console if debugging
debug = (msg) ->
  if DEBUG_MODE
    console.log msg

# Wrapper for handling exec calls
wrappedExec = (cmd, showOutput = false, callback = null) ->
  exec cmd, (err, stdout, stderr) ->
    if (showOutput)
      console.log(stdout.toString().trim())
      console.log(stderr.toString().trim())
    throw err if err
    callback?()

# Check for missing dependencies
checkDep = (callback) ->
  if missingModules.length > 0
    console.log("Please wait while required modules are being installed...")
    installDep(callback)
  else
    callback()

# Install missing dependent modules
installDep = (callback=null) ->
  curModuleNum = 0
  installMissingModules = ->
    if curModuleNum < missingModules.length
      # There are still more modules to load
      moduleName = missingModules[curModuleNum]
      console.log()
      console.log("Installing #{moduleName}...")
      curModuleNum++
      wrappedExec("npm install #{moduleName}", true, installMissingModules)
    else
      # All done! Reload dependencies
      getDependencies()
      # Print success message
      console.log()
      console.log('All modules have been successfully installed!'.green)
      console.log()
      # Empty missing modules
      missingModules = []
      # Call callback function if one was given
      callback?()
  installMissingModules()

# Check to see if a global node module is missing, and if it isn't executes the
# callback
checkGlobalModule = (moduleName, modulePkg, cmd, failOnError, callback) ->
  exec "#{cmd} -h", (err, stdout, stderr) ->
    if err
      if PLATFORM == Platform.WINDOWS
        # Handle Windows errors
        if err.code == 1
          # 1 = "ERROR_INVALID_FUNCTION"
          missingGlobalModule(moduleName, modulePkg, err) if failOnError
      else if err.code == 127
        # 127 = "illegal command"
        missingGlobalModule(moduleName, modulePkg, err) if failOnError
      else
        throw err # Unknown error
    callback not err

# Handle missing global modules
missingGlobalModule = (moduleName, modulePkg, error) ->
  console.error(error.toString().trim().red)
  console.error("#{moduleName} may not be installed correctly".red)
  console.error("Please install using \"npm install -g #{modulePkg}\"".red)
  process.exit(error.code)

# Compile CoffeeScript output to null to check for syntax errors
checkSyntax = (callback) ->
  nulDir = if process.platform == 'win32' then 'nul' else '/dev/null'

  exec "coffee -p -c #{SRC_DIR} > #{nulDir}", (err, stdout, stderr) ->
    if err
      msg = err.toString().trim()
      console.error(msg.red)
      err_pattern = /src.*?\n/
      msg = msg.match(err_pattern)[0]
      if not msg
        msg = "Check terminal for details"
      notify(msg, MessageLevel.ERROR, "Build FAILED") if WATCHING
     callback? not err

# Helper for finding all source files
getSourceFilePaths = (dirPath = SRC_DIR) ->
  files = []
  for file in fs.readdirSync dirPath
    filepath = path.join dirPath, file
    stats = fs.lstatSync filepath
    if stats.isDirectory()
      files = files.concat getSourceFilePaths filepath
    else if /\.coffee$/.test file
      files.push filepath
  files

# Sends a system notification
notify = (message, msgLvl, title='Cake Status') ->
  switch PLATFORM
    when Platform.WINDOWS
      notifu = '.\\vendor\\tools\\notifu'
      time = 5000
      switch msgLvl
        when MessageLevel.INFO
          time = 3000
        when MessageLevel.WARN
          time = 5000
        when MessageLevel.ERROR
          time = 10000
      spawn notifu, ['/p', title, '/m', message, '/t', msgLvl]
    when Platform.LINUX
      cmd = 'notify-send'
      icon = ''
      time = 5000
      switch msgLvl
        when MessageLevel.INFO
          icon += 'dialog-information'
          time = 3000
        when MessageLevel.WARN
          icon += 'dialog-warning'
          time = 5000
        when MessageLevel.ERROR
          icon += 'dialog-error'
          time = 10000
      spawn cmd, ['--hint=int:transient:1', '-i', icon, '-t', time,
        'Cake Status', message]

# Compile vendor scripts and styles
compileVendorFiles = (debug=false)->
  console.log("Combining vendor scripts to #{VENDOR_JS}".yellow)
  if debug
    _compileFiles(VENDOR_DEBUG_SCRIPTS, VENDOR_JS, VENDOR_JS_FILES)
  else
    _compileFiles(VENDOR_SCRIPTS, VENDOR_JS, VENDOR_JS_FILES)

# Helper function for compiling files
_compileFiles = (dir, target, orderedFiles=[]) ->
  text = ''
  for file in orderedFiles
    contents = fs.readFileSync (dir+'/'+file), 'utf8'
    text += contents + "\n"
  for file in fs.readdirSync(dir)
    unless file in orderedFiles
      contents = fs.readFileSync (dir+'/'+file), 'utf8'
      text += contents + "\n"
  try
    fs.writeFile target, text
  catch err
    console.log(err)

# Build source code
buildSource = (options, callback=null) ->
  if not BUILDING
    BUILDING = true
    console.log(
      "Building project from #{SRC_DIR}#{SLASH}*.coffee to #{APP_JS}...".yellow)

    files = new Rehab().process './'+SRC_DIR

    to_single_file = "--join #{APP_JS}"
    from_files = "--compile #{files.join ' '}"
    console.log(SRC_DIR)
    console.log("coffee #{to_single_file} #{from_files}")
    exec "coffee #{to_single_file} #{from_files}",
      (err, stdout, stderr) ->
        if err
          checkSyntax()
        else
          console.log('Build successful!'.green)
          invoke 'lint'
          #invoke 'typecheck'
          callback?()
        BUILDING = false

# Run Coffeelint on source code
lintSource = (options, callback=null) ->
  console.log("Checking #{SRC_DIR}#{SLASH}*.coffee for lint".yellow)
  pass = "✔".green
  warn = "!".yellow
  fail = "✖".red
  if process.platform == 'win32'
    pass = "√".green
    warn = "!".yellow
    fail = "x".red

  failCount = 0
  fileFailCount = 0
  errorCount = 0

  files = getSourceFilePaths()
  filesToLint = files.length
  files.forEach (filepath) ->
    fs.readFile filepath, (err, data) ->
      filesToLint--
      shortPath = filepath.substr SRC_DIR.length + 1
      try
        result = coffeelint.lint data.toString(), coffeeLintConfig
        if result.length
          fileFailCount++
          hasError = result.some (res) -> res.level is 'error'
          level = if hasError then fail else warn
          console.error "#{level}  #{shortPath}".red
          for res in result
            failCount++
            level = if res.level is 'error' then fail else warn
            console.error("   #{level}  Line #{res.lineNumber}: #{res.message}")
        else if options.verbose
          console.log("#{pass}  #{shortPath}".green)
        if filesToLint == 0
          if failCount > 0
            notify("Build succeeded, but #{failCount} lint errors were " +
              "found! Please check the terminal for more details.",
              MessageLevel.ERROR) if WATCHING and BUILD_PASSED
            console.error("\n")
            if errorCount > 0
              console.error(("#{errorCount} syntax error(s) found!").red.bold)
            console.error(("#{failCount} lint error(s) found in " +
              "#{fileFailCount} file(s)!").red.bold)
            console.error("As a reminder:".grey.underline)
            console.error("- Indentation is two spaces. No tabs allowed".grey)
            console.error(("- Maximum line width is " +
              "#{coffeeLintConfig.max_line_length.value} characters").grey)
          else
            notify("Build succeeded. All files passed lint.",
              MessageLevel.INFO) if WATCHING and BUILD_PASSED
            console.log('No lint errors found!'.green)
          console.log("") if WATCHING
          callback?()
      catch e
        errorCount++
        console.error("#{filepath}: #{e}".red)

# Intialize options hash for boolean values
initOptions = (options) ->
  options['verbose'] ?= 'verbose' of options
  options['no-doc'] ?= 'no-doc' of options
  options['port'] ?= null
  return options

###############################################################################
# Options

option '-v', '--verbose', 'Print out verbose output'
option null, '--no-doc', 'Don\'t document the source files when building'
option '-p', '--port [PORT]', 'Specify port to run server on'

###############################################################################
# Tasks

task 'build', 'Build coffee2js using Rehab', (options) ->
  initOptions(options)
  checkDep ->
    compileVendorFiles(true)
    buildSource(options)

task 'build:vendor', 'Combine vendor scripts into one file', ->
  compileVendorFiles()

task 'build:production', 'Compile and minify all scripts', (options) ->
  initOptions(options)
  checkDep ->
    compileVendorFiles()
    buildSource options, ->
      invoke 'minify'

task 'watch', 'Watch all files in src and compile as needed', (options) ->
  initOptions(options)
  WATCHING = true
  watch = tryRequire('node-watch')
  updateMsg = [
    "Cakefile has been updated."
    "Please restart `cake watch` as soon as you can."
  ].join(' ')

  checkDep ->
    console.log("Watching #{SRC_DIR} for changes...".yellow)
    console.log("Watching #{VENDOR_DIR} for changes...".yellow)

    watch = require 'node-watch'
    watch SRC_DIR, ->
      buildSource(options)
    watch VENDOR_DIR, ->
      compileVendorFiles(true)
    watch 'Cakefile', ->
      console.log updateMsg.yellow
      notify updateMsg, MessageLevel.INFO

    # Initial build
    invoke 'build'

task 'minify', 'Minifies all public .js files (requires UglifyJS)', ->
  console.log 'Minifying app.js and vendor.js...'.yellow

  checkGlobalModule 'UglifyJS', 'uglify-js', 'uglifyjs', true, (hasModule = false) ->
    exec "uglifyjs #{APP_JS} -o #{APP_JS}", (err, stdout, stderr) ->
      throw err if err
    exec "uglifyjs #{VENDOR_JS} -o #{VENDOR_JS}", (err, stdout, stderr) ->
      throw err if err

task 'check', 'Temporarily compiles coffee files to check syntax', ->
  checkDep ->
    checkSyntax (passed) ->
      if passed
        console.log("No errors found".green)

task 'typecheck', 'Type check the compiled JavaScript code', ->
  tryRequire('writefile')
  checkDep ->
    try
      fs.mkdirSync('tmp')
    catch e
      null

    TMP_COFFEE_FILE = "tmp#{SLASH}tmp.coffee"
    TMP_JS_FILE = "tmp#{SLASH}tmp.js"
    TMP_GOOGJS_FILE = "tmp#{SLASH}compiled.js"

    files = new Rehab().process './'+SRC_DIR

    typechecker = require './modules/typecheck'

    # Convert Codo-style documentation to jsDoc-compatible documentation and
    # write results to temp file
    console.log('Converting Codo to jsDoc...'.yellow)
    [superclasses, classes, buffer, compFiles] = typechecker.codoToJsdoc(files)

    # Compile CoffeeScript to temporary JavaScript file
    console.log('Compiling source...'.yellow)
    exec "coffee -cb ./tmp/#{SRC_DIR}", (err, stdout, stderr) ->
      console.log stdout if stdout
      console.error err if err

      # Convert CoffeeScript-generated JavaScript to Closure-compatible
      # JavaScript and rewrite to same file
      console.log(
        'Converting compiled JavaScript to Closure-compatible syntax...'.yellow)
      for file in compFiles
        buffer = typechecker.jsToClosure(file, classes, superclasses)
        fs.writeFile file, buffer
      files = compFiles.join(' ')

      # Run Google's Closure Compiler for the type checking features
      console.log('Running Closure type checker...'.yellow)
      cmd = "java"
      args = [
        "-jar vendor#{SLASH}tools#{SLASH}compiler.jar"
        "--js #{files}"
        "--js_output_file #{TMP_GOOGJS_FILE}"
        "--jscomp_error checkTypes"
        #"--externs app#{SLASH}cfg#{SLASH}externs.js"
      ].join(' ')
      exec "#{cmd} #{args}", (err, stdout, stderr) ->
        console.log stdout if stdout
        if stderr
          console.error stderr.red
          if WATCHING
            notify('Type errors found!', MessageLevel.ERROR)
        else
          console.log 'No type errors found!'.green

task 'install-dep', 'Install all necessary node modules', ->
  installDep()

task 'lint', 'Check CoffeeScript for lint using Coffeelint', (options) ->
  initOptions(options)
  checkDep ->
    lintSource(options)

task 'doc', 'Document the source code using Codo', (options) ->
  initOptions(options)
  lastResortCodoFix = (cmd, callback=null) ->
    console.log('Documenting with codo failed'.red)
    try
      process.chdir("#{NODE_DIR}#{SLASH}codo")
      console.log('Attempting to force installation of walkdir v0.0.5...'.yellow)
      exec "npm install walkdir@0.0.5", (err, stdout, stderr) ->
        throw err if err
        process.chdir("..#{SLASH}..")
        console.log('Installation successful'.green)
        console.log('Attempting to run codo again...'.yellow)
        exec cmd, (err, stdout, stderr) ->
          console.log(stdout)
          throw err if err

    catch err
      console.log('chdir: ' + err)

  checkDep ->
    console.log("Documenting CoffeeScript in #{SRC_DIR} to doc...".yellow)
    checkGlobalModule 'Codo', 'codo', 'codo', false, (hasModule = false) ->
      cmd = "#{NODE_BIN_DIR}#{SLASH}codo"
      if options['verbose']
        cmd += ' -v'
      if hasModule
        exec "codo #{SRC_DIR}", (err, stdout, stderr) ->
          console.log(stdout)
          lastResortCodoFix(cmd) if err
      else
        tryRequire('codo')
        checkDep ->
          exec cmd + " " + SRC_DIR, (err, stdout, stderr) ->
            console.log(stdout)
            lastResortCodoFix(cmd) if err
