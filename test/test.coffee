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
basePath = path.resolve('test/fixtures')
sassDir = path.resolve('test/fixtures')
files =
  sass: sassDir + '/**/*.scss'
  sassDir: sassDir
  singleSassPartial: sassDir + '/_a.scss'
  singleSassFile: sassDir + '/single.scss'
  partialFileTest: sassDir + '/partials/_a.scss'
  oneLayerSassFile: sassDir + '/_a.scss'
  twoLayerSassFile: sassDir + '/_b.scss'
  threeLayerSassFile: sassDir + '/_c.scss'
  output: 'test/output'

options =
  loadPaths: loadPaths

parseCSS = (cssText) ->
  assert.ok cssText
  return css.parse cssText

describe 'Gulp SASS Graph', ->
  describe 'sass-graph', ->
    it 'should work', (done) ->
      ancestors = []
      graph = grapher.parseDir(files.sassDir, options)
      graph.visitAncestors files.singleSassPartial, (filepath, data) ->
        ancestors.push(filepath)
      assert.equal(ancestors.length, 1)
      done()


  describe 'gulp-sass-grapher', ->
    it 'should be an instance of SassGrapher', ->
      assert.equal sassGrapher instanceof sassGrapher.SassGrapher, true, 'Sass Grapher was not initiated correctly'

    it 'should have an init method', ->
      assert.equal typeof sassGrapher.init, 'function', 'SassGrapher.init was not a function'

    it 'should have an ancestors method', ->
      assert.equal typeof sassGrapher.ancestors, 'function', 'SassGrapher.ancestors was not a function'

    it 'should compile the parent file', (done) ->
      sassGrapher.init files.sassDir, options

      gulp.src(files.singleSassPartial, { base: basePath })
        .pipe sassGrapher.ancestors()
        .pipe sass(
          includePaths: loadPaths
        )
        .pipe gulp.dest(files.output)
        .pipe through.obj (file, enc, next) ->
          cssData = parseCSS(file.contents.toString())
          assert.equal cssData.stylesheet.rules.length, 2, 'Other than 2 css rules in output'
          done()

    it 'should compile the root file', (done) ->
      sassGrapher.init files.sassDir, options

      gulp.src(files.singleSassFile, { base: basePath })
        .pipe sassGrapher.ancestors()
        .pipe sass(
          includePaths: loadPaths
        )
        .pipe gulp.dest(files.output)
        .pipe through.obj (file, enc, next) ->
          cssData = parseCSS(file.contents.toString())
          assert.equal cssData.stylesheet.rules.length, 2, 'Other than 2 css rules in output'
          next()
          done()
  
    it 'should find the nested root', (done) ->
      sassGrapher.init files.sassDir, options
      gulp.src(files.partialFileTest, { base: basePath })
        .pipe sassGrapher.ancestors()
        .pipe sass(
          includePaths: loadPaths
        )
        .pipe gulp.dest(files.output)
        .pipe through.obj (file, enc, next) ->
          cssData = parseCSS(file.contents.toString())
          assert.equal cssData.stylesheet.rules.length, 3, 'Other than 3 css rules in output'
          next()
      done()


  describe 'Nested Files', ->
    fileList = [
      files.oneLayerSassFile
      files.twoLayerSassFile
      files.threeLayerSassFile
    ]

    _.each fileList, (filepath, i) ->
      it 'should compile the root file ' + (i + 1) + ' layer(s) deep', (done) ->
        sassGrapher.init files.sassDir, options
        gulp.src(filepath, { base: path.resolve('test') })
          .pipe sassGrapher.ancestors()
          .pipe sass(
            includePaths: loadPaths
          )
          .pipe gulp.dest(files.output)
          .pipe through.obj (file, enc, next) ->
            cssText = file.contents.toString()
            assert.notEqual cssText.indexOf('background: '), -1, 'Could not find background in resulting CSS'
            done()

          
