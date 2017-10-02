module App exposing (..)

import Auth
import Html exposing (..)
import Html.Attributes exposing (class, target, href, property, defaultValue)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)

import Types exposing (..)
import Ports


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
    , errorMessage = Nothing
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
    in
        Http.get url responseDecoder
            |> Http.send HandleSearchResponse



-- DECODER


responseDecoder : Decoder (List SearchResult)
responseDecoder =
    decode identity
        |> required "items" (Json.Decode.list searchResultDecoder)


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
    decode SearchResult
        |> required "id" Json.Decode.int
        |> required "full_name" Json.Decode.string
        |> required "stargazers_count" Json.Decode.int


-- TYPES


-- VIEW


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ elmHeader
        , input [ class "search-query", onInput SetQuery, defaultValue model.query ] []
        , button [ class "search-button", onClick Search ] [ text "Search" ]
        , viewErrorMessage model.errorMessage
        , ul [ class "results" ] (List.map viewSearchResult model.results)
        ]


elmHeader : Html msg
elmHeader =
    header []
        [ h1 [] [ text "ElmHub" ]
        , span [ class "tagline" ] [ text "Like GitHub, but for Elm things." ]
        ]


viewErrorMessage : Maybe String -> Html msg
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



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search ->
            ( { model | errorMessage = Nothing }
            , searchFeed model.query
            )

        HandleSearchResponse (Ok results) ->
            ( { model | results = results, errorMessage = Nothing }
            , Cmd.none
            )

        HandleSearchResponse (Err error) ->
            let
                errorMessage =
                    case error of
                        Http.BadUrl err ->
                            err

                        Http.BadStatus err ->
                            err.status.message

                        Http.BadPayload err _ ->
                            err

                        _ ->
                            "Network error, please check your connection"
            in
                ( { model | errorMessage = Just errorMessage }, Cmd.none )

        DeleteById id ->
            ( { model | results = List.filter (\result -> result.id /= id) model.results }
            , Cmd.none
            )

        SetQuery queryString ->
            ( { model | query = queryString }
            , Cmd.none
            )
