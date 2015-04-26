mocha = require 'gulp-mocha'

module.exports = (gulp, gutil, paths) ->
  return ->
    gulp.src(paths.tests)
      .pipe mocha(
        bail: true
      )
