port module ConnectWallet exposing
    ( Model(..)
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


type Msg
    = Connect SupportedWallet
    | ReceiveEnabledWallet (Dropdown.State SupportedWallet) (Maybe SupportedWallet)
    | NoOp
    | ReceiveWalletConnected (Maybe SupportedWallet)
    | OptionPicked (Maybe SupportedWallet)
    | DropdownMsg (Dropdown.Msg SupportedWallet)


type Model
    = NotConnectedNotAbleTo
    | NotConnectedButWalletsInstalled (List SupportedWallet)
    | ChoosingWallet (List SupportedWallet) (Dropdown.State SupportedWallet) SupportedWallet
    | Connecting (List SupportedWallet) (Dropdown.State SupportedWallet) (Maybe SupportedWallet)
    | ConnectionEstablished (List SupportedWallet) (Dropdown.State SupportedWallet) SupportedWallet


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
        ( OptionPicked option, ChoosingWallet installedWallets dropdownState choosenWallet ) ->
            case option of
                Just walletChoice ->
                    ( Connecting installedWallets dropdownState option, connectWallet (encodeWallet walletChoice) )

                Nothing ->
                    ( ChoosingWallet installedWallets dropdownState choosenWallet, Cmd.none )

        ( DropdownMsg subMsg, ChoosingWallet installedWallets dropdownState choosenWallet ) ->
            let
                ( state, cmd ) =
                    Dropdown.update (dropdownConfig model) subMsg model dropdownState
            in
            ( ChoosingWallet installedWallets state choosenWallet, cmd )

        ( DropdownMsg subMsg, ConnectionEstablished installedWallets dropdownState choosenWallet ) ->
            let
                ( state, cmd ) =
                    Dropdown.update (dropdownConfig model) subMsg model dropdownState
            in
            ( ChoosingWallet installedWallets state choosenWallet, cmd )

        ( ReceiveEnabledWallet dropdownState maybeChoosenWallet, NotConnectedButWalletsInstalled installedWallets ) ->
            case maybeChoosenWallet of
                Just choosenWallet ->
                    ( ConnectionEstablished installedWallets dropdownState choosenWallet, Cmd.none )

                Nothing ->
                    ( NotConnectedNotAbleTo, Cmd.none )

        ( Connect choosenWallet, NotConnectedButWalletsInstalled installedWallets ) ->
            ( ChoosingWallet installedWallets (Dropdown.init "wallet-dropdown") choosenWallet, Cmd.none )

        ( ReceiveWalletConnected wallet, Connecting installedWallets dropdownState _ ) ->
            case wallet of
                Just w ->
                    ( ConnectionEstablished installedWallets dropdownState w, Cmd.none )

                Nothing ->
                    ( NotConnectedNotAbleTo, Cmd.none )

        _ ->
            ( model, Cmd.none )


dropdownConfig : Model -> Dropdown.Config SupportedWallet Msg Model
dropdownConfig model =
    let
        itemToPrompt : SupportedWallet -> Element.Element msg
        itemToPrompt item =
            encodeWallet item
                |> Element.text

        itemToElement : a -> b -> SupportedWallet -> Element.Element msg
        itemToElement _ _ supportedWallet =
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
                        ]
    in
    Dropdown.basic
        { itemsFromModel =
            always
                (case model of
                    NotConnectedButWalletsInstalled installedWallets ->
                        installedWallets

                    ChoosingWallet installedWallets _ _ ->
                        installedWallets

                    Connecting installedWallets _ _ ->
                        installedWallets

                    ConnectionEstablished installedWallets _ _ ->
                        installedWallets

                    _ ->
                        []
                )
        , selectionFromModel =
            \m ->
                case m of
                    Connecting _ _ (Just selectedOption) ->
                        Just selectedOption

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
                ConnectionEstablished _ _ supportedWallet ->
                    Element.row
                        [ Element.width (Element.px 200)
                        , Element.spacing 10
                        ]
                        [ Element.image
                            [ Element.width (Element.px 50)
                            , Element.height (Element.px 50)
                            ]
                            (case supportedWallet of
                                Nami ->
                                    { src = "./nami.svg"
                                    , description = "Nami"
                                    }

                                Eternl ->
                                    { src = "./eternl.webp"
                                    , description = "Eternl"
                                    }

                                Flint ->
                                    { src = "./flint.svg"
                                    , description = "Flint"
                                    }
                            )
                        , encodeWallet
                            supportedWallet
                            |> Element.text
                        ]

                ChoosingWallet _ _ supportedWallet ->
                    Element.row
                        [ Element.width (Element.px 200)
                        , Element.spacing 10
                        ]
                        [ Element.image
                            [ Element.width (Element.px 50)
                            , Element.height (Element.px 50)
                            ]
                            (case supportedWallet of
                                Nami ->
                                    { src = "./nami.svg"
                                    , description = "Nami"
                                    }

                                Eternl ->
                                    { src = "./eternl.webp"
                                    , description = "Eternl"
                                    }

                                Flint ->
                                    { src = "./flint.svg"
                                    , description = "Flint"
                                    }
                            )
                        , encodeWallet
                            supportedWallet
                            |> Element.text
                        ]

                _ ->
                    Element.text "Select Wallet"
            )
        |> Dropdown.withListAttributes [ Element.Border.width 1, Element.Border.rounded 5 ]
        |> Dropdown.withContainerAttributes [ Element.width (Element.px 200) ]


