import * as Wallet from './wallet'
import * as Lucid from 'lucid-cardano'
var { Elm } = require('./src/ConnectWallet.elm')
declare var window: any


const bk = "testnetwIyK8IphOti170JCngH0NedP0yK8wBZs"
    , blockfrostApi = 'https://cardano-testnet.blockfrost.io/api/v0'
    , blockfrostClient = new Lucid.Blockfrost(blockfrostApi, bk)
    , lucid = await Lucid.Lucid.new(blockfrostClient,
        'Testnet')


console.log('here')
console.log(Wallet.hasWalletEnabled())
console.log(await Wallet.walletsInstalled)
var app = Elm.ConnectWallet.init({
    flags: Wallet.walletsInstalled,
    node: document.getElementById("elm-app-is-loaded-here")
})

app.ports.checkForEnabledWallet.subscribe(async () => {
    console.log('checkForEnabledWallet')
    console.log(await Wallet.walletsInstalled)
    console.log(await Wallet.hasWalletEnabled())
    app.ports.receiveEnabledWallet.send(await Wallet.hasWalletEnabled())
})


app.ports.connectWallet.subscribe(async supportedWallet => {
    const wallet = await Wallet.getWalletApi(supportedWallet!) as any
    lucid.selectWallet(wallet)
    console.log(wallet)
    app.ports.receiveWalletConnection.send(supportedWallet)
})


