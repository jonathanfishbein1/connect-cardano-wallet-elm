module ConnectWalletTest exposing (suite)

import ConnectWallet
import Dropdown
import Element
import Expect
import Html
import Html.Attributes
import Test
import Test.Html.Query
import Test.Html.Selector


suite : Test.Test
suite =
    Test.describe "Connect Wallet Tests"
        [ Test.test "test Connect with NotConnectedNotAbleTo" <|
            \_ ->
                let
                    initialModel : ConnectWallet.Model
                    initialModel =
                        ConnectWallet.NotConnectedNotAbleTo

                    ( newModel, _ ) =
                        ConnectWallet.update (ConnectWallet.Connect ConnectWallet.Nami) initialModel
                in
                Expect.equal
                    newModel
                    ConnectWallet.NotConnectedNotAbleTo
        , Test.test "test Connect with NotConnectedButWalletsInstalled" <|
            \_ ->
                let
                    initialModel : ConnectWallet.Model
                    initialModel =
                        ConnectWallet.NotConnectedButWalletsInstalled [ ConnectWallet.Nami ]

                    ( newModel, _ ) =
                        ConnectWallet.update (ConnectWallet.Connect ConnectWallet.Nami) initialModel
                in
                Expect.equal
                    newModel
                    (ConnectWallet.ChoosingWallet [ ConnectWallet.Nami ] (Dropdown.init "wallet-dropdown") ConnectWallet.Nami)
        , Test.test "test ReceiveWalletConnected with Connecting" <|
            \_ ->
                let
                    initialModel : ConnectWallet.Model
                    initialModel =
                        ConnectWallet.Connecting [ ConnectWallet.Nami ] (Dropdown.init "wallet-dropdown") (Just ConnectWallet.Nami)

                    ( newModel, _ ) =
                        ConnectWallet.update (ConnectWallet.ReceiveWalletConnected (Maybe.Just ConnectWallet.Nami)) initialModel
                in
                Expect.equal
                    newModel
                    (ConnectWallet.ConnectionEstablished [ ConnectWallet.Nami ] (Dropdown.init "wallet-dropdown") (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami))
        , Test.test "test NotConnectedNotAbleTo view" <|
            \_ ->
                let
                    initialModel : ConnectWallet.Model
                    initialModel =
                        ConnectWallet.NotConnectedNotAbleTo
                in
                Test.Html.Query.fromHtml (ConnectWallet.view (Element.rgb255 0 0 0) initialModel)
                    |> Test.Html.Query.find [ Test.Html.Selector.text "No available wallet" ]
                    |> Test.Html.Query.has
                        [ Test.Html.Selector.text "No available wallet"
                        ]
        , Test.test "test NotConnectedButWalletsInstalled view" <|
            \_ ->
                let
                    initialModel : ConnectWallet.Model
                    initialModel =
                        ConnectWallet.NotConnectedButWalletsInstalled [ ConnectWallet.Nami ]
                in
                Test.Html.Query.fromHtml (ConnectWallet.view (Element.rgb255 0 0 0) initialModel)
                    |> Test.Html.Query.find [ Test.Html.Selector.attribute (Html.Attributes.attribute "data-dropdown-id" "wallet-dropdown") ]
                    |> Test.Html.Query.has [ Test.Html.Selector.attribute (Html.Attributes.attribute "data-dropdown-id" "wallet-dropdown") ]
        , Test.test "test ConnectionEstablished view" <|
            \_ ->
                let
                    initialModel : ConnectWallet.Model
                    initialModel =
                        ConnectWallet.ConnectionEstablished [ ConnectWallet.Nami ] (Dropdown.init "wallet-dropdown") (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                in
                Test.Html.Query.fromHtml (ConnectWallet.view (Element.rgb255 0 0 0) initialModel)
                    |> Test.Html.Query.find [ Test.Html.Selector.id "wallet-dropdown" ]
                    |> Test.Html.Query.has
                        [ Test.Html.Selector.all
                            [ Test.Html.Selector.text "nami"
                            ]
                        ]
        , Test.test "test Connecting view" <|
            \_ ->
                let
                    initialModel : ConnectWallet.Model
                    initialModel =
                        ConnectWallet.Connecting [ ConnectWallet.Nami ] (Dropdown.init "wallet-dropdown") (Just ConnectWallet.Nami)
                in
                Test.Html.Query.fromHtml (ConnectWallet.view (Element.rgb255 0 0 0) initialModel)
                    |> Test.Html.Query.find [ Test.Html.Selector.text "Connecting" ]
                    |> Test.Html.Query.has
                        [ Test.Html.Selector.text "Connecting"
                        ]
        ]
