

ListMachines
============

Overview
--------

A `ListMachine` takes as input a `List a` and produces
as output a `List b`.  Processing occurs as follows.
The machine reads the input list element by element,
adding an element to the output list at each step.
Call the input element that is being read at the moment
the "current" element. Then one has the notions of the element
before the current one and the element after the current one.
We model these as values of type `Maybe a`, since
`Nothing` can occur, e.g., when the first element
of the input list is being read.  These notions are
implemented in `InternalState` by a record
with fields `before`, `current`, and `after`.  An output
element is computed  by a function `outputFunction` 
of `InternalState`.

See [Making Functional Machines with Elm](https://medium.com/@jxxcarlson/making-functional-machines-with-elm-c07700bba13c)


Below is an example of a simple list machine
in operation. The output function `f` is,
in rough terms, given by

```
   f before current after = before + current + after
```

with obvious changes to account for the fact that
we are using `Maybe a` values.


```
Step 0:  Input = [0, 1, 2, 3, 4]  Output = [ ]
Step 1:  Input = [1, 2, 3, 4]     Output = [1]
Step 2:  Input = [2, 3, 4]        Output = [1, 3]
Step 3:  Input = [3, 4]           Output = [1, 3, 6]
Step 4:  Input = [4]              Output = [1, 3, 6, 9]
Step 5:  Input = [ ]              Output = [1, 3, 6, 9, 7]
```


Defining and running a ListMachine
----------------------------------

There is a fair amount of internal plumbing
in the `ListMachine` module.  However, this
module exposes only one function, `runMachine`,
and one type, `InternalState`. To define a `ListMachine`, 
one needs only define an output function, 
which has type signature

```
InternalState a -> b
```

To run the corresponding machine, execute

```
runMachine outputFunction inputList
```

Let's see how this works in the
example discussed above.  The outputFunction is

```
sumState : InternalState Int -> Int 
sumState internalState = 
  let
    a = internalState.before  |> Maybe.withDefault 0 
    b = internalState.current |> Maybe.withDefault 0 
    c = internalState.after   |> Maybe.withDefault 0 
  in  
    a + b + c
```

Thus, we can say

```
runMachine sumState [0,1,2,3,4]
```

to compute the value [1, 3, 6, 9, 7]


Compilation
------------


Compile with

```
$ cd examples
$ elm make src/Main.elm
```

Then click on the resulting `index.html`





