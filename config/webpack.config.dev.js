const autoprefixer = require('autoprefixer');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const paths = require('../config/paths');

module.exports = {

  devtool: 'eval',

  entry: [

    // WebpackDevServer client.
    require.resolve('webpack-dev-server/client') + '?/',

    // Replacement runtime.
    require.resolve('webpack/hot/dev-server'),

    paths.entry,
  ],
  output: {

    pathinfo: true,

    // The build folder.
    path: paths.dist,

    // Generated JS files.
    filename: 'dist/js/bundle.js',

    publicPath: '/',
  },
  resolveLoader: {

    // Look for loaders in own node_modules
    root: paths.ownModules,
    moduleTemplates: ['*-loader'],
  },
  resolve: {
    modulesDirectories: ['node_modules'],
    extensions: ['', '.js', '.elm'],
  },
  module: {
    noParse: /\.elm$/,
    loaders: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: `elm-hot!elm-webpack?verbose=true&warn=true&pathToMake=${paths.elmMake}`,
      },
      {
        test: /\.(js|jsx)$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: 'babel',
        query: {
          presets: ['latest'],
        },
      },
      {
        test: /\.css$/,
        loader: 'style!css!postcss',
      },
      {
        test: /\.(ico|jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2)(\?.*)?$/,
        exclude: /\/favicon.ico$/,
        loader: 'file',
        query: {
          name: 'static/media/[name].[hash:8].[ext]',
        },
      },
    ],
  },
  postcss: function postcss() {
    return [
      autoprefixer({
        browsers: [
          '>1%',
          'last 4 versions',
          'Firefox ESR',
          'not ie < 9',
        ],
      }),
    ];
  },
  plugins: [
    new HtmlWebpackPlugin({
      inject: true,
      template: paths.template,
      favicon: paths.favicon,
    }),
    new webpack.HotModuleReplacementPlugin(),
  ],

  // Some libraries import Node modules but don't use them in the browser.
  // Tell Webpack to provide empty mocks for them so importing them works.
  node: {
    fs: 'empty',
    net: 'empty',
    tls: 'empty',
  },
};
