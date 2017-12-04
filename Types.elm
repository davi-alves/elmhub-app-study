module Types exposing (..)

import Table


type alias SearchResult =
    { id : Int
    , name : String
    , stars : Int
    }


type alias Model =
    { query : String
    , results : List SearchResult
    , errorMessage : Maybe String
    , options : SearchOptions
    , tableState : Table.State
    }


type alias SearchOptions =
    { minStars : Int
    , minStarsError : Maybe String
    , searchIn : String
    , userFilter : String
    }


type Msg
    = Search
    | SetQuery String
    | DeleteById Int
    | HandleSearchResponse (List SearchResult)
    | HandleSearchError (Maybe String)
    | Options OptionsMsg
    | SetTableState Table.State
    | DoNothing


type OptionsMsg
    = SetMinStars String
    | SetSearchIn String
    | SetUserFilter String
