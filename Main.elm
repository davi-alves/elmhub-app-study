module App exposing (..)

import ElmHub
import Types exposing (Model, Msg)
import Html

-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { view = ElmHub.view
        , update = ElmHub.update
        , init = ElmHub.init
        , subscriptions = ElmHub.subscriptions
        }
