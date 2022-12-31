port module ConnectWallet exposing
    ( AvailableWallets
    , EnabledSupportedWallet(..)
    , Model(..)
    , Msg(..)
    , SupportedWallet(..)
    , decodeWallet
    , encodeWallet
    , subscriptions
    , update
    , view
    )

import Browser
import Dropdown
import Element
import Element.Border
import Element.Font
import Element.Input
import Html
import Maybe.Extra


type alias AvailableWallets =
    List SupportedWallet


type EnabledSupportedWallet
    = EnabledSupportedWallet SupportedWallet


type Msg
    = ChooseWallet
    | NoOp
    | ReceiveWalletConnected (Maybe SupportedWallet)
    | OptionPicked (Maybe SupportedWallet)
    | DropdownMsg (Dropdown.Msg SupportedWallet)


type Model
    = NotConnectedNotAbleTo
    | NotConnectedButWalletsInstalledAndEnabled (Element.Element Msg) AvailableWallets
    | ChoosingWallet (Element.Element Msg) AvailableWallets (Dropdown.State SupportedWallet) (Maybe SupportedWallet)
    | Connecting (Element.Element Msg) AvailableWallets (Dropdown.State SupportedWallet) SupportedWallet
    | ConnectionEstablished (Element.Element Msg) AvailableWallets (Dropdown.State SupportedWallet) EnabledSupportedWallet


decodeWallet : String -> Maybe SupportedWallet
decodeWallet status =
    case status of
        "nami" ->
            Just Nami

        "eternl" ->
            Just Eternl

        "flint" ->
            Just Flint

        _ ->
            Nothing


encodeWallet : SupportedWallet -> String
encodeWallet wallet =
    case wallet of
        Nami ->
            "nami"

        Eternl ->
            "eternl"

        Flint ->
            "flint"


type SupportedWallet
    = Nami
    | Eternl
    | Flint


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( OptionPicked option, ChoosingWallet selectWalletElement installedWallets dropdownState choosenWallet ) ->
            case option of
                Just walletChoice ->
                    ( Connecting selectWalletElement installedWallets dropdownState walletChoice, connectWallet (encodeWallet walletChoice) )

                Nothing ->
                    ( ChoosingWallet selectWalletElement installedWallets dropdownState choosenWallet, Cmd.none )

        ( DropdownMsg subMsg, ChoosingWallet selectWalletElement installedWallets dropdownState choosenWallet ) ->
            let
                ( state, cmd ) =
                    Dropdown.update (dropdownConfig selectWalletElement model) subMsg model dropdownState
            in
            ( ChoosingWallet selectWalletElement installedWallets state choosenWallet, cmd )

        ( DropdownMsg subMsg, ConnectionEstablished selectWalletElement installedWallets dropdownState (EnabledSupportedWallet choosenWallet) ) ->
            let
                ( state, cmd ) =
                    Dropdown.update (dropdownConfig selectWalletElement model) subMsg model dropdownState
            in
            ( ChoosingWallet selectWalletElement installedWallets state (Just choosenWallet), cmd )

        ( _, NotConnectedButWalletsInstalledAndEnabled selectWalletElement installedWallets ) ->
            ( ChoosingWallet selectWalletElement installedWallets (Dropdown.init "wallet-dropdown") Nothing, Cmd.none )

        ( ReceiveWalletConnected wallet, Connecting selectWalletElement installedWallets dropdownState _ ) ->
            case wallet of
                Just w ->
                    ( ConnectionEstablished selectWalletElement installedWallets dropdownState (EnabledSupportedWallet w), Cmd.none )

                Nothing ->
                    ( ChoosingWallet selectWalletElement installedWallets (Dropdown.init "wallet-dropdown") Nothing, Cmd.none )

        _ ->
            ( model, Cmd.none )


