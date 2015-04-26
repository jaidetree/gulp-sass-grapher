_ = require 'underscore'
assert = require 'assert'
css = require 'css'
fs = require 'fs'
grapher = require 'sass-graph'
gulp = require 'gulp'
path = require 'path'
sass = require 'gulp-sass'
sassGrapher = require '../src/index'
through = require 'through2'

graph = null

loadPaths = ['./test/fixtures']

paths =
  sass: 'test/fixtures/**/*.scss'
  sassDir: 'test/fixtures'
  singleSassPartial: 'test/fixtures/_a.scss'
  singleSassFile: 'test/fixtures/single.scss'
  partialFileTest: 'test/fixtures/partials/_a.scss'
  oneLayerSassFile: 'test/fixtures/_a.scss'
  twoLayerSassFile: 'test/fixtures/_b.scss'
  threeLayerSassFile: 'test/fixtures/_c.scss'
  output: 'test/output'

options =
  loadPaths: loadPaths

parseCSS = (cssText) ->
  assert.ok cssText
  return css.parse cssText

describe 'Gulp SASS Graph', ->
  describe 'sass-graph', ->
    it 'should work', (done) ->
      graph = grapher.parseDir(path.resolve(paths.sassDir), options)
      ancestors = graph.visitAncestors path.resolve(paths.singleSassPartial), (filepath, data) ->
        assert.equal path.basename(filepath), 'single.scss'
        done()


  describe 'gulp-sass-grapher', ->
    it 'should be an instance of SassGrapher', ->
      assert.equal sassGrapher instanceof sassGrapher.SassGrapher, true, 'Sass Grapher was not initiated correctly'

    it 'should have an init method', ->
      assert.equal typeof sassGrapher.init, 'function', 'SassGrapher.init was not a function'

    it 'should have an ancestors method', ->
      assert.equal typeof sassGrapher.ancestors, 'function', 'SassGrapher.ancestors was not a function'

    it 'should compile the parent file', (done) ->
      sassGrapher.init paths.sassDir, options

      gulp.src(paths.singleSassPartial, { base: path.resolve('test/fixtures') })
        .pipe sassGrapher.ancestors()
        .pipe sass(
          includePaths: loadPaths
        )
        .pipe gulp.dest(paths.output)
        .pipe through.obj (file, enc, next) ->
          cssData = parseCSS(file.contents.toString())
          assert.equal cssData.stylesheet.rules.length, 2, 'Other than 2 css rules in output'
          done()

    it 'should compile the root file', (done) ->
      sassGrapher.init paths.sassDir, options

      gulp.src(paths.singleSassFile, { base: path.resolve('test/fixtures') })
        .pipe sassGrapher.ancestors()
        .pipe sass(
          includePaths: loadPaths
        )
        .pipe gulp.dest(paths.output)
        .pipe through.obj (file, enc, next) ->
          cssData = parseCSS(file.contents.toString())
          assert.equal cssData.stylesheet.rules.length, 2, 'Other than 2 css rules in output'
          next()
          done()
  
    it 'should find the nested root', (done) ->
      sassGrapher.init paths.sassDir, options
      gulp.src(paths.partialFileTest, { base: path.resolve('test/fixtures') })
        .pipe sassGrapher.ancestors()
        .pipe sass(
          includePaths: loadPaths
        )
        .pipe gulp.dest(paths.output)
        .pipe through.obj (file, enc, next) ->
          cssData = parseCSS(file.contents.toString())
          assert.equal cssData.stylesheet.rules.length, 3, 'Other than 3 css rules in output'
          next()
          done()


  describe 'Nested Files', ->
    files = [
      paths.oneLayerSassFile
      paths.twoLayerSassFile
      paths.threeLayerSassFile
    ]

    _.each files, (filepath, i) ->
      it 'should compile the root file ' + (i + 1) + ' layer(s) deep', (done) ->
        sassGrapher.init paths.sassDir, options
        gulp.src(filepath, { base: path.resolve('test') })
          .pipe sassGrapher.ancestors()
          .pipe sass(
            includePaths: loadPaths
          )
          .pipe gulp.dest(paths.output)
          .pipe through.obj (file, enc, next) ->
            cssText = file.contents.toString()
            assert.notEqual cssText.indexOf('background: '), -1, 'Could not find background in resulting CSS'
            done()

          
