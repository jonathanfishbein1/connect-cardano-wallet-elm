import path from 'path'
import HtmlWebPackPlugin from "html-webpack-plugin"
import webpack from 'webpack';
const __dirname = path.resolve()
    , mode = process.env.NODE_ENV || 'development'

console.log(mode)
export default {
    mode: mode,
    entry: './index.ts',
    output: {
        path: path.resolve(__dirname, 'dist'),
        publicPath: '/',
        filename: '[contenthash].js',
        clean: true,
        assetModuleFilename: '[name][ext]'
    },
    target: 'web',
    resolve: {
        extensions: ['.tsx', '.ts', '.js'],
    },
    module: {
        rules: [
            {
                test: /\.(png|jpg|gif|svg|eot|ttf|woff|webp)$/,
                type: 'asset/resource'
            },
            {
                test: /\.html$/,
                use: [
                    {
                        loader: "html-loader",
                    }
                ]
            },
            {
                test: /\.tsx?$/,
                use: 'ts-loader',
                exclude: /node_modules/,
            },
            {
                test: /\.elm$/,
                use: 'elm-webpack-loader',
                exclude: [/elm-stuff/, /node_modules/],
            }
        ],
        noParse: /\.elm$/
    },
    plugins: [new HtmlWebPackPlugin({
        title: 'index',
        filename: `index.html`,
        template: `./index.html`,
    }),
    new webpack.ProvidePlugin({ Buffer: ['buffer', 'Buffer'] })
    ]
    , experiments: {
        asyncWebAssembly: true,
        outputModule: true,
        topLevelAwait: true,
        layers: true
    }
};