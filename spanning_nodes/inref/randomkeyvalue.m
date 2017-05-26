; Generates two files such that a key on line x in justkeys.txt corresponds to the value on line x in justvalues.txt.
; This script is called from basic.csh. Assumes block size is 1024.
randomkeyvalue
	set ^numpair=1000
	set ^keylen=200
	set ^keyfile="justkeys.txt"
	set ^valuefile="justvalues.txt"
	open ^keyfile:newversion
	open ^valuefile:newversion
	; Following loop creates mixture of spanning and non-spanning blocks
	for i=1:1:^numpair use ^keyfile write $$%RANDSTR^%RANDSTR(^keylen),! use ^valuefile write $$%RANDSTR^%RANDSTR(i+$random(1024)),!
	close ^keyfile
	close ^valuefile
	quit
