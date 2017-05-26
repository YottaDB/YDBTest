fiforead
	set ftest="mytest.fifo"
	if $zversion["OS390" do
	. for i=1:1:240 quit:^writezready  hang 1
	open ftest:(fifo:readonly)
	use ftest
	set ^readzready=1
	for  read x quit:$zeof  use $p write x,! use ftest
	set za=$za
	set zeof=$zeof
	set d=$device
	use $p
	write "$za = ",za," $zeof = ",zeof," $device = ",d,!
	quit
