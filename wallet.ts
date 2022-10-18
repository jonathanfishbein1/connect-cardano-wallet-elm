
import nami from './images/nami.svg'
import eternl from './images/eternl.webp'
import flint from './images/flint.svg'
import checkmark from './images/checkmark.svg'
import selectWallet from './images/select wallet.png'

nami
eternl
flint
checkmark
selectWallet

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
