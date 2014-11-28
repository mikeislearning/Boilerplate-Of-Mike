#-----------------------------------------------------------------
# Setup
#-----------------------------------------------------------------
server          = false
production      = false
fs              = require('fs')
path            = require('path')
exec            = require('exec')

gulp            = require('gulp')
plugins         = require('gulp-load-plugins')()

bower           = require('main-bower-files')
ecstatic        = require('ecstatic')
es              = require('event-stream')
jade            = require('jade')
lr              = require('tiny-lr')
pngcrush        = require('imagemin-pngcrush')

reloadServer = lr()

#-----------------------------------------------------------------
# Paths
#-----------------------------------------------------------------

SOURCE = './src/'
DESTINATION = './public/'


paths =
  scripts:
    source: SOURCE + 'coffee/*.coffee'
    watch: SOURCE + 'coffee/*.coffee'
    destination: DESTINATION + '/js/'
  templates:
    source: SOURCE + 'templates/*.html'
    watch:  SOURCE + 'templates/*.html'
    destination: DESTINATION
  styles:
    source: SOURCE + 'stylus/style.styl'
    watch: SOURCE + 'stylus/*.styl'
    destination: DESTINATION + '/css/'
  images:
    source: SOURCE + 'img/**/*.*'
    watch: SOURCE + 'img/**/*.*'
    destination: DESTINATION + '/img/'

# --------------------------------------
# Handlers
# --------------------------------------

errorHandler = (error) ->
  console.log(plugins.util.log)

serverHandler = () ->
  console.log('Started Server...')

templateHandler = (error) ->
  console.log('Template Error: ', error) if error

fileHandler = (error) ->
  console.log('File Error: ', error) if error

#-----------------------------------------------------------------
# Templates
#-----------------------------------------------------------------

gulp.task 'templates', ->

  gulp.src(paths.templates.source)
    .pipe(gulp.dest(paths.templates.destination))
    .pipe(plugins.livereload(reloadServer))

#-----------------------------------------------------------------
# Styles
#-----------------------------------------------------------------

gulp.task 'styles', () ->
  # Define

  libs = gulp.src(bower())

  main = gulp.src(paths.styles.source).pipe(plugins.stylus(use: [require('nib')(), require('jeet')()]))

  # Create Libs
  libs
    .pipe(plugins.rename('libs.min.css'))
    .pipe(plugins.minifyCss())
    .on('error', errorHandler)
    .pipe(gulp.dest(paths.styles.destination))

  # Create Main
  main
    .pipe(plugins.rename('main.min.css'))
    .pipe(plugins.minifyCss())
    .on('error', errorHandler)
    .pipe(gulp.dest(paths.styles.destination))
    .pipe plugins.livereload(reloadServer)
#-----------------------------------------------------------------
# Scripts
#-----------------------------------------------------------------

gulp.task 'scripts', () ->

  # Define
  libs    = gulp.src(bower())
  main    = gulp.src(paths.scripts.source).pipe(plugins.coffee( bare: true ))

  # Create Libs
  es.concat(libs)
    .pipe(plugins.concat('libs.min.js'))
    .pipe(plugins.uglify())
    .on('error', errorHandler)
    .pipe(gulp.dest(paths.scripts.destination))

  # Create Main
  main
    .pipe(plugins.concat('main.min.js'))
    .pipe(plugins.uglify())
    .on('error', errorHandler)
    .pipe(gulp.dest(paths.scripts.destination))
    .pipe(plugins.livereload(reloadServer))


#-----------------------------------------------------------------
# Images
#-----------------------------------------------------------------

gulp.task 'images', () ->
  gulp
    .src paths.images.source
    .pipe(plugins.imagemin({ progressive: true, use: [pngcrush()] }))
    .pipe gulp.dest paths.images.destination

#-----------------------------------------------------------------
# Server
#-----------------------------------------------------------------
gulp.task 'server', ->
  require('http')
    .createServer ecstatic root: path.join(__dirname, 'public')
    .listen 9000
#-----------------------------------------------------------------
# Watch
#-----------------------------------------------------------------
gulp.task 'watch', ->
  reloadServer.listen 35729

  gulp.watch paths.templates.watch, ['templates']
  gulp.watch paths.styles.watch, ['styles']
  gulp.watch paths.images.watch, ['images']
  gulp.watch paths.scripts.watch, ['scripts']


gulp.task "build", ['scripts', 'templates', 'styles', 'images']
gulp.task "default", ['build', 'watch', 'server']
gulp.task "go", ['watch', 'server']
