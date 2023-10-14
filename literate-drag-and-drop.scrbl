#lang scribble/lp2

@title{Literate Drag and Drop Using the Racket GUI}
@author[(author+email "Justin Zamora" "justin@zamora.com")]

@section{Introduction}

[This example was created for the 
@hyperlink["https://racket.discourse.group/t/the-2023-racket-summer-event"]{2023
Racket Summer Event}. The source file is available at 
@hyperlink["https://github.com/zamora/literate-drag-and-drop"]{my GitHub}.] 

The @hyperlink["https://www.racket-lang.org/"]{Racket Programming Language} 
has an excellent cross-platform 
@hyperlink["https://docs.racket-lang.org/gui/index.html"]{GUI} that doesn't 
get as much attention as it deserves. In this example, I describe one way to 
implement a drag-and-drop protocol using the Racket GUI. Although not 
required, it will be helpful to have basic familiarity with the Racket GUI 
and its classes. 

This example implements a minimal program that draws two objects on a light 
blue background: a rectangular flag and a @racket[standard-fish]. You can use 
your mouse to drag the two objects around and place them anywhere on the 
canvas. Be careful, though: this example program is not robust. It doesn't do 
any bounds checking, so it is possible to drag the objects outside the window 
and lose them forever. If this happens, you will need to restart the program. 

@section{Literate Programming}

This is a 
@hyperlink["https://en.wikipedia.org/wiki/Literate_programming"]{literate 
program}. That means that the 
@hyperlink["https://github.com/zamora/literate-drag-and-drop"]{source code} 
produces both the program and its documentation using the same files. 
Racket's literate programming language, called @racketmodname[scribble/lp2], 
separates the code from the documentation and processes each of them 
appropriately.

To run the program, open the @racketplainfont{literate-drag-and-drop.scrbl} 
file in 
@hyperlink["https://docs.racket-lang.org/drracket/index.html"]{DrRacket} and 
click on ``Run''. You can also run @racketplainfont{racket 
literate-drag-and-drop.scrbl} from the command line. To generate HTML 
documentation, either open the @racketplainfont{literate-drag-and-drop.scrbl} 
file in 
@hyperlink["https://docs.racket-lang.org/drracket/index.html"]{DrRacket} and 
click on “Scribble HTML” or run @racketplainfont{scribble +m 
literate-drag-and-drop.scrbl} from the command line. 

In a literate program, chunks of code are interspersed with the text of the 
documentation. In @racketmodname[scribble/lp2], by convention, the chunks are 
given names that start with @litchar{<} and end with @litchar{>}. Chunk names 
can appear within the code to refer to other chunks. When Racket processes 
the file, it gathers all the chunks and puts them in the correct order to 
produce the final program. 

One advantage of literate programming is that, by having the code and the 
documentation in the same file, you can develop them together so that they 
reinforce each other. You can describe the thinking and reasoning behind a 
program in more depth and in a better format than that allowed by normal 
comments. 

@section{Requiring the Racket GUI}

We start our program by requiring the @racket[racket/gui] library. This gives 
us access to all the tools and functions of the Racket GUI. 

@chunk[<require-racket/gui>
       (require racket/gui)]

