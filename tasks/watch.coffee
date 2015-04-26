module.exports = (gulp, gutil, paths) ->
  return ->
    gulp.watch(paths.watch.coffee, ['lint', 'coffee'])
