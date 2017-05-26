;search for a partucular line in dse dump
searchdump(particular)
	do dump^%DSEWRAP("DEFAULT",.s,"","all")
	set sfile="savedsewrap.out"
	open sfile:append
	use sfile
	zwrite s
	close sfile
	set y="s"
	for  set y=$query(@y) quit:(y="")!($order(@y)=particular)
	write @($query(@y))
	quit
