const autoprefixer = require('autoprefixer');
const webpack = require('webpack');
const paths = require('../config/paths');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');

const root = process.cwd();

module.exports = {
  bail: true,
  entry: [
    paths.entry,
  ],
  output: {

    // The build folder.
    path: paths.dist,

    // Generated JS files.
    filename: 'js/[name].[chunkhash:8].js',
  },
  resolveLoader: {

    // Look for loaders in own ./node_modules
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

        // Use the local installation of elm-make
        loader: 'elm-webpack',
        query: {
          pathToMake: paths.elmMake,
        },
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
        loader: ExtractTextPlugin.extract('style', 'css?-autoprefixer!postcss'),

      },
      {
        test: /\.(ico|jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2)(\?.*)?$/,
        exclude: /\/favicon.ico$/,
        loader: 'file',
        query: {
          name: 'media/[name].[hash:8].[ext]',
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

    // Remove the content of the ./dist/ folder.
    new CleanWebpackPlugin(['dist'], {
      root,
      verbose: true,
      dry: false,
    }),

    new HtmlWebpackPlugin({
      inject: true,
      template: paths.template,
      favicon: paths.favicon,
      minify: {
        removeComments: true,
        collapseWhitespace: true,
        removeRedundantAttributes: true,
        useShortDoctype: true,
        removeEmptyAttributes: true,
        removeStyleLinkTypeAttributes: true,
        keepClosingSlash: true,
        minifyJS: true,
        minifyCSS: true,
        minifyURLs: true,
      },
    }),

    new webpack.optimize.OccurrenceOrderPlugin(),
    new webpack.optimize.DedupePlugin(),

    // Minify the compiled JavaScript.
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        screw_ie8: true,
        warnings: false,
      },
      mangle: {
        screw_ie8: true,
      },
      output: {
        comments: false,
        screw_ie8: true,
      },
    }),

    new ExtractTextPlugin('css/[name].[contenthash:8].css'),
  ],

  // Some libraries import Node modules but don't use them in the browser.
  // Tell Webpack to provide empty mocks for them so importing them works.
  node: {
    fs: 'empty',
    net: 'empty',
    tls: 'empty',
  },
};
