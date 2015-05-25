# Vent Methods #

Each Vent has a number of methods to start it, stop it, edit it, and anything else. Here's a reference of each one.

**Note that these are *Vent* methods, not VentGroup methods.**

##### `vent:emit()` #####

This command creates one "round" of particles from the vent.

```Lua
vent:emit()
```

##### `vent:start()` #####

Begins the Vent's particle timer, calling `emit()` in intervals of the Vent's `emissionSpeed`.

```Lua
vent:start()
```

##### `vent:stop()` #####

If the Vent is started (`vent:start()` was called earlier), this "turns off" the Vent and cancels the particle timer.

```Lua
vent:stop()
```

##### `vent:clean()` #####

This method removes all particles from the Vent instantly. Note, though, that this does not stop the Vent if the Vent is started. For an abrupt stop of a Vent (ending the particle timer and destroying all particles), you would call both `stop()` and `clean()`.

```Lua
vent:clean()
```

##### `vent:resetPoints()` #####

If you set `point1` and `point2` on a Vent, you can call this and the points along the line for the `alongLine` option of `positionType` will be recalculated. This is a rather intensive operation, so try to avoid calling it repeatedly.

```Lua
vent.point1 = {0, 0}
vent.point2 = {1024, 768}

vent:resetPoints()
```

##### `vent:resetAngles()` #####

This is used as a method to recalculate emission angles for a Vent. You can calculate the angles each time a particle is emitted by using `preCalculate = false`, but that can be memory-intensive. To use this method, set the Vent's `angles` table (and the `autoAngle`, if needed) and call this function. The velocity angles are reset to the new set of angles.

```Lua
vent.angles = {{0, 360}}
vent.autoAngle = true

vent:resetAngles()
```

##### `vent.set(params)` #####

**Notice that this function uses a dot, not a colon!**
This is a quick way to set a Vent's values. A table is received as the only argument, and values from the table are set as the Vent's values, instead of having to use `vent.this = that; vent.anotherThing = yetSomethingElse; vent.whatever = "L"`.

```Lua
vent.set{
	positionType = "inRadius",
	posRadius = 100,
	x = display.contentCenterX,
	y = display.contentHeight
}
```

##### `vent:destroy()` #####

This function completely obliterates a Vent. It can be used to clear the Vent when changing scenes. The handle should be set to `nil` afterwards.

```Lua
vent:destroy()
vent = nil
```