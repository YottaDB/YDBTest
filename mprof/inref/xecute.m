xecute	; Test of eXecute command
;	File modified by Hallgarth on 15-APR-1986 13:30:44.33
	s x="write ""help"",!"
	s y="w x,!!"
	x x
	x y
	s tt=13
	x x:tt>12,y:tt>6
	s z="x"
	x @z:tt=13
	x:z="x" @z:tt>1
	s xx="write x"
	s zz=",!"
	x xx_zz
	x "write z,!"
