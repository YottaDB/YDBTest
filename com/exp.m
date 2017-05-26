exp	Set unix=$ZVersion'["VMS"
	set exp=2**$ZCMDLINE
	if unix w exp,! q
	s fn="exp_tmp.com"
	o fn c fn:delete o fn u fn
	w "$ exp == ",exp,!
	c fn
	q
