module Main exposing (main)

import Html exposing (Html, pre , text)


-- MAIN

main : Html msg
main =
    Html.pre [] [
     line "TESTS:"
     , test "input" theInputList
     , test "state 0 " state0
     , test "state 1 " state1
     , test "output" (run (makeReducer outputValue) theInputList)
     ]
 
 
-- DISPLAY FUNCTONS
  
line str = text (str ++ "\n\n")
test a b = text (a ++ ": " ++ Debug.toString b ++ "\n\n")


-- EXAMPLES

theInputList = [0, 1, 2, 3, 4]
state0 = initialInternalState theInputList
state1 = nextInternalState state0
  
  
  
-- TYPES
     
type alias InternalState a = {before: Maybe a, current: Maybe a, after: Maybe a, inputList: List a}

type alias MachineState a b = {state: InternalState a, outputList: List b}

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
  {state =  initialInternalState inputList, outputList = []}
  
initialInternalState : List a -> InternalState a
initialInternalState inputList = 
  {before = Nothing
   , current = List.head inputList 
   , after = List.head (List.drop 1 inputList)
   , inputList = inputList
   }
   

-- NEXT STATE FUNCTION

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
    nextInputList = List.drop 1 machineState.state.inputList  
    nextInternalState_ = nextInternalState machineState.state
    newOutput = computeOutput machineState.state
    outputList = newOutput::machineState.outputList 
  in
    {state = nextInternalState_, outputList = outputList}

  

-- COMPUTE AN OUTPUT VALUE FROM THE INTERNAL STATE

outputValue : InternalState Int -> Int 
outputValue internalState = 
  let
    a = internalState.before  |> Maybe.withDefault 0 
    b = internalState.current |> Maybe.withDefault 0 
    c = internalState.after   |> Maybe.withDefault 0 
  in  
    a + b + c
