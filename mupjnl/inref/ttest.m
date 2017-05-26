ttest	;
	set unix=$zv'["VMS"
	if unix s com="$gtm_tst/com/jnl_on.csh"
	e  s com="@gtm$test_common:set_jnl.com"
	h 2
	d ttest1^ttest
	view "JNLFLUSH"
	h 2
	zsystem com
	d ttest2^ttest
	view "JNLFLUSH"
	h 2
	zsystem com
	d ttest3^ttest
	view "JNLFLUSH"
	h 2
	zsystem com
	view "JNLFLUSH"
	h 4	; this is for the work-around for C9D11-002459, please remove once it is fixed.
	q
ttest1	;
	set unix=$zv'["VMS"
	if unix zsy "$gtm_tst/com/abs_time.csh time0"
	else  zsy "pipe write sys$output f$time() > time0.txt"
	h 2
	F i=1:1:10 S ^A(i)="A"_i
	F i=1:1:10 S ^B(i)="B"_i
	h 2
	q
ttest2	;
	set unix=$zv'["VMS"
	if unix zsy "$gtm_tst/com/abs_time.csh time1"
	else  zsy "pipe write sys$output f$time() > time1.txt"
	h 2
	ZTS
	F i=1:1:10 S ^C(i)="C"_i
	F i=1:1:10 S ^CC(i)="C2"_i
	ZTC
	h 2
	q

ttest3	;
	set unix=$zv'["VMS"
	if unix zsy "$gtm_tst/com/abs_time.csh time2"
	else  zsy "pipe write sys$output f$time() > time2.txt"
	h 2
	TS
	F i=1:1:10 S ^BB(i)="B2"_i
	F i=1:1:10 S ^AA(i)="A2"_i
	TC
	h 2
	q
