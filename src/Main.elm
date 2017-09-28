module App exposing (..)

import Auth
import Html exposing (..)
import Html.Attributes exposing (class, target, href, property, defaultValue)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)


-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , update = update
        , init = ( initialModel, searchFeed initialModel.query )
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


initialModel : Model
initialModel =
    { query = "tutorial"
    , results = []
    }



-- COMMANDS


searchFeed : String -> Cmd Msg
searchFeed query =
    let
        url =
            "https://api.github.com/search/repositories?access_token="
                ++ Auth.token
                ++ "&q="
                ++ query
                ++ "+language:elm&sort=stars&order=desc"

        request =
            "TODO replace this String with a Request built using http://package.elm-lang.org/packages/elm-lang/http/latest/Http#get"
    in
        Cmd.none



-- DECODER


decodeResults : String -> List SearchResult
decodeResults json =
    case decodeString responseDecoder json of
        Ok searchResults ->
            searchResults

        Err errorMessage ->
            []


responseDecoder : Decoder (List SearchResult)
responseDecoder =
    decode identity
        |> required "items" (list searchResultDecoder)


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
    decode SearchResult
        |> required "id" int
        |> required "full_name" string
        |> required "stargazers_count" int



-- TYPES


type alias SearchResult =
    { id : Int
    , name : String
    , stars : Int
    }


type alias Model =
    { query : String
    , results : List SearchResult
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
        , button [ class "search-button", onClick Search ] [ text "Search" ]
        , ul [ class "results" ] (List.map viewSearchResult model.results)
        ]


viewErrorMessage : Maybe String -> Html Msg
viewErrorMessage errorMessage =
    case errorMessage of
        Just message ->
            div [ class "error" ] [ text message ]

        Nothing ->
            text ""


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


type Msg
    = Search
    | SetQuery String
    | DeleteById Int
    | HandleSearchResponse (Result Http.Error (List SearchResult))


update : Msg -> Model -> Model
update msg model =
    case msg of
        DeleteById id ->
            { model | results = List.filter (\result -> result.id /= id) model.results }

        SetQuery queryString ->
            { model | query = queryString }
