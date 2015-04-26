coffeelint = require 'gulp-coffeelint'
module.exports = (gulp, gutil, paths) ->
  return ->
    ###
    # Run the coffee source through coffeelint
    ###
    return gulp.src paths.src.coffee
      .pipe coffeelint()
      .pipe coffeelint.reporter()