dropdownConfig : Element.Element Msg -> Model -> Dropdown.Config SupportedWallet Msg Model
dropdownConfig selectWalletElement model =
    let
        itemToPrompt : SupportedWallet -> Element.Element msg
        itemToPrompt supportedWallet =
            case supportedWallet of
                Nami ->
                    Element.row
                        [ Element.width (Element.px 200)
                        , Element.spacing 10
                        ]
                        [ Element.image
                            [ Element.width (Element.px 50)
                            , Element.height (Element.px 50)
                            ]
                            { src = "./nami.svg"
                            , description = "Nami"
                            }
                        , encodeWallet
                            supportedWallet
                            |> Element.text
                        , Element.image
                            [ Element.width (Element.px 50)
                            , Element.height (Element.px 50)
                            ]
                            { src = "./checkmark.svg"
                            , description = "checkmark"
                            }
                        ]

                Eternl ->
                    Element.row
                        [ Element.width (Element.px 200)
                        , Element.spacing 10
                        ]
                        [ Element.image
                            [ Element.width (Element.px 50)
                            , Element.height (Element.px 50)
                            ]
                            { src = "./eternl.webp"
                            , description = "Eternl"
                            }
                        , encodeWallet
                            supportedWallet
                            |> Element.text
                        , Element.image
                            [ Element.width (Element.px 50)
                            , Element.height (Element.px 50)
                            ]
                            { src = "./checkmark.svg"
                            , description = "checkmark"
                            }
                        ]

                Flint ->
                    Element.row
                        [ Element.width (Element.px 200)
                        , Element.spacing 10
                        ]
                        [ Element.image
                            [ Element.width (Element.px 50)
                            , Element.height (Element.px 50)
                            ]
                            { src = "./flint.svg"
                            , description = "Flint"
                            }
                        , encodeWallet
                            supportedWallet
                            |> Element.text
                        , Element.image
                            [ Element.width (Element.px 50)
                            , Element.height (Element.px 50)
                            ]
                            { src = "./checkmark.svg"
                            , description = "checkmark"
                            }
                        ]

        itemToElement : Bool -> Bool -> SupportedWallet -> Element.Element msg
        itemToElement selected _ supportedWallet =
            case supportedWallet of
                Nami ->
                    Element.row
                        [ Element.width (Element.px 200)
                        , Element.spacing 10
                        ]
                        [ Element.image
                            [ Element.width (Element.px 50)
                            , Element.height (Element.px 50)
                            ]
                            { src = "./nami.svg"
                            , description = "Nami"
                            }
                        , encodeWallet
                            supportedWallet
                            |> Element.text
                        , if selected then
                            Element.image
                                [ Element.width (Element.px 50)
                                , Element.height (Element.px 50)
                                ]
                                { src = "./checkmark.svg"
                                , description = "checkmark"
                                }

                          else
                            Element.none
                        ]

                Eternl ->
                    Element.row
                        [ Element.width (Element.px 200)
                        , Element.spacing 10
                        ]
                        [ Element.image
                            [ Element.width (Element.px 50)
                            , Element.height (Element.px 50)
                            ]
                            { src = "./eternl.webp"
                            , description = "Eternl"
                            }
                        , encodeWallet
                            supportedWallet
                            |> Element.text
                        , if selected then
                            Element.image
                                [ Element.width (Element.px 50)
                                , Element.height (Element.px 50)
                                ]
                                { src = "./checkmark.svg"
                                , description = "checkmark"
                                }

                          else
                            Element.none
                        ]

                Flint ->
                    Element.row
                        [ Element.width (Element.px 200)
                        , Element.spacing 10
                        ]
                        [ Element.image
                            [ Element.width (Element.px 50)
                            , Element.height (Element.px 50)
                            ]
                            { src = "./flint.svg"
                            , description = "Flint"
                            }
                        , encodeWallet
                            supportedWallet
                            |> Element.text
                        , if selected then
                            Element.image
                                [ Element.width (Element.px 50)
                                , Element.height (Element.px 50)
                                ]
                                { src = "./checkmark.svg"
                                , description = "checkmark"
                                }

                          else
                            Element.none
                        ]
    in
    Dropdown.basic
        { itemsFromModel =
            \m ->
                case m of
                    NotConnectedButWalletsInstalledAndEnabled _ installedWallets ->
                        installedWallets

                    ChoosingWallet _ installedWallets _ _ ->
                        installedWallets

                    Connecting _ installedWallets _ _ ->
                        installedWallets

                    ConnectionEstablished _ installedWallets _ _ ->
                        installedWallets

                    _ ->
                        []
        , selectionFromModel =
            \m ->
                case m of
                    Connecting _ _ _ selectedOption ->
                        Just selectedOption

                    ChoosingWallet _ _ _ selectedOption ->
                        selectedOption

                    _ ->
                        Nothing
        , dropdownMsg = DropdownMsg
        , onSelectMsg = OptionPicked
        , itemToPrompt = itemToPrompt
        , itemToElement = itemToElement
        }
        |> Dropdown.withSelectAttributes [ Element.Border.width 1, Element.Border.rounded 5, Element.paddingXY 16 8 ]
        |> Dropdown.withPromptElement
            (case model of
                ConnectionEstablished _ _ _ (EnabledSupportedWallet supportedWallet) ->
                    case supportedWallet of
                        Nami ->
                            Element.row
                                [ Element.width (Element.px 200)
                                , Element.spacing 10
                                ]
                                [ Element.image
                                    [ Element.width (Element.px 50)
                                    , Element.height (Element.px 50)
                                    ]
                                    { src = "./nami.svg"
                                    , description = "Nami"
                                    }
                                , encodeWallet
                                    supportedWallet
                                    |> Element.text
                                , Element.image
                                    [ Element.width (Element.px 50)
                                    , Element.height (Element.px 50)
                                    ]
                                    { src = "./checkmark.svg"
                                    , description = "checkmark"
                                    }
                                ]

                        Eternl ->
                            Element.row
                                [ Element.width (Element.px 200)
                                , Element.spacing 10
                                ]
                                [ Element.image
                                    [ Element.width (Element.px 50)
                                    , Element.height (Element.px 50)
                                    ]
                                    { src = "./eternl.webp"
                                    , description = "Eternl"
                                    }
                                , encodeWallet
                                    supportedWallet
                                    |> Element.text
                                , Element.image
                                    [ Element.width (Element.px 50)
                                    , Element.height (Element.px 50)
                                    ]
                                    { src = "./checkmark.svg"
                                    , description = "checkmark"
                                    }
                                ]

                        Flint ->
                            Element.row
                                [ Element.width (Element.px 200)
                                , Element.spacing 10
                                ]
                                [ Element.image
                                    [ Element.width (Element.px 50)
                                    , Element.height (Element.px 50)
                                    ]
                                    { src = "./flint.svg"
                                    , description = "Flint"
                                    }
                                , encodeWallet
                                    supportedWallet
                                    |> Element.text
                                , Element.image
                                    [ Element.width (Element.px 50)
                                    , Element.height (Element.px 50)
                                    ]
                                    { src = "./checkmark.svg"
                                    , description = "checkmark"
                                    }
                                ]

                ChoosingWallet _ _ _ supportedWallet ->
                    case supportedWallet of
                        Just Nami ->
                            Element.row
                                [ Element.width (Element.px 200)
                                , Element.spacing 10
                                ]
                                [ Element.image
                                    [ Element.width (Element.px 50)
                                    , Element.height (Element.px 50)
                                    ]
                                    { src = "./nami.svg"
                                    , description = "Nami"
                                    }
                                , encodeWallet
                                    Nami
                                    |> Element.text
                                , Element.image
                                    [ Element.width (Element.px 50)
                                    , Element.height (Element.px 50)
                                    ]
                                    { src = "./checkmark.svg"
                                    , description = "checkmark"
                                    }
                                ]

                        Just Eternl ->
                            Element.row
                                [ Element.width (Element.px 200)
                                , Element.spacing 10
                                ]
                                [ Element.image
                                    [ Element.width (Element.px 50)
                                    , Element.height (Element.px 50)
                                    ]
                                    { src = "./eternl.webp"
                                    , description = "Eternl"
                                    }
                                , encodeWallet
                                    Eternl
                                    |> Element.text
                                , Element.image
                                    [ Element.width (Element.px 50)
                                    , Element.height (Element.px 50)
                                    ]
                                    { src = "./checkmark.svg"
                                    , description = "checkmark"
                                    }
                                ]

                        Just Flint ->
                            Element.row
                                [ Element.width (Element.px 200)
                                , Element.spacing 10
                                ]
                                [ Element.image
                                    [ Element.width (Element.px 50)
                                    , Element.height (Element.px 50)
                                    ]
                                    { src = "./flint.svg"
                                    , description = "Flint"
                                    }
                                , encodeWallet
                                    Flint
                                    |> Element.text
                                , Element.image
                                    [ Element.width (Element.px 50)
                                    , Element.height (Element.px 50)
                                    ]
                                    { src = "./checkmark.svg"
                                    , description = "checkmark"
                                    }
                                ]

                        Nothing ->
                            selectWalletElement

                _ ->
                    selectWalletElement
            )
        |> Dropdown.withListAttributes [ Element.Border.width 1, Element.Border.rounded 5 ]


