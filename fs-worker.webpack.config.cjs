const
  _path =
    require(
      'path');
const
  _output_dir =
    _path.resolve(
      __dirname);
const
  _input_file_name =
    "fs-worker";
const
  _input_file_path =
    `./node_modules/opfs/${_input_file_name}`;
const
  _output_file_name =
    `${_input_file_name}.js`;
const
  _output = {
    path:
      _output_dir,
    filename:
      _output_file_name
  };
const
  _node_fs_ignore =
  { resourceRegExp:
      /^node:fs$/ };
const
  _webpack =
    require(
     "webpack");
const
  _ignore_plugin =
    _webpack.IgnorePlugin; 
const
  _node_fs_ignore_plugin =
    new _ignore_plugin(
          _node_fs_ignore);
module.exports = {
  entry:
    _input_file_path,
  output:
    _output,
  optimization: {
    moduleIds: 'deterministic',
  },
  resolve: {
    alias: {
      "fs":
        _path.resolve(
          __dirname,
          'node_modules/fs/fs'),
      "opfs":
        _path.resolve(
          __dirname,
          'node_modules/fs/fs'),
      "path":
        _path.resolve(
          __dirname,
          'node_modules/path/mod.js'),
    },
  },
  plugins: [
    _node_fs_ignore_plugin,
  ]
};
