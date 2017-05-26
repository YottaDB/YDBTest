; Verify merge works fine with spanning nodes.
; Called from basic.csh

merge
	kill ^aa,^bb
	set ^aa="begin1"_$justify(" ",3000)_"end1"
	set ^aa(1)="begin2"_$justify(" ",3000)_"end2"
	merge ^bb=^aa
	kill ^aa(1)
	merge ^bb=^aa
	if 0=$data(^bb(1)) write "ERROR! ^bb is not merged properly",!
	quit
