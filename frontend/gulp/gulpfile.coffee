
# ==================================
# Imports
# ==================================
gulp                  = require 'gulp'
gutil                 = require 'gulp-util'
bower                 = require 'bower'
concatPlugin          = require 'gulp-concat'
minifyCssPlugin       = require 'gulp-minify-css'
rename                = require 'gulp-rename'
shellPlugin           = require 'shelljs'
coffeePlugin          = require 'gulp-coffee'
ifPlugin              = require 'gulp-if'
cleanPlugin           = require 'del'
karmaPlugin           = require 'gulp-karma'
uglifyPlugin          = require 'gulp-uglify'
htmlMinPlugin         = require 'gulp-minify-html'
plumberPlugin         = require 'gulp-plumber'
watchPlugin           = require 'gulp-watch'
liveReloadPlugin      = require 'gulp-livereload'
includeSourcesPlugin  = require 'gulp-include-source'
minifyImagesPlugin    = require 'gulp-imagemin'
revPlugin             = require 'gulp-rev'
_                     = require 'lodash'
useminPlugin          = require 'gulp-usemin'
obfuscatePlugin       = require 'gulp-obfuscate'
regexReplacePlugin    = require 'gulp-regex-replace'
gulpSassPlugin        = require 'gulp-sass'
fs                    = require 'fs'
findPathsPlugin       = require 'vinyl-paths'


# ==================================
# Path Variables
# ==================================
paths = {}


# ==================================
# Setup
# ==================================

readJSON = (filename) ->
  blob = fs.readFileSync(filename, 'utf8')
  return JSON.parse(blob)


setup = (done) ->
  pathsJSON = readJSON('gulp/paths.json')
  _(paths).extend pathsJSON

  done()


# ==================================
# Common
# ==================================

feedback =

  info : (options) ->
    unless options.name and options.message then throw new Error("#{gutil.colors.red(' === Invalid info feedback === ')}")

    gutil.log """ [#{gutil.colors.cyan(options.name)}] : #{options.message} \n """

  error : (options) ->
    unless options.name and options.message then throw new Error("#{gutil.colors.red('=== Invalid error feedback === ')}")

    gutil.log """ [#{gutil.colors.red(options.name)}] \n
      #{gutil.colors.red(options.message)} \n
    """

  fromWatcher: (options) ->
    unless options.name and options.file then throw new Error("#{gutil.colors.red('=== Invalid fromWatcher feedback === ')}")

    gutil.log """ [#{gutil.colors.cyan(options.name)}] : #{gutil.colors.magenta( _.last(options.file.path.split('/')) )} was changed \n
    """

buildSASS = (options) ->
  gulp.src options.paths
    .pipe plumberPlugin()
    .pipe gulpSassPlugin(
      indentedSyntax: yes
      onError: (error) -> feedback.error(name: 'SASS-ERROR', message: error)
    )
    .pipe rename basename: options.renameTo, extname: options.extensionName
    .pipe gulp.dest options.dest


minifyStyles = (options) ->
  gulp.src options.paths
    .pipe plumberPlugin()
    .pipe rename basename: options.renameTo, extname: options.extensionName
    .pipe minifyCssPlugin keepSpecialComments: 0
    .pipe gulp.dest options.dest

concat = (options) ->
  gulp.src options.paths
    .pipe plumberPlugin()
    .pipe concatPlugin(options.renameTo)
    .pipe gulp.dest options.dest

copy = (options) ->
  gulp.src options.paths
    .pipe gulp.dest options.dest

clean = (paths) ->
  gulp.src(paths)
    .pipe findPathsPlugin(cleanPlugin)



# ==================================
# Vendors
# ==================================

# Install Bower Components
# ======================
install = () ->
 unless shellPlugin.which 'git'
    feedback.error(name : 'GitCheck', message: 'Git is not installed. \n Git, the version control system, is required to download dependencies.')
    process.exit 1

  unless shellPlugin.which('bower')
    feedback.error(name : 'BOWER', message: 'Bower is not installed. \n ..Abort!!')
    process.exit 1

  bower.commands.prune().on 'log', (data) -> feedbak.info( name: 'Bower Prune', message: data.id + data.message)
    .on 'end', ->
      bower.commands.install().on 'log', (data) -> feedbak.info( name: 'Bower Install', message: data.id + data.message)


# ==================================
# Source
# ==================================

# Build CoffeeScript
# ======================
buildAppScripts = () ->
  gulp.src paths.source.coffee.sourceFiles
    .pipe plumberPlugin()
    .pipe coffeePlugin bare: yes
    .on 'error', (error) -> feedback.error(name: 'CoffeeScript-ERROR', message: error)
    .pipe gulp.dest paths.dev.jsDirectory


