per0348	;per0348 - u "" intermittantly gives a device not open error
	;
	o "_test.dat"
	u "_test.dat" 
	u "" 
	c "_test.dat":delete
	w !,"OK from test of file name beginning with _"
