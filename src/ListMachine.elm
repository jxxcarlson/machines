 
module ListMachine exposing(runMachine, InternalState)  

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
 
runMachine : (InternalState a -> b) -> List a -> List b 
runMachine outputFunction inputList = 
  run (makeReducer outputFunction) inputList 


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

  