view : Element.Color -> Model -> Html.Html Msg
view fontColor model =
    case model of
        NotConnectedNotAbleTo ->
            Element.layout []
                (Element.Input.button
                    []
                    { onPress =
                        Just
                            NoOp
                    , label =
                        Element.text
                            "No available wallet"
                    }
                )

        NotConnectedButWalletsInstalled _ ->
            Element.layout [ Element.Font.color fontColor ]
                (Element.text
                    "Connect"
                )

        ChoosingWallet _ dropdownWallets _ ->
            Element.layout [ Element.Font.color fontColor ]
                (Dropdown.view (dropdownConfig model)
                    model
                    dropdownWallets
                )

        Connecting _ dropdownState _ ->
            Element.layout [ Element.Font.color fontColor ]
                (Element.column
                    []
                    [ Dropdown.view (dropdownConfig model)
                        model
                        dropdownState
                    , Element.text
                        "Connecting"
                    ]
                )

        ConnectionEstablished _ dropdownState _ ->
            Element.layout [ Element.Font.color fontColor ]
                (Dropdown.view (dropdownConfig model)
                    model
                    dropdownState
                )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ receiveEnabledWallet
            (\s ->
                ReceiveEnabledWallet (Dropdown.init "wallet-dropdown") (decodeWallet s)
            )
        , receiveWalletConnection (\s -> ReceiveWalletConnected (decodeWallet s))
        ]


init : List String -> ( Model, Cmd Msg )
init walletsInstalledStrings =
    -- let
    --     enabledWallet : Maybe SupportedWallet
    --     enabledWallet =
    --         decodeWallet enabledWalletString
    -- in
    case walletsInstalledStrings of
        [] ->
            ( NotConnectedNotAbleTo, Cmd.none )

        w :: ws ->
            let
                walletsInstalled : List SupportedWallet
                walletsInstalled =
                    List.map decodeWallet walletsInstalledStrings
                        |> Maybe.Extra.values
            in
            ( NotConnectedButWalletsInstalled walletsInstalled
            , checkForEnabledWallet ()
            )


main : Program (List String) Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view (Element.rgb255 0 0 0)
        , subscriptions = subscriptions
        }


port checkForEnabledWallet : () -> Cmd msg


port receiveEnabledWallet : (String -> msg) -> Sub msg


port connectWallet : String -> Cmd msg


port receiveWalletConnection : (String -> msg) -> Sub msg
