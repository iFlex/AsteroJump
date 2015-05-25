### Why You Should Get It ###

CBEffects is entirely free and open-source, infinitely customizable, and generates moderate to low memory overhead. It takes a completely different slant on particle effects to provide the easiest, fastest route to the most advanced and stunning visuals around.

Most particle systems attempt to "hold your hand" throughout the whole experience of creating effects. With CBEffects, a substantial amount of "hand holding" was included to make things easier, but it was also taken into account that too much is... too much. Thus, you can either use static values for parameters or go out on your own and use functions to define just about everything.

For example, if you want a varying velocity for particles, that would be pretty easy with most particle systems (except for *really* hard-core "hand holders"). But what about if you want a velocity that cycles through from 0.5 to 1.5 and then cycles backwards and after it's made an entire revolution starts picking random numbers from 1 to 5? Can you make a function that does that? Stick the function into the effect parameters under the name "velocity". Finished. If you can do it in a function, you can do it with CBEffects.

What about another example. Say you want particles to be an animated sprite. Simple enough. What about an animated sprite that plays at a random speed per particle? Still pretty simple. What about an animated sprite with a width that varies between 100 pixels and 500 pixels and then after the particle engine has emitted particles 50 times change the height to a constant 200 pixels and the spritesheet file to a different one and the reference point to topLeft and then the play speed for the sprite to 10 milliseconds between frames? Again, **if you can do it in a function, you can do it with CBEffects.**

### CBEffects and the Problem With OSS ###

Sometimes, free software can be... um... weak. It's understandable - most people wouldn't put as much work into something they're not getting return from. However, this is by no means the case with CBEffects. Since the time I created it (to rival the leading paid library), it has been under active development.

### The CBEffects Method ###
Instead of keeping track of particle effects internally like a lot of particle systems do, CBEffects simply creates the object and gives you the handle. Then, all methods are accomplished **with the handle**, not through the library. The CBEffects library, after being included into your project, is just a placeholder for the effect functions - after creating your objects, you don't need to use any library methods again.

### What's up with the Parameter Count? ###
Taking a glance at the number of possible parameters can be daunting. Never fear, though - you will never need to use all of them. The reason there are so many parameters is so that titles can be meaningful. For example, which is easier to understand, the first one or the second one:

###### 1. ######
```Lua
positionType = "alongLine",
positionParameter1 = {10, 10},
positionParameter2 = {100, 10}
```
###### 2. ######
```Lua
positionType = "alongLine",
point1 = {10, 10},
point2 = {100, 10}
```
Unless you happen to be from the planet Neptune (or maybe are a really hard-core programmer who knows everything there is to know), the second should be easier. The first technique would certainly lower the number of parameters, but you'd have to memorize what `positionParameter1` and `positionParameter2` mean when `positionType` is `alongLine`, then what they mean when `positionType` is `inRadius`, then `inRect`, etc. And that's just one parameter with it's followers. Imagine every parameter that uses other parameters each having several `thisParameterA`'s and `thisParameterB`'s. Things could get very complicated, very fast. By using descriptive names, the parameter count goes up, but the usability also goes up - each parameter that uses other parameters has clear, concise names to make parameter settings easier.