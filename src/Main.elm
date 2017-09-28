module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, target, href, property, defaultValue)
import Html.Events exposing (..)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import SampleResponse


-- MAIN


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { view = view
        , update = update
        , model = initialModel
        }



-- DECODER


decodeResults : String -> List SearchResult
decodeResults json =
    case decodeString responseDecoder json of
        _ ->
            []


responseDecoder : Decoder (List SearchResult)
responseDecoder =
    decode identity
        |> required "items" (list searchResultDecoder)


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
    decode SearchResult
        |> hardcoded 0
        |> hardcoded ""
        |> hardcoded 0



-- TYPES


type Msg
    = SetQuery String
    | DeleteById Int


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


initialModel : Model
initialModel =
    { query = "tutorial"
    , results = []
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
        , input
            [ class "search-query"
            , onInput SetQuery
            , defaultValue model.query
            ]
            []
        , button [ class "search-button" ] [ text "Search" ]
        , ul [ class "results" ] (List.map viewSearchResult model.results)
        ]


viewSearchResult : SearchResult -> Html Msg
viewSearchResult result =
    li []
        [ span [ class "start-count" ] [ text (toString result.stars) ]
        , a [ href ("https://github.com/" ++ result.name), target "_blank" ]
            [ text result.name ]
        , button
            [ class "hide-result", onClick (DeleteById result.id) ]
            [ text "X" ]
        ]



-- UPDATE


update : Msg -> Model -> Model
update msg model =
    case msg of
        DeleteById id ->
            { model | results = List.filter (\result -> result.id /= id) model.results }

        SetQuery queryString ->
            { model | query = queryString }
