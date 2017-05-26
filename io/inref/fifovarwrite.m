fifovarwrite
	set ftest="mytest.fifo"
	set sync1="sync1.fifo"
	set sync2="sync2.fifo"
	open ftest:(fifo:writeonly:newversion)
	open sync1:(fifo:readonly)
	open sync2:(fifo:writeonly:newversion)
	if $zversion["OS390" do
	. for i=1:1:240 quit:^readready  hang 1
	use sync1
	read x
	use ftest
	write "abcdefghijklmnopqrstuvwxyz",!
	; tell reader that response was written to ftest
	use sync2
	write "send 1 done",!

	use sync1
	read x
	use ftest
	write "abcdefghijklmnopqrstuvwxyz",!
	; tell reader that response was written to ftest
	use sync2
	write "send 2 done",!

	use sync1
	read x
	use ftest
	write "abcdefghijklmnopqrstuvwxyz"
	; tell reader that response was written to ftest
	use sync2
	write "send 3 done",!

	use sync1
	read x
	use ftest
	write "abcdefghijklmnopqrstuvwxyz"
	; tell reader that response was written to ftest
	use sync2
	write "send 4 done",!

	use sync1
	read x
	use ftest
	write "abcdefghijklmnopqrstuvwxyz",!
	; tell reader that response was written to ftest
	use sync2
	write "send 5 done",!
	; wait until reader is done before quit
	use sync1
	read x
	quit
