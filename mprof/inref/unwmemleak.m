; a helper script for memleak subtest; it makes a number of
; simple label calls within this routine to go through
; unw_prof_frame repeatedly
unwmemleak
	d verylonglabelname0
	d verylonglabelname5
	q

verylonglabelname0
	s x=1
	s x=2
	s x=3
	s x=4
	s x=5
	s x=6
	s x=7
	s x=8
	s x=9
	d verylonglabelname1
	q

verylonglabelname1
	s x=1
	s x=2
	s x=3
	s x=4
	s x=5
	s x=6
	s x=7
	s x=8
	s x=9
	d verylonglabelname2
	q

verylonglabelname2
	s x=1
	s x=2
	s x=3
	s x=4
	s x=5
	s x=6
	s x=7
	s x=8
	s x=9
	d verylonglabelname3
	q

verylonglabelname3
	s x=1
	s x=2
	s x=3
	s x=4
	s x=5
	s x=6
	s x=7
	s x=8
	s x=9
	d verylonglabelname4
	q

verylonglabelname4
	s x=1
	s x=2
	s x=3
	s x=4
	s x=5
	s x=6
	s x=7
	s x=8
	s x=9
	q

verylonglabelname5
	s x=1
	s x=2
	s x=3
	s x=4
	s x=5
	s x=6
	s x=7
	s x=8
	s x=9
	d verylonglabelname6
	q

verylonglabelname6
	s x=1
	s x=2
	s x=3
	s x=4
	s x=5
	s x=6
	s x=7
	s x=8
	s x=9
	d verylonglabelname7
	q

verylonglabelname7
	s x=1
	s x=2
	s x=3
	s x=4
	s x=5
	s x=6
	s x=7
	s x=8
	s x=9
	d verylonglabelname8
	q

verylonglabelname8
	s x=1
	s x=2
	s x=3
	s x=4
	s x=5
	s x=6
	s x=7
	s x=8
	s x=9
	d verylonglabelname9
	q

verylonglabelname9
	s x=1
	s x=2
	s x=3
	s x=4
	s x=5
	s x=6
	s x=7
	s x=8
	s x=9
	q
