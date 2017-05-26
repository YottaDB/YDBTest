testzgoto
	write "Start: in testzgoto main",!
	do tzg1
	write "Returned to testzgoto main with $zlevel=",$zlevel,!,!
	do tzg2
	write "Returned to testzgoto main with $zlevel=",$zlevel,!,!
	do tzg3
	write "Completed: in testzgoto main with $zlevel=",$zlevel,!
	quit

tzg1	write "In tzg1 - calling zgoto indirection test tzgindir1 - $zlevel=",$zlevel,!
	do tzgindir1
	write "we shouldn't still be in tzg1 subrtn",!
	quit

tzg2	write "In tzg2 - calling zgoto indirection test tzgindir2 - $zlevel=",$zlevel,!
	do tzgindir2
	write "we shouldn't still be in tzg2 subrtn",!
	quit

tzg3	write "In tzg3 - calling zgoto w/o indirection tzgdir3 - $zlevel=",$zlevel,!
	do tzgdir3
	write "we shouldn't still be in tzg3 subrtn",!
	quit

tzgindir1
	write "In tzgindir1 subrtn with $zlevel=",$zlevel,!
	write "Testing zgoto $zlevel-1:@x^@y",!
	set x="dummy"
	set y="testzgoto"
	zgoto $zlevel-1:@x^@y
	write "shouldn't still be in tzgindir1 subrtn",!
	quit

tzgindir2
	write "In tzgindir2 subrtn with $zlevel=",$zlevel,!
	write "Testing zgoto $zlevel-1:@x",!
	set x="dummy"
	zgoto $zlevel-1:@x
	write "shouldn't still be in tzgindir2 subrtn",!
	quit

tzgdir3
	write "In tzgdir3 subrtn with $zlevel=",$zlevel,!
	write "Testing zgoto $zlevel-1:dummy",!
	zgoto $zlevel-1:dummy
	write "shouldn't still be in tzgdir3 subrtn",!
	quit

dummy
	write "In dummy subrtn with $zlevel=",$zlevel,!
	quit