# Include Sources from a list
# ======================
includeSources = ->
  gulp.src paths.dev.indexFile
    .pipe includeSourcesPlugin({ cwd: paths.dev.directory })
    .pipe gulp.dest(paths.dev.directory)

# ==================================
# Watch files
# ==================================
watch = ->

  # SASS Files
  # ==================
  gulp.watch(paths.source.sass.sourceFiles).on('change', (e) ->
    buildSASS(
      paths         : paths.source.sass.mainSassFile
      renameTo      : 'app'
      extensionName : '.css'
      dest          : paths.dev.cssDirectory
    )
      .on 'end', -> feedback.fromWatcher( name: 'SassWatcher', file: e)
  )

  # Scripts
  # ==================
  gulp.watch(paths.source.coffee.sourceFiles).on('change', (e) ->
    buildAppScripts()
      .on 'end', ->
        # runAppTestsFunction('watch')
        feedback.fromWatcher( name: 'CoffeeWatcher', file: e)
  )

  # HTMLs
  # ==================
  gulp.watch(paths.source.html.sourceFiles).on('change', (e) ->
    copy( paths: paths.source.html.sourceFiles, dest: paths.dev.htmlDirectory )
      .on 'end', -> feedback.fromWatcher( name: 'HtmlWatcher', file: e)
  )

  # Index
  # ==================
  gulp.watch(paths.source.indexFile).on('change', (e) ->
    copy( paths: paths.source.indexFile, dest: paths.dev.directory).on 'end', includeSources
      .on 'end', -> feedback.fromWatcher( name: 'IndexFileWatcher', file: e)
  )

  # Imgs
  # ==================
  gulp.watch(paths.source.img.sourceFiles).on('change', (e) ->
    copy( paths: paths.source.img.sourceFiles, dest: paths.dev.imgDirectory )
      .on 'end', -> feedback.fromWatcher( name: 'ImagesWatcher', file: e)
  )

  # Resources
  # ==================
  gulp.watch(paths.source.resourcesFiles).on('change', (e) ->
    copy( paths: paths.source.resourcesFiles, dest: paths.dev.resourcesDirectory)
      .on 'end', -> copy( paths: paths.source.indexFile, dest: paths.dev.directory).on 'end', includeSources
        .on 'end', -> feedback.fromWatcher( name: 'ResourcesWatcher', file: e)
  )

# ==================================
# Distribuition
# ==================================

# Build index.html
# ======================
proccessIndexFile = ->
  gulp.src(paths.dev.indexFile)
    .pipe(
      useminPlugin(
        js: [
          uglifyPlugin()
        ],
        css: [
          minifyCssPlugin(keepSpecialComments: 0)
        ]
      )
    )
    .pipe(gulp.dest(paths.release.directory))


# Minify Markup
# ======================
minifyMarkupInReleaseFolder = ->
  gulp.src(paths.release.htmlFiles)
    .pipe(htmlMinPlugin(quotes: true, empty: true, spare: true))
    .pipe(gulp.dest(paths.release.htmlDirectory))

  gulp.src(paths.release.indexFile)
    .pipe(htmlMinPlugin(quotes: true, empty: true, spare: true))
    .pipe(gulp.dest(paths.release.directory))

# Optimize Img
# ======================
optimizeImgInReleaseFolder = ->
  gulp.src(paths.release.imgFiles)
    .pipe(minifyImagesPlugin())
    .pipe gulp.dest(paths.release.imgDirectory)


# ==================================
# Spec
# ==================================

# RunAppTests
# ======================
runAppTestsFunction = (actionString) ->
  gulp.src(paths.spec.js.sourceFiles)
    .pipe plumberPlugin()
    .pipe( karmaPlugin
      configFile : 'karma.conf.js'
      action     : actionString
    )

gulp.task 'runAppTests', [], -> runAppTestsFunction('run')




# ==================================
# Register Macro Tasks
# ==================================

# Default
# =======================
gulp.task 'setup'                        , [                          ], setup
gulp.task 'cleanDev'                     , ['setup'                   ], -> clean(paths.dev.directory)
gulp.task 'install'                      , ['setup', 'cleanDev'       ], install

gulp.task 'buildVendorsSASS'             , ['install'                 ], ->
  buildSASS(
    paths         : paths.vendors.sass.mainSassFile
    renameTo      : paths.vendors.css.mainCssFileName
    extensionName : '.css'
    dest          : paths.dev.cssDirectory
  )

