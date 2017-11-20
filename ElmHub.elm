module ElmHub exposing (..)

import Auth
import Html exposing (..)
import Html.Attributes exposing (class, target, href, defaultValue, type_, checked, placeholder, value)
import Html.Events exposing (..)
import Json.Decode exposing (Decoder, Value, decodeValue)
import Json.Decode.Pipeline exposing (..)
import Types exposing (..)
import Ports exposing (githubSearch, githubResponse)


-- Init


init : ( Model, Cmd msg )
init =
    ( initialModel, githubSearch (getQueryString initialModel) )



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


getQueryString : Model -> String
getQueryString model =
    "access_token="
        ++ Auth.token
        ++ "&q="
        ++ model.query
        ++ "+in:"
        ++ model.options.searchIn
        ++ "+stars:>="
        ++ (toString model.options.minStars)
        ++ "+language:elm"
        ++ (if String.isEmpty model.options.userFilter then
                ""
            else
                "+user:" ++ model.options.userFilter
           )
        ++ "&sort=stars&order=desc"



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
        [ header []
            [ h1 [] [ text "ElmHub" ]
            , span [ class "tagline" ] [ text "Like GitHub, but for Elm things." ]
            ]
        , div [ class "search" ]
            -- maps the view to the Options type constructor
            [ Html.map Types.Options (viewSearchOptions model.options)
            , div [ class "search-input" ]
                [ input [ class "search-query", onInput SetQuery, defaultValue model.query ] []
                , button [ class "search-button", onClick Search ] [ text "Search" ]
                ]
            ]
        , viewErrorMessage model.errorMessage
        , ul [ class "results" ] (List.map viewSearchResult model.results)
        ]


viewSearchOptions : SearchOptions -> Html OptionsMsg
viewSearchOptions opts =
    div [ class "search-options" ]
        [ div [ class "search-option" ]
            [ label [ class "top-level" ] [ text "Search in" ]
            , select [ onChange SetSearchIn, value opts.searchIn ]
                [ option [ value "name" ] [ text "Name" ]
                , option [ value "description" ] [ text "Description" ]
                , option [ value "name,description" ] [ text "Name and Description" ]
                ]
            ]
        , div [ class "search-option" ]
            [ label [ class "top-level" ] [ text "Owned by" ]
            , input
                [ type_ "text"
                , placeholder "Enter a username"
                , defaultValue opts.userFilter
                , onInput SetUserFilter
                ]
                []
            ]
        , div [ class "search-option" ]
            [ label [ class "top-level" ] [ text "Minimum stars" ]
            , input
                [ type_ "text"
                , defaultValue (toString opts.minStars)
                , onBlurWithTargetValue SetMinStars
                ]
                []
            , viewMinStarsError opts.minStarsError
            ]
        ]


viewMinStarsError : Maybe String -> Html msg
viewMinStarsError message =
    case message of
        Nothing ->
            text " "

        Just errorMessage ->
            div [ class "stars-error" ] [ text errorMessage ]


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
        [ span [ class "star-count" ] [ text (toString result.stars) ]
        , a [ href ("https://github.com/" ++ result.name), target "_blank" ]
            [ text result.name ]
        , button
            [ class "hide-result", onClick (DeleteById result.id) ]
            [ text "X" ]
        ]



-- HTML EVENTS MAP


onChange : (String -> msg) -> Attribute msg
onChange toMsg =
    on "change" (Json.Decode.map toMsg Html.Events.targetValue)


onBlurWithTargetValue : (String -> msg) -> Attribute msg
onBlurWithTargetValue toMsg =
    on "blur" (Json.Decode.map toMsg targetValue)



-- UPDATE


updateOptions : OptionsMsg -> SearchOptions -> SearchOptions
updateOptions optionsMsg options =
    case optionsMsg of
        SetMinStars minStarsStr ->
            case String.toInt minStarsStr of
                Ok minStars ->
                    { options | minStars = minStars, minStarsError = Nothing }

                Err _ ->
                    { options | minStarsError = Just "Must be an interger!" }

        SetSearchIn searchIn ->
            { options | searchIn = searchIn }

        SetUserFilter userFilter ->
            { options | userFilter = userFilter }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search ->
            ( { model | errorMessage = Nothing }
            , githubSearch (getQueryString model)
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

        Options searchOptions ->
            ( { model | options = (updateOptions searchOptions model.options) }, Cmd.none )
