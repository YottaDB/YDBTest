	;;; freeze.m
	new prevdev
	s prevdev=$IO
	u $p
	;h 3 ; to make sure that database is freezed
	zsystem "$gtm_tst/com/wait_for_log.csh -log frozen.txt -waitcreation -duration 180 -vrb" ; to make sure that database is frozen
	s ^a="new",^b="new"
	zsystem "touch done_freeze.txt; echo ""--"";ls -l; date"
	u prevdev
	q
