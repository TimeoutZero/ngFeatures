
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
cleanPlugin           = require 'gulp-clean'
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
# Vendors
# ==================================

# Check git installation
# ======================
gitCheck = (done) ->
  unless shellPlugin.which 'git'
    gutil.log("""
      #{gutil.colors.red('Git is not installed.')}
      \n Git, the version control system, is required to download dependencies."""
    )
    process.exit 1
  done()

# Install Bower Components
# ======================
install = () ->
  unless shellPlugin.which('bower')
    gutil.log gutil.colors.red '=== BOWER IS NOT INSTALLED === ..Abort!!'
    process.exit 1

  bower.commands.prune()
    .on 'log', (data) ->
      gutil.log '[Bower Prune]', gutil.colors.cyan data.id, data.message

  bower.commands.install()
    .on 'log', (data) ->
      gutil.log '[Bower Install]', gutil.colors.cyan data.id, data.message


# Build SASS
# ======================
buildVendorsSASS = ->
  gulp.src paths.vendors.sass.mainSassFile
    .pipe gulpSassPlugin(indentedSyntax: yes)
    .pipe minifyCssPlugin keepSpecialComments: 0
    .pipe rename basename: 'vendors', extname: '.min.css'
    .pipe gulp.dest paths.dev.cssDirectory

# Build CSS
# ======================
buildVendorsStyles = ->
  gulp.src [paths.vendors.css.sourceFiles, paths.dev.vendorsCssFile]
    .pipe concatPlugin('vendors')
    .pipe minifyCssPlugin keepSpecialComments: 0
    .pipe rename basename: 'vendors', extname: '.min.css'
    .pipe gulp.dest paths.dev.cssDirectory


buildVendorsScripts = ->
  gulp.src paths.vendors.scripts
    .pipe gulp.dest(paths.dev.libsDirectory)

  gulp.src paths.bowerDirectory
    .pipe gulp.dest(paths.dev.libsDirectory)

# ==================================
# Source
# ==================================

# Build SASS
# ======================
buildAppStyles = () ->
  gulp.src paths.source.sass.mainSassFile
    .pipe plumberPlugin()
    .pipe gulpSassPlugin(
      indentedSyntax: yes
      onError: (error) -> console.log("\n #{gutil.colors.red('=== [SASS-ERROR] ===')} \n\n #{gutil.colors.red(error)}")
    )
    .pipe minifyCssPlugin keepSpecialComments: 0
    .pipe rename basename: "app", extname: '.min.css'
    .pipe gulp.dest paths.dev.cssDirectory

# Build CoffeeScript
# ======================
buildAppScripts = () ->
  gulp.src paths.source.coffee.sourceFiles
    .pipe plumberPlugin()
    .pipe coffeePlugin bare: yes
    .on 'error', gutil.log
    .pipe gulp.dest paths.dev.jsDirectory

# Build HTML
# ======================
buildMarkup = ->
  gulp.src(paths.source.html.sourceFiles)
    .pipe gulp.dest(paths.dev.htmlDirectory)

# Copy Resources
# ======================
copyResourcesToDevFolder = ->
  gulp.src(paths.source.resourcesFiles)
    .pipe gulp.dest(paths.dev.resourcesDirectory)

# Copy Images to Dist
# ======================
copyImgToDevFolder = ->
  gulp.src(paths.source.img.sourceFiles)
    .pipe gulp.dest(paths.dev.imgDirectory)

