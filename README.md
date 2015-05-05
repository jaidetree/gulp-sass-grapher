
# Gulp Sass Grapher [![Build Status][travis-image]][travis-url] [![NPM version][npm-image]][npm-url]
[![Dependency Status][depstat-image]][depstat-url] [![devDependency Status][devdepstat-image]][devdepstat-url]

A gulp plugin for passing only the root SASS files down the stream. Unlike other plugins this one accounts for rebuilding the graph index when new files are added along with a manual API to rebuild the index.

> [Sass Graph](https://github.com/xzyfer/sass-graph) plugin for [gulp][gulp] 3.

## Install

Install with [npm](https://npmjs.org/package/gulp-sass-graph)

```
npm install --save-dev gulp-sass-grapher
```

## Example

Here is an example using gulp-sass-grapher with gulp-watch.

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


[gulp]: http://gulpjs.com/
[npm-url]: https://npmjs.org/package/gulp-coffeelint
[npm-image]: http://img.shields.io/npm/v/gulp-coffeelint.svg

[travis-url]: http://travis-ci.org/jayzawrotny/gulp-sass-grapher
[travis-image]: https://travis-ci.org/jayzawrotny/gulp-sass-grapher.svg?branch=master

[depstat-url]: https://david-dm.org/jayzawrotny/gulp-sass-grapher
[depstat-image]: https://david-dm.org/jayzawrotny/gulp-sass-grapher.svg

[devdepstat-url]: https://david-dm.org/jayzawrotny/gulp-sass-grapher#info=devDependencies
[devdepstat-image]: https://david-dm.org/jayzawrotny/gulp-sass-grapher/dev-status.svg
