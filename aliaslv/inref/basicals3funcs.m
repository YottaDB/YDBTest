; External functions used by basicals3 test

funcals(newall)
	If 'newall New y Write "(New only working vars)",!
	If newall New  Write "(New all vars)",!
	Set y(1)=1_"ext"
	Set y(2)=2_"ext"
	Quit *y

funcalsct(newall)
	If 'newall New y,z Write "(New only working vars)",!
	If newall New  Write "(New all vars)",!
	Set y(1)=11_"ext"
	Set y(2)=22_"ext"
	Set *z(1)=y
	Quit *z(1)
