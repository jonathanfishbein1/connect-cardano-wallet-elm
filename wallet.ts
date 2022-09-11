
import nami from './images/nami.svg'
import eternl from './images/eternl.webp'
import flint from './images/flint.svg'
import checkmark from './images/checkmark.svg'

console.log(nami)
console.log(eternl)
console.log(flint)
console.log(checkmark)

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
    , walletsEnabled = async () => await walletsInstalled.filter(supportedWallet => {
        try {
            return window.cardano[supportedWallet].isEnabled()
        }
        catch (err) {
            return false
        }
    }
    )
