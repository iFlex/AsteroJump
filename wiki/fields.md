# Fields #

Sure, Vents are one of the best things since `display.newImage()`, but to make your effects customizable from the beginning to the end (and any other stage there might be), CBEffects also provides an object called a CBField (yep, you guessed it - Field for short). Fields are highly customizable collision sensors that register collisions with particles and can modify them in any way possible - simply define a collision function and CBEffects passes the colliding particle and the associated field to it for each frame the particle is colliding with the field.
CBEffects was made to be easy and straightforward, so working with Fields (and FieldGroups, as you'll see in the next section) is almost identical to working with Vents and VentGroups. You create a single Field with the `NewField` function call, shown below.
```Lua
local field = CBE.NewField{
	[...]
}
```
The data table works the same as a data table for the `NewVent` method, except Fields utilize different parameters.
There is one parameter that **must** be given, unless errors are your thing. That parameter is the `targetVent` parameter. It specifies what Vent to modify particles from. It accepts a Vent as the value. You can either specify a single Vent or one that's been `:get()`-ed from a VentGroup.
```Lua
local field = CBE.NewField{
	targetVent = myVent -- This Vent was created earlier through NewVent
}
```
```Lua
local field = CBE.NewField{
	targetVent = myVentGroup:get("myVent") -- This Vent was collected throught the get() function, as you can see
}
```


# FieldGroups #

Just like VentGroups with Vents, CBEffects provides a special object to manage fields - CBFieldGroups (I'm not even going to say what it's shortened as). FieldGroups are built identically to VentGroups, and much of the methods are the same. The only difference in the creation technique is the name.

```Lua
local myFieldGroup = CBE.FieldGroup{
	{title = "field1"},
	{title = "field2"},
	{title = "field3"}
}
```