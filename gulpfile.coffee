gulp = require 'gulp'

require('./tasks')([
  'coffee'
  'lint'
  'test'
  'watch'
])

gulp.task 'default', [ 'coffe', 'watch' ]
