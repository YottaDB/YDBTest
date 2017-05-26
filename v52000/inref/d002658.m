d002658	;
	; D9H05-002658 [Narayanan] SIG-11 in jnl_write at KTB (due to gvcst_zprevious memory corruption)
	;
	; The test case consists of two steps
	; a) Open the region whose max_key_size is the smallest and do ZPREVIOUS (or $ORDER(...,-1)) on global in this region first.
	; b) Later open other regions with higher max_key_size and do $ZPREVIOUS/$ORDER(,-1) on globals in those regions.
	; Test with concurrent processes that dry clean the cache to make sure we still do not overwrite memory not allocated to us.
	;
	set jmaxwait=0
	set ^stop=0
	do ^job("thread^d002658",5,"""""")
	hang 5
	set ^stop=1
	do wait^job
	quit
	
thread	;
	;
	new subs,i,direction
	set direction=(2*$r(2))-1
	for  quit:^stop=1  do
	.	kill ^xxxx($j)
	.	for i=1:1:1000 s ^xxxx($j,i)=$j(i,10)
	.	set subs="" for  set subs=$order(^xxxx($j,subs),direction) quit:subs=""
	.	kill ^a($j)
	.	for i=1:1:1000 s ^a($j,$j(i,$r(50)))=$j(i,10)
	.	set subs="" for  set subs=$order(^a($j,subs),direction) quit:subs=""
	.	kill ^b($j)
	.	for i=1:1:1000 s ^b($j,$j(i,$r(150)))=$j(i,20)
	.	set subs="" for  set subs=$order(^b($j,subs),direction) q:subs=""
	.	for x="a","b","xxxx" do queryloop(x)
	quit

queryloop(gbl);
	new sub
	set sub="^"_gbl_"("""")"
	for  set sub=$query(@sub) quit:sub=""
	quit
