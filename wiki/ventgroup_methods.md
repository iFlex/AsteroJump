# VentGroup Methods #

A VentGroup is a convenient "manager" for Vents. Each VentGroup gives easy-access functions to manipulate internal Vents.

**These are not *Vent* methods - for Vent methods, see [Vent Methods](http://www.github.com/GymbylCoding/CBEffects/wiki/Vent-Methods)**

**Most VentGroup functions use a list of Vent titles as arguments; when creating a VentGroup, each vent should be given a title. The Vent title arguments point to the vents associated to the titles. Each method, unless otherwise mentioned, also has another form, in which the word "master" is inserted at the end. When this function is called, the original function is executed for each Vent inside of the VentGroup.**

##### `VentGroup:emit( [titles] )` #####

This function creates one "round" of particles from each vent specified.

```Lua
VentGroup:emit("vent1", "vent2", "vent3")

-- OR --

VentGroup:emitMaster()
```

##### `VentGroup:start( [titles] )` #####

Begins each specified Vent's particle timer, calling `emit()` in intervals of their `emissionSpeed`.

```Lua
VentGroup:start("vent1", "vent2", "vent3")

-- OR --

VentGroup:startMaster()
```

##### `VentGroup:stop( [titles] )` #####

"Turns off" each specified Vent and cancels their particle timer.

```Lua
VentGroup:stop("vent1", "vent2", "vent3")

-- OR --

VentGroup:stopMaster()
```

##### `VentGroup:clean( [titles] )` #####
  
**No `cleanMaster()` method for VentGroups.**

This method removes all particles from each specified Vent instantly. Note, though, that this does not stop the Vent if the Vent is started. For an abrupt stop of a Vent (ending the particle timer and destroying all particles), you would call both `stop()` for a Vent *and* `clean()`.

```Lua
VentGroup:clean("vent1", "vent2", "vent3")
```

##### `VentGroup:destroy( [titles] )` #####

This function completely obliterates each specified Vent. It can be used to destroy a single unneeded Vent and free up memory. To destroy the entire VentGroup, use `destroyMaster()`. The handle should be set to `nil` after **only** `destroyMaster()`, not `destroy()`, otherwise you may introduce a memory leak.

```Lua
VentGroup:destroy("vent1", "vent2", "vent3") -- This destroys a single vent, not the entire VentGroup

-- OR --
VentGroup:destroyMaster() -- This completely destroys the entire VentGroup
VentGroup = nil
```

##### `VentGroup:move(title, x, y)` #####
  
**No `moveMaster()` method for VentGroups.**

This function positions a **single** Vent in a single line. It's really just a convenience function to save time. Unlike the other methods, it can only apply to one Vent at a time.

```Lua
VentGroup:move("vent1", 512, 384)
````

##### `VentGroup:get( [titles] )` #####

**No `getMaster()` method for VentGroups.**

This function returns the actual Vent object for each title.

```Lua
local vent1, vent2, vent3 = VentGroup:get("vent1", "vent2", "vent3")
````

See [Methods for Vents](http://www.github.com/GymbylCoding/CBEffects/wiki/Vent-Methods) to see the capabilities of individual Vents.

