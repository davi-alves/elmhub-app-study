module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


-- TYPES


type alias Msg =
    { operation : String, data : Int }


type alias SearchResult =
    { id : Int
    , name : String
    , stars : Int
    }


type alias Model =
    { query : String
    , results : List SearchResult
    }



-- MODEL


model : Model
model =
    { query = "tutorial"
    , results =
        [ { id = 1
          , name = "TheSeamau5/elm-checkerboardgrid-tutorial"
          , stars = 66
          }
        , { id = 2
          , name = "grzegorzbalcerek/elm-by-example"
          , stars = 41
          }
        , { id = 3
          , name = "sporto/elm-tutorial-app"
          , stars = 35
          }
        , { id = 4
          , name = "jvoigtlaender/Elm-Tutorium"
          , stars = 10
          }
        , { id = 5
          , name = "sporto/elm-tutorial-assets"
          , stars = 7
          }
        ]
    }



-- VIEW


elmHeader : Html msg
elmHeader =
    div [ class "content" ]
        [ header []
            [ h1 [] [ text "ElmHub" ]
            , span [ class "tagline" ] [ text "Like GitHub, but for Elm things." ]
            ]
        ]


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ elmHeader
        , ul [ class "results" ] (List.map viewSearchResult model.results)
        ]


viewSearchResult : SearchResult -> Html Msg
viewSearchResult result =
    li []
        [ span [ class "start-count" ] [ text (toString result.stars) ]
        , a [ href ("https://github.com/" ++ result.name), target "_blank" ]
            [ text result.name ]
        , button
            [ class "hide-result", onClick { operation = "DELETE_BY_ID", data = result.id } ]
            [ text "X" ]
        ]



-- UPDATE


update : Msg -> Model -> Model
update msg model =
    if msg.operation == "DELETE_BY_ID" then
        { model | results = List.filter (\result -> result.id /= msg.data) model.results }
    else
        model



-- MAIN


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { view = view, update = update, model = model }
