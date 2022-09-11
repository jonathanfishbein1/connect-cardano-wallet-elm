
import nami from './images/nami.svg'
import eternl from './images/eternl.webp'
import flint from './images/flint.svg'
console.log(nami)
console.log(eternl)
console.log(flint)

export type SupportedWallet =
    'nami'
    | 'flint'
    | 'eternl'


const supportedWallets: Array<SupportedWallet> =
    ['nami'
        , 'flint'
        , 'eternl']


export const getWalletApi = async (wallet: SupportedWallet) => window.cardano[wallet].enable()
    , walletsInstalled = supportedWallets.filter(supportedWallet => window.onload = () => window.cardano[supportedWallet] !== undefined)
    , hasWalletEnabled = async () => await walletsInstalled.find(supportedWallet => {
        try {
            window.cardano[supportedWallet].isEnabled()
        }
        catch (err) {
            console.log(err)
        }
    })