# Copy index.html
# ======================
copyIndexToDevFolder = ->
  gulp.src(paths.source.indexFile)
    .pipe gulp.dest(paths.dev.directory)
    .on 'end', includeSources

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
    buildAppStyles()
      .on 'end', ->
        gutil.log( gutil.colors.red('[SassWatcher] ') + gutil.colors.magenta( _.last(e.path.split('/')) ) + ' was changed' )
  )

  # Scripts
  # ==================
  gulp.watch(paths.source.coffee.sourceFiles).on('change', (e) ->
    buildAppScripts()
      .on 'end', ->
        runAppTestsFunction('run')
        gutil.log( gutil.colors.red('[CoffeeWatcher] ') + gutil.colors.magenta( _.last(e.path.split('/')) ) + ' was changed' )
  )

  # HTMLs
  # ==================
  gulp.watch(paths.source.html.sourceFiles).on('change', (e) ->
    buildMarkup()
      .on 'end', ->
        gutil.log( gutil.colors.red('[HtmlWatcher] ') + gutil.colors.magenta( _.last(e.path.split('/')) ) + ' was changed' )
  )

  # Index
  # ==================
  gulp.watch(paths.source.indexFile).on('change', (e) ->
    copyIndexToDevFolder()
      .on 'end', ->
        gutil.log( gutil.colors.red('[IndexFileWatcher] ') + gutil.colors.magenta( _.last(e.path.split('/')) ) + ' was changed' )
  )


  # Imgs
  # ==================
  gulp.watch(paths.source.img.sourceFiles).on('change', (e) ->
    copyImgToDevFolder()
      .on 'end', ->
        gutil.log( gutil.colors.red('[CopyImgToDevFolder] ') + gutil.colors.magenta( _.last(e.path.split('/')) ) + ' was changed' )
  )

  # Resources
  # ==================
  gulp.watch(paths.source.resourcesFiles).on('change', (e) ->
    copyResourcesToDevFolder()
      .on 'end', ->
        copyIndexToDevFolder()
        .on 'end', ->
          gutil.log( gutil.colors.red('[CopyResourcesToDevFolder] ') + gutil.colors.magenta( _.last(e.path.split('/')) ) + ' was changed' )
  )

# ==================================
# Distribuition
# ==================================

# Clean Dist Directories
# ======================
cleanDev = ->
  gulp.src(paths.dev.directory)
    .pipe cleanPlugin(force: yes)

cleanDevScriptsDirectory = ->
  gulp.src(paths.dev.jsDirectory)
    .pipe cleanPlugin(force: yes)

# Clean Release Directories
# ======================
cleanRelease = ->
  gulp.src(paths.release.directory)
    .pipe cleanPlugin(force: yes)

# ==================================
# Build
# ==================================

# Build index.html
# ======================
proccessIndexFile = ->
  gulp.src(paths.dev.indexFile)
    .pipe(
      useminPlugin(
        js: [
          uglifyPlugin()
        ]
      )
    )
    .pipe(gulp.dest(paths.release.directory))

# Copy Markup
# ======================
copyMarkupToReleaseFolder = ->
  gulp.src(paths.dev.htmlFiles)
    .pipe gulp.dest(paths.release.htmlDirectory)

# Minify Markup
# ======================
minifyMarkupInReleaseFolder = ->
  gulp.src(paths.release.htmlFiles)
    .pipe(htmlMinPlugin(quotes: true, empty: true, spare: true))
    .pipe(gulp.dest(paths.release.htmlDirectory))

  gulp.src(paths.release.indexFile)
    .pipe(htmlMinPlugin(quotes: true, empty: true, spare: true))
    .pipe(gulp.dest(paths.release.directory))

# Copy CSS
# ======================
copyCssToReleaseFolder = ->
  gulp.src(paths.dev.cssFiles)
    .pipe gulp.dest(paths.release.cssDirectory)

# Copy Img
# ======================
copyImgToReleaseFolder = ->
  gulp.src(paths.dev.imgFiles)
    .pipe gulp.dest(paths.release.imgDirectory)

# Optimize Img
# ======================
optimizeImgInReleaseFolder = ->
  gulp.src(paths.release.imgFiles)
    .pipe(minifyImagesPlugin())
    .pipe gulp.dest(paths.release.imgDirectory)

# Copy Resources
# ======================
copyResourcesToReleaseFolder = ->
  gulp.src(paths.dev.resourcesFiles.fonts)
    .pipe gulp.dest(paths.release.resourcesDirectory.fonts)

  gulp.src(paths.dev.resourcesFiles.videos)
    .pipe gulp.dest(paths.release.resourcesDirectory.videos)