view : Element.Color -> Model -> Html.Html Msg
view fontColor model =
    case model of
        NotConnectedNotAbleTo ->
            Element.layout [ Element.Font.color fontColor ]
                (Element.text
                    "No available wallet"
                )

        NotConnectedButWalletsInstalledAndEnabled selectWalletElement _ ->
            Element.layout [ Element.Font.color fontColor ]
                (Dropdown.view (dropdownConfig selectWalletElement model)
                    model
                    (Dropdown.init "wallet-dropdown")
                )

        ChoosingWallet selectWalletElement _ dropdownWallets _ ->
            Element.layout [ Element.Font.color fontColor ]
                (Dropdown.view (dropdownConfig selectWalletElement model)
                    model
                    dropdownWallets
                )

        Connecting selectWalletElement _ dropdownState _ ->
            Element.layout [ Element.Font.color fontColor ]
                (Element.column
                    []
                    [ Dropdown.view (dropdownConfig selectWalletElement model)
                        model
                        dropdownState
                    , Element.text
                        "Connecting"
                    ]
                )

        ConnectionEstablished selectWalletElement _ dropdownState _ ->
            Element.layout [ Element.Font.color fontColor ]
                (Dropdown.view (dropdownConfig selectWalletElement model)
                    model
                    dropdownState
                )


subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveWalletConnection (\s -> ReceiveWalletConnected (decodeWallet s))


init : List String -> ( Model, Cmd Msg )
init walletsInstalledAndEnabledStrings =
    case walletsInstalledAndEnabledStrings of
        [] ->
            ( NotConnectedNotAbleTo, Cmd.none )

        _ ->
            let
                walletsInstalledAndEnabled : List SupportedWallet
                walletsInstalledAndEnabled =
                    List.map decodeWallet walletsInstalledAndEnabledStrings
                        |> Maybe.Extra.values
            in
            update ChooseWallet
                (NotConnectedButWalletsInstalledAndEnabled
                    (Element.image
                        [ Element.width (Element.px 200)
                        , Element.height (Element.px 50)
                        ]
                        { src = "./select wallet.png"
                        , description = "select wallet"
                        }
                    )
                    walletsInstalledAndEnabled
                )


main : Program (List String) Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view =
            view
                (Element.rgb255 0 0 0)
        , subscriptions = subscriptions
        }


port connectWallet : String -> Cmd msg


port receiveWalletConnection : (String -> msg) -> Sub msg
