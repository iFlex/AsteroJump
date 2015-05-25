# Vents #
At the heart of the CBEffects engine is an object called a CBVent (generally shortened to Vent; named thus because of such lack of originality with "emitter"). Vents create and move particles according to settings that you define. Vents are created with the `NewVent` method.
```Lua
local vent = CBE.NewVent{
	[...]
}
```
Inside of the NewVent function call's **data table** are your parameters. These parameters define how particles move, how they are colored, what they look like, and such. The best way to learn what parameters are is to check out a few samples. There is also a list of parameters in each CBEffects package (find it in the file "CBReference.txt").

# VentGroups #
To make life easier, CBEffects also has a type of object called a CBVentGroup (VentGroup for short). These can be looked at as "Vent managers"; they make manipulating and using multiple vents much easier. Note that this also means you should use the `NewVent` method for single vents. The `VentGroup` method should be used for more than one vent - otherwise, you're just using unneeded extra memory. Each vent is stored inside of the VentGroup, so you don't have to keep track of five or six different Vents - just one VentGroup. The VentGroup also gives simplified methods for starting Vents, editing them, and other helpful functions. VentGroups are created with the `VentGroup` method.
```Lua
local VentGroup = CBE.VentGroup{
	[...]
}
```
The function call is essentially the same, only for VentGroups, the data table has multiple Vent data tables instead of parameters. Each separate table denotes another Vent to be created inside of the VentGroup.
```Lua
local VentGroup = CBE.VentGroup{
	{title = "vent1"},
	{title = "vent2"},
	{title = "vent3"}
}
```
The internal tables are identical in every way to the table that goes inside of the `NewVent` function call.