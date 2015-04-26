# Gulp Sass Grapher
A gulp plugin for passing only the root SASS files down the stream. Unlike other plugins this one accounts for rebuilding the graph index when new files are added along with a manual API to rebuild the index.

## Example

```javascript
  var sassGrapher = require('gulp-sass-grapher'),
    gulp = require('gulp'),
    path = require('path'),
    watch = require('gulp-watch');

  gulp.task('watch-styles', function() {
    var loadPaths = path.resolve('src/sass');
    sassGrapher.init('src/sass', { loadPaths: loadPaths })
    return watch('src/sass/**/*.scss', { base: path.resolve('src/sass') })
      .pipe(sassGrapher.ancestors())
      .pipe(sass({
        includePath: loadPaths
      }))
      .pipe(gulp.dest('dist/css'))
  })
```
