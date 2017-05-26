zread
	set a="test"
	; if the location of mupip is the $PATH or it is aliased then the full path is not necessary
	open a:(comm="$gtm_exe/mupip integ mumps.dat")::"pipe"
	use a
	for  read x quit:$zeof  use $p write "line= ",x,! use a
	close a
	quit
