
module Main exposing (main)

import Html exposing (Html, pre , text)


line str = text (str ++ "\n\n")
test a b = text (a ++ ": " ++ Debug.toString b ++ "\n\n")


theList = [0, 1, 2, 3, 4]
iis = initialInternalState theList
nis = nextInternalState iis


main : Html msg
main =
    Html.pre [] [
     line "TESTS:"
     , test "input" theList
     , test "output" (run reduce theList)
     , test "iis " iis
     , test "nis "nis
     --, test "reduce input" (run_ reduce (initialMachineState [0, 1, 2, 3]) [0,1,2,3])
     ]
     
     

-- type alias InputState a = {before: Maybe a, current: Maybe a, after: Mabye a}

type alias InternalState a = {before: Maybe a, current: Maybe a, after: Maybe a, inputList: List a}

type alias MachineState a b = {state: InternalState a, outputList: List b}

type alias Reducer a b = a -> MachineState a b -> MachineState a b


{-|  A machine uses a reducer and an initial machine state to transform a list
of inputs to a final machine state. That state consists of a final internal
state and a list of outputs.
-}
type alias Machine a b = Reducer a b -> MachineState a b -> List a -> MachineState a b


outputValue : InternalState Int -> Int 
outputValue internalState = 
  let
    a = internalState.before |> Maybe.withDefault 0 
    b = internalState.current |> Maybe.withDefault 0 
    c = internalState.after |> Maybe.withDefault 0 
  in 
    a + b + c

initialInternalState : List a -> InternalState a
initialInternalState inputList = 
  {before = Nothing
   , current = List.head inputList 
   , after = List.head (List.drop 1 inputList)
   , inputList = inputList}
   
  
nextInternalState : InternalState a -> InternalState a
nextInternalState internalState_ = 
  let 
     nextInputList_ = List.drop 1 internalState_.inputList
  in
  {  
    before = internalState_.current
   , current = internalState_.after 
   , after = List.head (List.drop 1 nextInputList_)
   , inputList = nextInputList_}

   
initialMachineState : List Int -> MachineState Int Int
initialMachineState inputList = 
  {state =  initialInternalState inputList, outputList = []}
  


reduce : Reducer Int Int 
reduce input machineState =
  let 
    nextInputList = List.drop 1 machineState.state.inputList  
    nextInternalState_ = nextInternalState machineState.state
    newOutput = outputValue machineState.state
    outputList = newOutput::machineState.outputList 
  in
    {state = nextInternalState_, outputList = outputList}
    

run_ : Reducer a b -> MachineState a b -> List a -> MachineState a b
run_ reducer initialMachineState_ inputList = 
  List.foldl reducer initialMachineState_ inputList
  
 
run : Reducer Int Int -> List Int -> List Int
run reducer inputList = 
  let
    initialMachineState_ = initialMachineState inputList 
    finalState = run_ reducer initialMachineState_ inputList
  in
    List.reverse finalState.outputList
    
    
    
    
    
    


  