Note: In normal programs, we can specify the Racket GUI language by using 
@racket[@#,hash-lang[] @#,racketmodname[racket/gui]], however, since we are 
using Racket's literate programming, our language is 
@racketmodname[scribble/lp2]}, and the current version of 
@racketmodname[scribble/lp2] doesn't allow us to specify another language for 
the code. Some other literate programming packages, like 
@hyperlink["https://docs.racket-lang.org/hyper-literate/"]{Suzanne Soy's 
Hyper-literate programming} and 
@hyperlink["https://docs.racket-lang.org/brush/index.html"]{David 
Christiansen's Brush} provide options for specifying other languages. 
S
@section{A Class for Draggable Objects}

The first thing we will do is create an abstract class called 
@racket[draggable-object%] to represent a GUI object that can be dragged 
around on a @racket[canvas%]. Each different kind of draggable object will be 
a subclass that implements methods specialized for that particular kind of 
object. 

A draggable object has to have the following things: 

@itemlist[@item{The position of the object on a canvas}
          @item{A method to draw a visual representation of the object}
          @item{A method to determine whether the user clicked on the object}
          @item{A method to change the position of the object as it is dragged}]

@subsection{Position of the Object}

The position of the object is represented using two fields for the @italic{x} 
and @italic{y} coordinates of the object. We also define getter and setter 
methods for the fields. 

@chunk[<position-methods>
       (init-field x)
       (init-field y)
       (define/public (get-x) x)
       (define/public (set-x v) (set! x v))
       (define/public (get-y) y)
       (define/public (set-y v) (set! y v))]

@subsection{Drawing and Clicking on an Object}

Our class needs to have a @racket[draw] method to do the actual drawing of 
the object. To determine whether the user clicked on the object, we also need 
a method, which we'll call @racket[contains?], that returns @racket[#t] if 
the @italic{x} and @italic{y} coordinates of a mouse click are within the 
bounds of the object. 

Because every kind of object will need to be drawn differently, we cannot 
provide an implementation in the @racket[draggable-object%] class. Instead, 
we use the @racket[abstract] clause to declare a @racket[draw] method without 
an implementation. The code to draw the object will need to be provided by 
each subclass of @racket[draggable-object%]. 

Since we don't know how the object is drawn, we also have no way to tell 
whether the user has clicked within the bounds of the object. So 
@racket[contains?] must also be declared as @racket[abstract]. 

The code for our abstract methods is very simple:

@chunk[<abstract-methods>
       (abstract contains?)
       (abstract draw)]

@subsection[#:tag "dragging-an-object"]{Dragging an Object}

We need to define a method, which we'll call @racket[on-drag], that is called 
when the user drags the mouse. This method is responsible for moving the 
object to follow the mouse as it is dragged. 

It turns out that the @racket[on-drag] method needs to share information and 
cooperate with other mouse-handling methods, so the details of its 
implementation are given along with the other mouse actions in the section 
``@secref{mouse-events}''. 

@subsection{Final Class}

Having worked out all the requirements of a draggable object, here is the 
final definition of the @racket[draggable-object%] class. 

@chunk[<draggable-object>
       (define draggable-object%
         (class object%
           (super-new)
           <abstract-methods>
           <position-methods>
           <on-drag-method>))]

@section{Draggable Flag}

Now that we have defined our @racket[draggable-object%] class, we can create 
a subclass to represent a draggable flag. 

@chunk[<draggable-flag>
       (define draggable-flag%
         (class draggable-object%
           (super-new)
           (inherit-field x)
           (inherit-field y)
           (init-field width)
           (init-field height)
           <flag-draw>
           <flag-contains?>))]

In this subclass, we inherit the @racket[x] and @racket[y] position fields 
from @racket[draggable-object%]. We then add @racket[width] and 
@racket[height] fields to represent the dimensions of the flag. 

@subsection{Flag @racket[draw] Method}

We now define the @racket[draw] method for our flag, which will consist of a 
rectangular background with a circle in the center. Since @racket[draw] in 
the parent class is an abstract method, we use @racket[define/override] to 
override the abstract method and provide our own implementation. 

@chunk[<flag-draw>
       (define/override (draw dc)
         (code:comment "Draw the rectangle")
         (send dc set-pen "black" 1 'transparent)
         (send dc set-brush "darkmagenta" 'solid)
         (send dc draw-rectangle x y width height)

         (code:comment "Draw the circle")
         (send dc set-brush "yellow" 'solid)
         (let ([diameter (* height 0.6)])
           (send dc draw-ellipse
                 (+ x (/ (- width diameter) 2))
                 (+ y (/ (- height diameter) 2))
                 diameter
                 diameter)))]          

We draw the flag in two stages: the rectangle and then the circle. We set the 
pen to be transparent so that the flag doesn't have a border. Next, we set 
the color of the rectangle to be dark magenta. I chose dark magenta for 
@hyperlink["https://venngage.com/blog/accessible-colors"]{accessibility}, 
because it provides good contrast against the light blue background. 

For the circle, we set color to yellow (again, to improve contrast and 
accessibility). Then we draw the circle itself, using the 
@racket[draw-ellipse] method. We use a little bit of math to position the 
circle at the center of the rectangle. 

@subsection{Flag @racket[contains?] Method}

@margin-note{For some objects, only certain "hot spots" should be clickable 
and not the entire object. In that case, @racket[contains?] should return 
@racket[#t] if the point is in any of the hot spots.} 

The @racket[contains?] method takes an (@italic{x}, @italic{y}) coordinate 
and returns @racket[#t] if the coordinate lies inside the flag. This is used 
to determine whether the user clicked on the object. 

For complex objects, the check could be quite involved, but since this is a
simple shape, the check is very straightforward. 

@chunk[<flag-contains?>
       (define/override (contains? x0 y0)
         (and (< x x0 (+ x width))
              (< y y0 (+ y height))))]

@section{Draggable Fish}

We want our second object to be a @racket[standard-fish]. Since 
@racket[standard-fish] is part of the @racketmodname[pict] library of 
functional pictures, we need to use @racket[require] to access its 
definition. 

@chunk[<require-pict>
       (require pict)]

The class for a draggable fish is very much like @racket[draggable-flag]: we 
inherit the position fields, add width and height fields, and override the 
abstract @racket[draw] method. 

@chunk[<draggable-fish>
       (define draggable-fish%
         (class draggable-object%
           (super-new)
           (inherit-field x)
           (inherit-field y)
           (init-field width)
           (init-field height)
           <fish-draw>
           <fish-contains?>))]

The implementation of the @racket[draw] method is also very simple; we just 
use the @racket[draw-pict] function to draw the fish. 

@chunk[<fish-draw>
       (define/override (draw dc)
         (draw-pict (standard-fish width height #:color "salmon") dc x y))]

The fish is close enough to rectangular that we can use its bounding box to 
check whether the user clicked on it. 

@chunk[<fish-contains?>
       (define/override (contains? x0 y0)
         (and (< x x0 (+ x width))
              (< y y0 (+ y height))))]

@section{Defining the Canvas}

A @racket[canvas%] is a GUI object that lets you draw inside of it. It can 
also receive and handle events from the keyboard, mouse, and other GUI 
objects. 

We create a subclass of @racket[canvas%] specialized for handling and 
displaying our draggable objects. 

@chunk[<drag-canvas>
       (define drag-canvas%
         (class canvas%
           (inherit get-dc get-width get-height refresh)

           <draw-background>
           <draw-objects>
           <handle-mouse-events>
    
           (super-new [paint-callback (lambda (canvas dc)
                                        (draw-background dc)
                                        (draw-objects dc))])))]

Our subclass inherits the methods we will use and defines methods to draw the 
background, draw the objects, and handle the mouse events.

After defining the methods, we initialize the parent class using 
@racket[super-new] and define the paint callback. @racket[paint-callback] is 
a function that is called whenever the canvas needs to redraw its contents. 
In our case, the callback calls procedures to draw the background and then 
draw the two objects. 

Drawing the background is very simple. 

@chunk[<draw-background>
       (define (draw-background dc)
         (send dc set-background "lightblue")
         (send dc clear))]

Drawing the objects is more involved. For this example program, there are 
only two objects, so I just draw them one after the other. 

@chunk[<draw-objects>
       (define (draw-objects dc)
         (send my-fish draw dc)
         (send my-flag draw dc))]

That works for an example like this one, but it is insufficient for a real 
program. First of all, it always draws the fish first and then the flag. This 
means that the flag is always on top, even if you are dragging the fish. 

Secondly, this approach doesn't scale. The objects should be stored in a data 
structure instead of built into the code. You also want to keep track of the 
order of the objects so that they can be drawn correctly. 

@section[#:tag "mouse-events"]{Handling Mouse Events}

Whenever the user moves the mouse or performs a mouse operation such as 
clicking or dragging, the Racket GUI sends a 
@hyperlink["https://docs.racket-lang.org/gui/mouse-event_.html"]{mouse event} 
to the canvas. We define the @method[canvas<%> on-event] method to handle 
these events. We also define some variables needed by the event handlers.

The @method[canvas<%> on-event] method checks what kind of event it is and 
executes the appropriate code. We respond to three different events: 
@method[mouse-event% button-down?], @method[mouse-event% dragging?], and 
@method[mouse-event% button-up?]. After handling the events, we call the 
@method[window<%> refresh] method to redraw the canvas. 

@chunk[<handle-mouse-events>
       <define-mouse-event-variables>
       (define/override (on-event event)
         (cond
           [(send event button-down?) <button-down>]
           [(send event dragging?) <dragging>]
           [(send event button-up?) <button-up>])
         (refresh))]

@subsection{Event Handling Variables}

The event handlers need to share some information about the object being 
dragged, so we define three variables. The @racket[active-object] variable 
will always refer to the object being dragged. Two offset variables are 
necessary to ensure the smooth movement of the object while dragging. 

@chunk[<define-mouse-event-variables>
       (define active-object null)
       (define offset-x 0)
       (define offset-y 0)]

To understand why we need the offsets, note that all objects are positioned 
and drawn relative to a starting point. For example, most of the objects in 
the @racketmodname[racket/draw] and @racketmodname[pict] libraries are drawn 
relative to the top left corner of the bounding rectangle. This creates 
problems for us when dragging an object. 

The issue is that a user can click anywhere within the object before dragging 
it, and this location could be quite far away from the starting point of the 
object. If we use the mouse location as the starting point for drawing the 
object, the object would ``jump'' to its new location rather than moving 
smoothly. 

Instead, we need the object to move as if the user clicked on the actual 
starting point. For example, if the starting point is at (100, 200), and the 
user clicks at (130, 220), then we need to subtract 30 from the 
@italic{x}-coordinate and 20 from the @italic{y}-coordinate so that we can 
draw the object in the right place, without any jumps. 

To implement this, when the user clicks on the mouse button, we compute the 
difference between the mouse location and the starting point and store the 
result in the offset variables. Then, when we draw the object during the drag 
operation, we subtract the offset from the mouse location, so that the object 
is drawn in the correct place. 

@subsection{Button Down Event}

A dragging operation begins when the user presses the mouse button. When this 
happens, the canvas receives a @method[mouse-event% button-down?] event. The 
first we do in response is identify which, if any, of the objects the user 
clicked on. 

To do this, we create a helper function, @racket[object-at], that takes the 
@italic{x} and @italic{y} coordinates of the mouse and returns the object at 
those coordinates. If there is no object, it returns @racket[null]. 

@chunk[<object-at>
       (define (object-at x y)
         (cond
           [(send my-flag contains? x y) my-flag]
           [(send my-fish contains? x y) my-fish]
           [else null]))]

As with the @racket[draw-objects] method, we call the @racket[contains?] 
method for each object in turn, returning it if the object contains the 
coordinates. Also, as before, this is not a good method for a real program. A 
better choice is to use something like a 
@hyperlink["https://en.wikipedia.org/wiki/K-d_tree"]{@italic{k}-d tree} to 
store the objects so that they can be searched efficiently using the 
coordinates. 

Now we are ready for the implementation of the @method[mouse-event% 
button-down?] handler itself. When we receive a @method[mouse-event% 
button-down?], we get the @italic{x} and @italic{y} coordinates of the mouse. 
Then we call @racket[object-at] to locate the object the user clicked on and 
store it in the @racket[active-object] variable. Finally, we compute the 
@italic{x} and @italic{y} offsets. 

@chunk[<button-down>
       <object-at>
       (let ([x (send event get-x)]
             [y (send event get-y)])
         (let ([clicked-object (object-at x y)])
           (when (not (null? clicked-object))
             (set! active-object clicked-object)
             (set! offset-x (- x (send clicked-object get-x)))
             (set! offset-y (- y (send clicked-object get-y))))))]

@subsection{Dragging Event}

When we receive a dragging event, we make sure that the user is dragging on 
an object. Then we get the new location of the mouse and call the object's 
@racket[on-drag] method (see ``@secref{dragging-an-object}''). We pass the 
new location and the offsets so that @racket[on-drag] can move the object 
smoothly. 

@chunk[<dragging>
       (when (not (null? active-object))
         (send active-object on-drag
               (send event get-x)
               (send event get-y)
               offset-x
               offset-y))]

@margin-note{Here we see one of the strengths of literate programming. Even 
though @racket[on-drag] is a method of @racket[draggable-object%], we are 
able to describe it here alongside the event handlers, and Racket's literate 
programming language will put the code where it belongs.} 

Now we can finally implement the @racket[on-drag] method of the 
@racket[draggable-object%] class. The method subtracts the @italic{x} and 
@italic{y} offsets from the mouse location and uses the result to set the 
new position of the object. 

@chunk[<on-drag-method>
       (define/public (on-drag x0 y0 offset-x offset-y)
         (set! x (- x0 offset-x))
         (set! y (- y0 offset-y )))]

@subsection{Button Up Event}

When the user releases the button, the dragging operation is over, so our 
@racket[button-up] handler needs to clean up by resetting the 
@racket[active-object] and the offset variables. 

@chunk[<button-up>
       (set! active-object null)
       (set! offset-x 0)
       (set! offset-y 0)]

@section{Main Program}

Now that we have the canvas and object classes defined, all that is left is 
to create the main program. Since the classes do all the hard work, this is 
straightforward. We start by defining constants for the width and height of 
our canvas. 

@chunk[<define-constants>
       (define WIDTH 640)
       (define HEIGHT 480)]

Next, we create instances of a flag and a fish. We use a little bit of math to 
position them nicely on the canvas. 

@chunk[<create-instances>
       (define my-flag (new draggable-flag%
                            [x (- (* WIDTH 1/3) 37)]
                            [y (/ (- HEIGHT 50) 2)]
                            [width 75]
                            [height 50]))
       (define my-fish (new draggable-fish%
                            [x (- (* WIDTH 2/3) 50)]
                            [y (/ (- HEIGHT 50) 2)]
                            [width 100]
                            [height 50]))]

The final step is to create the frame and canvas for the GUI and display 
them. 

@chunk[<initialize-gui>
       (define frame (new frame% [label "Drag and Drop Example"]
                          [width WIDTH]
                          [height HEIGHT]))

       (define canvas (new drag-canvas% [parent frame]
                           [min-width WIDTH]
                           [min-height HEIGHT]))

       (send frame show #t)]       

And that's it! We now have a simple, but complete example of implementing 
drag-and-drop within the Racket GUI. We've also gotten a taste of literate 
programming and some of its features. I encourage you to explore more 
features of the Racket GUI library and incorporate them into your own 
projects. Have fun! 

@section{Appendix: Code Outline}

Here is the outline of the entire program. Racket's literate programming 
language uses this outline to gather the chunks that we defined throughout 
this document and assemble them into the final, runnable program. 

@chunk[<*>
       <require-racket/gui>
       <draggable-object>
       <draggable-flag>
       <require-pict>
       <draggable-fish>
       <drag-canvas>

       <define-constants>
       <create-instances>
       <initialize-gui>]
