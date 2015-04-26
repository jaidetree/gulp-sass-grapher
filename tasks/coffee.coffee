coffee = require 'gulp-coffee'

module.exports = (gulp, gutil, paths) ->
  return ->
    ###
    # Compile the Express app coffeescript for production
    ###
    return gulp.src paths.src.coffee
      .pipe coffee().on 'error', gutil.log
      .pipe gulp.dest(paths.build.coffee)

