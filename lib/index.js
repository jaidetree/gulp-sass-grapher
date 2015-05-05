(function() {
  var File, SassGrapher, error, fs, grapher, gutil, path, through;

  File = require('vinyl');

  fs = require('fs');

  grapher = require('sass-graph');

  gutil = require('gulp-util');

  path = require('path');

  through = require('through2');

  error = function(message) {
    return new gutil.PluginError('gulp-sass-grapher', message);
  };

  SassGrapher = (function() {
    function SassGrapher() {}


    /*
     * Ancestors
     * Gets the root level sass files to process
     * Returns a through transform stream
     */

    SassGrapher.prototype.ancestors = function() {
      var self;
      self = this;
      return through.obj(function(file, enc, next) {
        var getAncestors, hasImports, sassData, stream;
        hasImports = false;
        stream = this;
        if (file.isNull()) {
          this.push(file);
          return next();
        }
        if (file.isStream()) {
          this.emit('error', error('Streaming not supported'));
          this.push(file);
          return next();
        }
        if (file.event && file.event === 'add') {
          self.reconstruct(file.relative);
        }
        sassData = self.graph.index[file.path];
        if (!sassData || sassData.importedBy.length === 0) {
          self.reconstruct(file.relative);
          sassData = self.graph.index[file.path];
        }
        if (!sassData || sassData.importedBy.length === 0) {
          this.push(file);
          return next();
        }
        getAncestors = function(childFilepath) {
          return self.graph.visitAncestors(childFilepath, function(filepath) {
            if (path.basename(filepath).slice(0, 1) === '_') {
              return;
            }
            hasImports = true;
            return stream.push(new File({
              cwd: file.cwd,
              base: path.dirname(filepath),
              path: filepath,
              contents: new Buffer(fs.readFileSync(filepath, 'utf8'))
            }));
          });
        };
        getAncestors(file.path);
        if (!hasImports) {
          this.push(file);
        }
        return next();
      });
    };


    /*
     * Init
     * Method for creating the graph instance
     */

    SassGrapher.prototype.init = function(sourceDir, options) {
      this.sourceDir = sourceDir;
      this.options = options;
      return this.buildGraph();
    };


    /*
     * Reconstruct
     * API Method for reconstructing the graph
     */

    SassGrapher.prototype.reconstruct = function(file) {
      var cyan, white;
      if (file) {
        white = gutil.colors.white;
        cyan = gutil.colors.cyan;
        gutil.log(white('Rebuilding graph for'), cyan(file) + white('...'));
      }
      this.buildGraph();
      return this.graph;
    };


    /*
     * Build Graph
     * Method for reconstructing the graph. Automatically called on add events but
     * can be called manually in other contexts.
     */

    SassGrapher.prototype.buildGraph = function() {
      return this.graph = grapher.parseDir(path.resolve(this.sourceDir), this.options);
    };

    return SassGrapher;

  })();

  module.exports = new SassGrapher();

  module.exports.SassGrapher = SassGrapher;

}).call(this);