gulp.task 'buildVendorsStyles'           , ['buildVendorsSASS'        ], ->
  concat(
    paths: [paths.vendors.css.sourceFiles, paths.dev.vendorsCssFile]
    renameTo: paths.vendors.css.mainCssFileName + '.css'
    dest: paths.dev.cssDirectory
  )

gulp.task 'buildAppStyles'               , ['cleanDev'                ], ->
  buildSASS(
    paths         : paths.source.sass.mainSassFile
    renameTo      : paths.source.css.mainCssFileName
    extensionName : '.css'
    dest          : paths.dev.cssDirectory
  )

gulp.task 'buildVendorsScripts'          , ['install'                 ], -> copy(paths: [paths.vendors.scripts, paths.bowerDirectory], dest: paths.dev.libsDirectory)
gulp.task 'buildAppScripts'              , ['cleanDev'                ], buildAppScripts
gulp.task 'buildMarkup'                  , ['cleanDev'                ], -> copy( paths: paths.source.html.sourceFiles, dest: paths.dev.htmlDirectory )
gulp.task 'copyResourcesToDevFolder'     , ['cleanDev'                ], -> copy( paths: paths.source.resourcesFiles, dest: paths.dev.resourcesDirectory)
gulp.task 'copyImgToDevFolder'           , ['cleanDev'                ], -> copy( paths: paths.source.img.sourceFiles, dest: paths.dev.imgDirectory)
gulp.task 'copyIndexToDevFolder'         , ['copyResourcesToDevFolder', 'buildAppScripts'], -> copy( paths: paths.source.indexFile, dest: paths.dev.directory).on 'end', includeSources
gulp.task 'runDevTests'                  , ['buildAppScripts', 'buildVendorsScripts'], -> runAppTestsFunction('run')



gulp.task 'default', [
  'setup'
  'cleanDev'
  'install'
  'buildVendorsSASS'
  'buildVendorsStyles'
  'buildVendorsScripts'
  'buildAppStyles'
  'buildAppScripts'
  'buildMarkup'
  'copyResourcesToDevFolder'
  'copyImgToDevFolder'
  'copyIndexToDevFolder'
  # 'runDevTests'
]


# Dev tasks
# =======================
gulp.task 'watch'     , ['default'], watch
gulp.task 'dev'       , ['watch'], -> runAppTestsFunction('watch')
gulp.task 'buildDev'  , ['default']


# Release tasks
# =======================
gulp.task 'cleanRelease'                  , ['default'                  ], -> clean(paths.release.directory)
gulp.task 'proccessIndexFile'             , ['cleanRelease'             ], proccessIndexFile
gulp.task 'copyMarkupToReleaseFolder'     , ['proccessIndexFile'        ], -> copy( paths: paths.source.html.sourceFiles, dest: paths.release.htmlDirectory)
gulp.task 'minifyMarkupInReleaseFolder'   , ['copyMarkupToReleaseFolder'], minifyMarkupInReleaseFolder
gulp.task 'copyCssToReleaseFolder'        , ['cleanRelease'             ], -> copy( paths: paths.dev.cssFiles, dest: paths.release.cssDirectory)
gulp.task 'copyImgToReleaseFolder'        , ['cleanRelease'             ], -> copy( paths: paths.dev.imgFiles, dest: paths.release.imgDirectory)
gulp.task 'optimizeImgInReleaseFolder'    , ['copyImgToReleaseFolder'   ], optimizeImgInReleaseFolder
gulp.task 'copyResourcesToReleaseFolder'  , ['cleanRelease'             ], -> copy( paths: paths.dev.resourcesFiles , dest: paths.release.resourcesDirectory )

gulp.task 'buildRelease', [
  'default'
  'cleanRelease'
  'proccessIndexFile'
  'copyMarkupToReleaseFolder'
  'minifyMarkupInReleaseFolder'
  'copyCssToReleaseFolder'
  'copyImgToReleaseFolder'
  'optimizeImgInReleaseFolder'
  'copyResourcesToReleaseFolder'
]
gulp.task 'release', [ 'buildRelease' ]


# Release Server Test
# =======================
gulp.task 'buildToServerTest' , ['default']

# Test tasks
# =======================
gulp.task 'buildVendorsScriptsToTests'          , [ 'install'             ], -> copy(paths: [paths.vendors.scripts, paths.bowerDirectory], dest: paths.dev.libsDirectory)
gulp.task 'buildAppScriptsToTests'              , [ 'setup'               ], buildAppScripts

gulp.task 'test'          , ['buildVendorsScriptsToTests', 'buildAppScriptsToTests'], -> runAppTestsFunction('watch')
gulp.task 'spec'          , ['test']
gulp.task 'watchTests'    , ['test']
gulp.task 'debugTests'    , ['test']


