module Main exposing (main)

import Html exposing (Html, pre , text)
import ListMachine exposing(runMachine, InternalState)

-- MAIN

main : Html msg
main =
    Html.pre [] [
     line "TESTS:"
     , test "input" theInputList
     , test "output" (runMachine outputValue theInputList)
     , test "str input" inputStringList
     , test "str output" (runMachine stringJoiner inputStringList)
     , test "str output2" (runMachine stringJoiner2 inputStringList)
     , test "str output2b" ((runMachine stringJoiner2 inputStringList) |> String.join "")
     ]
 
 
-- DISPLAY FUNCTONS
  
line str = text (str ++ "\n\n")
test a b = text (a ++ ": " ++ Debug.toString b ++ "\n\n")


-- EXAMPLES

theInputList = [0, 1, 2, 3, 4]
inputStringList = ["He", "said", ",", "Wow", "!"]
  
 
-- COMPUTE AN OUTPUT VALUE FROM THE INTERNAL internalstate

outputValue : InternalState Int -> Int 
outputValue internalState = 
  let
    a = internalState.before  |> Maybe.withDefault 0 
    b = internalState.current |> Maybe.withDefault 0 
    c = internalState.after   |> Maybe.withDefault 0 
  in  
    a + b + c

type SpacingSymbol = Space | NoSpace | EndParagraph

stringJoiner : InternalState String -> (String, SpacingSymbol)
stringJoiner internalState =
  let 
    b = internalState.current |> Maybe.withDefault ""
    c = internalState.after   |> Maybe.withDefault "" 
    symbol =  if internalState.after == Nothing then 
                  EndParagraph
              else if List.member (String.left 1 c) 
                  [",", ";", ".", ":", "?", "!"] then 
                  NoSpace 
              else 
                  Space
  in 
    (b, symbol)

stringJoiner2 : InternalState String -> String
stringJoiner2 internalState =
  let 
    b = internalState.current |> Maybe.withDefault ""
    c = internalState.after   |> Maybe.withDefault "" 
    output =  if internalState.after == Nothing then 
                  b ++ "\n\n"
              else if List.member (String.left 1 c) 
                  [",", ";", ".", ":", "?", "!"] then 
                  b 
              else 
                  b ++ " "
  in 
    output
  