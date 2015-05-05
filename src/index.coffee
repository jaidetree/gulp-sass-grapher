# Gulp Sass Grapher

# Require our modules
File = require 'vinyl'
fs = require 'fs'
grapher = require 'sass-graph'
path = require 'path'
through = require 'through2'

# Lets get to it!

error = (message) ->
  return new gutil.PluginError('gulp-sass-grapher', message)

class SassGrapher
  ###
  # Ancestors
  # Gets the root level sass files to process
  # Returns a through transform stream
  ###
  ancestors: ->
    self = this
    graph = @graph
    return through.obj (file, enc, next) ->
      hasImports = false
      stream = this

      if file.isNull()
        this.push file
        return next()

      if file.isStream()
        this.emit('error', error('Streaming not supported'))
        this.push file
        return next()

      if file.event && file.event == 'add'
        graph = self.reconstruct()

      # What if we are given a root file?
      sassData = self.graph.index[file.path]

      # If the file is not indexed, try rebuilding the graph
      if !sassData
        graph = self.reconstruct()
        sassData = graph.index[file.path]

      # If the file is not indexed and is not imported by anything just
      # pass it along
      if !sassData || sassData.importedBy.length == 0
        this.push file
        return next()

      # Push the most parential files to the stream otherwise recursively
      # trace up the ancestors.
      getAncestors = (childFilepath) ->
        self.graph.visitAncestors childFilepath, (filepath) ->
          # If it's a partial, skip adding it.
          if path.basename(filepath).slice(0, 1) == '_'
            return

          hasImports = true
        
          # Push the root scss file down the stream
          stream.push(new File(
            cwd: file.cwd
            base: path.dirname(filepath)
            path: filepath
            contents: new Buffer(fs.readFileSync(filepath, 'utf8'))
          ))

      # Get the ancestors
      getAncestors(file.path)

      # If nothing imports this file, just pass it along
      if !hasImports
        this.push file

      next()

  ###
  # Init
  # Method for creating the graph instance
  ###
  init: (@sourceDir, @options) ->
    @buildGraph()

  ###
  # Reconstruct
  # API Method for reconstructing the graph
  ###
  reconstruct: ->
    @buildGraph()
    return @graph

  ###
  # Build Graph
  # Method for reconstructing the graph. Automatically called on add events but
  # can be called manually in other contexts.
  ###
  buildGraph: ->
    @graph = grapher.parseDir(path.resolve(@sourceDir), @options)


module.exports = new SassGrapher()
module.exports.SassGrapher = SassGrapher
