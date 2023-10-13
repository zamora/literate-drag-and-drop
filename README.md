Literate Drag and Drop Using the Racket GUI
===========================================
.
[This example was created for the [2023 Racket Summer Event](https://racket.discourse.group/t/the-2023-racket-summer-event).]

The [Racket Programming Language](https://www.racket-lang.org/) has an excellent cross-platform [GUI](https://docs.racket-lang.org/gui/index.html) that doesn't 
get as much attention as it deserves. In this example, I describe one way to implement a drag-and-drop protocol using the Racket GUI. Although not 
required, it will be helpful to have basic familiarity with the Racket GUI and its classes. 

This is a [literate program](https://en.wikipedia.org/wiki/Literate_programming). That means that the 
source code produces both the program and its documentation using the same files. Racket's literate programming language, called [scribble/lp2](https://docs.racket-lang.org/scribble/lp.html), separates the code from the documentation and processes each of them appropriately. 

To run the program, open the `literate-drag-and-drop.scrbl` file in [DrRacket](https://docs.racket-lang.org/drracket/index.html") and click on “Run”. You can also run `racket literate-drag-and-drop.scrbl` from the command line. To generate HTML documentation, either open the `literate-drag-and-drop.scrbl` file in [DrRacket](https://docs.racket-lang.org/drracket/index.html") and click on “Scribble HTML” or run `scribble +m literate-drag-and-drop.scrbl` from the command line.
