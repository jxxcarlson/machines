module Main exposing (main)

import Html exposing (Html, pre , text)


-- MAIN

main : Html msg
main =
    Html.pre [] [
     line "TESTS:"
     , test "input" theInputList
     , test "internalstate 0 " state0
     , test "internalstate 1 " state1
     , test "output" (run (makeReducer outputValue) theInputList)
     , test "str input" inputStringList
     , test "str output" (run (makeReducer stringJoiner) inputStringList)
     , test "str output2" (run (makeReducer stringJoiner2) inputStringList)
     , test "str output2b" (run (makeReducer stringJoiner2) inputStringList |> String.join "")
     ]
 
 
-- DISPLAY FUNCTONS
  
line str = text (str ++ "\n\n")
test a b = text (a ++ ": " ++ Debug.toString b ++ "\n\n")


-- EXAMPLES

theInputList = [0, 1, 2, 3, 4]
inputStringList = ["He", "said", ",", "Wow", "!"]
state0 = initialInternalState theInputList
state1 = nextInternalState state0
  
  
  
-- TYPES
     
type alias InternalState a = {before: Maybe a, current: Maybe a, after: Maybe a, inputList: List a}

type alias MachineState a b = {internalstate: InternalState a, outputList: List b}

type alias Reducer a b = a -> MachineState a b -> MachineState a b


-- RUNNERS

run_ : Reducer a b -> MachineState a b -> List a -> MachineState a b
run_ reducer initialMachineState_ inputList = 
  List.foldl reducer initialMachineState_ inputList
  
 
run : Reducer a b -> List a -> List b
run reducer inputList = 
  let
    initialMachineState_ = initialMachineState inputList 
    finalState = run_ reducer initialMachineState_ inputList
  in
    List.reverse finalState.outputList  
 
 
-- INITIALIZERS
    
initialMachineState : List a -> MachineState a b
initialMachineState inputList = 
  {internalstate =  initialInternalState inputList, outputList = []}
  
initialInternalState : List a -> InternalState a
initialInternalState inputList = 
  {before = Nothing
   , current = List.head inputList 
   , after = List.head (List.drop 1 inputList)
   , inputList = inputList
   }
   

-- NEXT internalstate FUNCTION

nextInternalState : InternalState a -> InternalState a
nextInternalState internalState_ = 
  let 
     nextInputList_ = List.drop 1 internalState_.inputList
  in
  {  
    before = internalState_.current
   , current = internalState_.after 
   , after = List.head (List.drop 1 nextInputList_)
   , inputList = nextInputList_
  }


-- A REDUCER MAKER

makeReducer : (InternalState a -> b) -> Reducer a b
makeReducer computeOutput input machineState =
  let 
    nextInputList = List.drop 1 machineState.internalstate.inputList  
    nextInternalState_ = nextInternalState machineState.internalstate
    newOutput = computeOutput machineState.internalstate
    outputList = newOutput::machineState.outputList 
  in
    {internalstate = nextInternalState_, outputList = outputList}

  

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
  