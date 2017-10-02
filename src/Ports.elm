port module Ports exposing (githubSearch, githubResponse)

import Json.Decode exposing (Value)


port githubSearch : String -> Cmd msg


port githubResponse : (Value -> msg) -> Sub msg
