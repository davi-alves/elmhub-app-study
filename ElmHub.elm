module ElmHub exposing (..)

import Auth
import Html exposing (..)
import Html.Attributes exposing (class, target, href, property, defaultValue)
import Html.Events exposing (..)
import Json.Decode exposing (Decoder, Value, decodeValue)
import Json.Decode.Pipeline exposing (..)
import Types exposing (..)
import Ports exposing (githubSearch, githubResponse)


-- Init


init : ( Model, Cmd msg )
init =
    ( initialModel, githubSearch (getQueryString initialModel.query) )



-- Subscriptions


subscriptions : a -> Sub Msg
subscriptions =
    \_ -> githubResponse decodeResponse



-- MODEL


initialModel : Model
initialModel =
    { query = "tutorial"
    , results = []
    , errorMessage = Nothing
    , options =
        { minStars = 0
        , minStarsError = Nothing
        , searchIn = "name"
        , userFilter = ""
        }
    }



-- COMMANDS


getQueryString : String -> String
getQueryString query =
    "access_token="
        ++ Auth.token
        ++ "&q="
        ++ query
        ++ "+language:elm&sort=stars&order=desc"



-- DECODER


decodeResponse : Value -> Msg
decodeResponse json =
    case decodeValue responseDecoder json of
        Ok results ->
            HandleSearchResponse results

        Err err ->
            HandleSearchError (Just err)


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
            , githubSearch (getQueryString model.query)
            )

        HandleSearchResponse results ->
            ( { model | results = results, errorMessage = Nothing }
            , Cmd.none
            )

        HandleSearchError error ->
            ( { model | errorMessage = error }, Cmd.none )

        DeleteById id ->
            ( { model | results = List.filter (\result -> result.id /= id) model.results }
            , Cmd.none
            )

        SetQuery queryString ->
            ( { model | query = queryString }
            , Cmd.none
            )

        Options _ ->
            ( model, Cmd.none )
