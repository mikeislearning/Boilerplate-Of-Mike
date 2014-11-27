#-----------------------------------------------------------------
# Setup
#-----------------------------------------------------------------
server          = false
fs              = require('fs')
path            = require('path')
exec            = require('exec')

gulp       			= require('gulp')
plugins    			= require('gulp-load-plugins')()

bower      			= require('main-bower-files')
ecstatic   			= require('ecstatic')
es         			= require('event-stream')
jade            = require('jade')
lr         			= require('tiny-lr')
pngcrush   			= require('imagemin-pngcrush')

reloadServer = lr()

#-----------------------------------------------------------------
# Paths
#-----------------------------------------------------------------

SOURCE = './src/'
DESTINATION = './app/'


paths =
  scripts:
    source: SOURCE + 'coffee/main.coffee'
    destination: DESTINATION + '/js/'
    filename: 'bundle.js'
  templates:
    source: SOURCE + '*.html'
    watch:  SOURCE + '*.html'
    destination: DESTINATION
  styles:
    source: SOURCE + 'stylus/style.styl'
    watch: SOURCE + 'stylus/*.styl'
    destination: DESTINATION + '/css/'
  assets:
    source: SOURCE + 'assets/**/*.*'
    watch: SOURCE + 'assets/**/*.*'
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
# Templates
#-----------------------------------------------------------------

gulp.task 'templates', ->
  pipeline = gulp
    .src paths.templates.source
    .pipe(jade(pretty: not production))
    .on 'error', handleError
    .pipe gulp.dest paths.templates.destination

  pipeline = pipeline.pipe livereload(auto: false) unless production



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
# Images
#-----------------------------------------------------------------

gulp.task 'images', () ->
	gulp
		.src paths.images.source
		.pipe(plugins.imagemin({ progressive: true, use: [pngcrush()]	}))
		.pipe gulp.dest paths.images.destination


#-----------------------------------------------------------------
# Server and Watcher
#-----------------------------------------------------------------

gulp.task 'server', () ->
	require('http')
		.createServer ecstatic root: __dirname
		.listen 9001

gulp.task 'watch', () ->
	reloadServer.listen 35729

	gulp.watch(paths.templates.watch, ['templates']).on('error', errorHandler)
	gulp.watch(paths.styles.watch, ['styles']).on('error', errorHandler)
	gulp.watch(paths.images.watch, ['images']).on('error', errorHandler)
	gulp.watch(paths.scripts.watch, ['scripts']).on('error', errorHandler)


gulp.task "build", ['scripts', 'templates', 'styles', 'images']
gulp.task "default", ['build', 'watch', 'server']
# gulp.task "default", ['build', 'watch', 'server']
gulp.task "go", ['watch', 'server']