# Ofuscates Javascript
# ======================
ofuscateJSFiles = ->
  gulp.src paths.release.jsFiles
    .pipe obfuscatePlugin(
      exclude       : ['angular', '_', '$', 'jQuery', 'videojs', '_V_', 'FB', '$injector']
    )
    .pipe gulp.dest(paths.release.jsDirectory)



# ==================================
# Spec
# ==================================

# RunAppTests
# ======================
runAppTestsFunction = (actionString) ->
  gulp.src(paths.spec.js.sourceFiles)
    .pipe( karmaPlugin
      configFile: 'karma.conf.js'
      action    : actionString
    )
    .on 'error', (err) ->
      console.log 'runAppTests: ' + err

gulp.task 'runAppTests', [], -> runAppTestsFunction('run')
  



# ==================================
# Register Macro Tasks
# ==================================

# Dev Distribuition tasks
# =======================
gulp.task 'setup'                        , [                          ], setup
gulp.task 'cleanDev'                     , ['setup'                   ], cleanDev
gulp.task 'gitCheck'                     , ['cleanDev'                ], gitCheck
gulp.task 'install'                      , ['gitCheck'                ], install
gulp.task 'buildVendorsSASS'             , ['install'                 ], buildVendorsSASS
gulp.task 'buildVendorsStyles'           , ['buildVendorsSASS'        ], buildVendorsStyles
gulp.task 'buildVendorsScripts'          , ['install'                 ], buildVendorsScripts
gulp.task 'buildAppStyles'               , ['cleanDev'                ], buildAppStyles
gulp.task 'buildAppScripts'              , ['cleanDev'                ], buildAppScripts
gulp.task 'buildMarkup'                  , ['cleanDev'                ], buildMarkup
gulp.task 'copyResourcesToDevFolder'     , ['cleanDev'                ], copyResourcesToDevFolder
gulp.task 'copyImgToDevFolder'           , ['cleanDev'                ], copyImgToDevFolder
gulp.task 'copyIndexToDevFolder'         , ['copyResourcesToDevFolder'], copyIndexToDevFolder
gulp.task 'runDevTests'                  , ['buildAppScripts', 'buildVendorsScripts'], -> runAppTestsFunction('run')



gulp.task 'default', [
  'cleanDev'
  'gitCheck'
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
  'runDevTests'
]


# Dev tasks
# =======================
gulp.task 'watch'     , ['default'], watch
gulp.task 'dev'       , ['watch']
gulp.task 'buildDev'  , ['default']


# Release tasks
# =======================
gulp.task 'cleanRelease'                  , ['default'                  ], cleanRelease
gulp.task 'proccessIndexFile'             , ['cleanRelease'             ], proccessIndexFile
gulp.task 'copyMarkupToReleaseFolder'     , ['proccessIndexFile'        ], copyMarkupToReleaseFolder
gulp.task 'minifyMarkupInReleaseFolder'   , ['copyMarkupToReleaseFolder'], minifyMarkupInReleaseFolder
gulp.task 'copyCssToReleaseFolder'        , ['cleanRelease'             ], copyCssToReleaseFolder
gulp.task 'copyImgToReleaseFolder'        , ['cleanRelease'             ], copyImgToReleaseFolder
gulp.task 'optimizeImgInReleaseFolder'    , ['copyImgToReleaseFolder'   ], optimizeImgInReleaseFolder
gulp.task 'copyResourcesToReleaseFolder'  , ['cleanRelease'             ], copyResourcesToReleaseFolder
gulp.task 'ofuscateJSFiles'               , ['proccessIndexFile'        ], ofuscateJSFiles


gulp.task 'buildRelease', [
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
gulp.task 'test'          , [], -> runAppTestsFunction('watch')
gulp.task 'spec'          , ['test']

gulp.task 'watchTests'          , [], -> runAppTestsFunction('watch')
gulp.task 'debugTests'          , ['test']
# gulp.task 'testAndWatch'  , ['test', 'watchSpecs']


