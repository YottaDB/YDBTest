zlfix	; Test re-call of code that gets re-zlinked
	Zsystem "\cp $gtm_tst/$tst/inref/zlfix1a.m zlfix1.m"
	zlink "zlfix1.m"

	d ^zlfix1

	Zsystem "\cp $gtm_tst/$tst/inref/zlfix1b.m zlfix1.m"
	zlink "zlfix1.m"

	d ^zlfix1
	Quit
