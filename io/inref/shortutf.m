shortutf
	; Test short utf-8 inputs both with and without bom for disk, fifo, and pipe reads
	; disk tests
	; streaming mode
	w !,"DISK TESTS",!
	set fin="uout_with_bom"
	open fin
	use fin
	read x
	use $P
	write "-",x,"-",!
	close fin
	set fin="uout_without_bom"
	open fin
	use fin
	read x
	use $P
	write "-",x,"-",!
	close fin

	; fixed mode
	set fin="uout_with_bom"
	open fin:(fixed:recordsize=1)
	use fin
	read x
	use $P
	write "-",x,"-",!
	close fin
	set fin="uout_without_bom"
	open fin:(fixed:recordsize=1)
	use fin
	read x
	use $P
	write "-",x,"-",!

	; pipe tests
	; streaming mode
	w !,"PIPE TESTS",!
	set p1="test1"
	open p1:(command="cat -u uout_with_bom")::"pipe"
	use p1
	read x
	use $P
	write "-",x,"-",!
	close p1
	open p1:(command="cat -u uout_without_bom")::"pipe"
	use p1
	read x
	use $P
	write "-",x,"-",!
	close p1

	; fixed mode
	set p1="test1"
	open p1:(command="cat -u uout_with_bom | strip_cr":fixed:recordsize=1)::"pipe"
	use p1
	read x
	use $P
	write "-",x,"-",!
	close p1
	open p1:(command="cat -u uout_without_bom | strip_cr":fixed:recordsize=1)::"pipe"
	use p1
	read x
	use $P
	write "-",x,"-",!
	close p1

	; fifo tests
	; streaming mode
	set p1="fifo.test"
	w !,"FIFO TESTS",!
	open p1:(fifo:newversion)
	use p1
	zsystem "cat -u uout_with_bom > fifo.test"
	read x
	use $P
	write "-",x,"-",!
	close p1
	set p1="fifo.test"
	open p1:(fifo:newversion)
	use p1
	zsystem "cat -u uout_without_bom > fifo.test"
	read x
	use $P
	write "-",x,"-",!
	close p1
	
	; fixed mode
	open p1:(fifo:newversion:fixed:recordsize=1)
	use p1
	zsystem "cat -u uout_with_bom | strip_cr > fifo.test"
	read x
	use $P
	write "-",x,"-",!
	close p1
	set p1="fifo.test"
	open p1:(fifo:newversion:fixed:recordsize=1)
	use p1
	zsystem "cat -u uout_without_bom | strip_cr > fifo.test"
	read x
	use $P
	write "-",x,"-",!
	close p1

	quit
