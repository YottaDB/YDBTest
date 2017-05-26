fifowrite
	set ftest="mytest.fifo"
	open ftest:(fifo:writeonly:newversion)
	use ftest
	set ^writezready=1
	for i=1:1:240 quit:^readzready  hang 1
  	for i=1:1:10 do
 	. w i,":abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz",!
	quit
