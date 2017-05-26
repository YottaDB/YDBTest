REVZWR(name)
	New s 
	Set s="" 
	For  Set s=$Order(@name@(s),-1)  Quit:s=""  Do REVZWR($Name(@name@(s)))
	If $Data(@name)#2 Write name,"=""",@name,"""",!
	Quit 
