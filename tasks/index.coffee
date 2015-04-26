gulp = require 'gulp'
gutil = require 'gulp-util'
paths = require('cson').parseCSONFile('tasks/config/paths.cson')

module.exports = (tasks) ->
  # Loop through each task name
  for name in tasks
    task = require './' + name
    # Define the task and include the file
    gulp.task name, task(gulp, gutil, paths)

  return gulp
