module.exports = {
  mode: "production",
  module: {
    rules: [
      {
        test: /\.coffee$/,
        loader: "coffee-loader",
      },
    ],
  },
  resolve: {
    extensions: [".js", ".coffee"],
  },
  entry: "./src/scripts/main.coffee",
  output: {
    path: __dirname + "/dist/",
    filename: "main.js",
    clean: true,
  },
}
