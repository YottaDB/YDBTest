c003042	;
	; Test repositioning logic happens only ONCE in gds_tp_hist_moved (see TR folder for details)
	; This requires a si->first_tp_hist array expansion to happen while in a gvcst_root_search.
	; Therefore we need to do lots of new global references. Hence create at least 16 globals and use all inside TP.
	;
	set ^max=16+$r(128)	; have at least 16 globals to populate the directory tree
	set ^maxsubs=1+$r(16)
	; Initialize ^max globals a1, a2, ... each with ^maxsubs subscripts ^a1(1)..^a1(^maxsubs), ^a2(1)..^a2(^maxsubs) etc.
	set max=^max
	set maxsubs=^maxsubs
	for i=1:1:max for k=1:1:maxsubs  set xstr="set ^a"_i_"("_k_")=$j("_k_",200)"  xecute xstr
	for i=1:1:20  do ^job("child^c003042",1,"""""")
	quit
child	;
	set max=^max
	set maxsubs=^maxsubs
	for i=1:1:max  do
	.	tstart ():serial
	.	for j=1:1:i  do
	.	.	set gbl="^a"_j
	.	.	set max(i,j)=$r(maxsubs)
	.	.	for l=1:1:max(i,j)  set x=$get(@gbl@(l))
	.	tcommit
	quit
