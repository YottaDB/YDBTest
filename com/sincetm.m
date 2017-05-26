sincetm(outfname);
	OPEN outfname:newversion 
	USE outfname
	WRITE $ZD($H,"DD-MON-YEAR 24:60:SS")
	CLOSE outfname
	q
