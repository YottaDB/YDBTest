fgdbfill;
	; For now following routines are called. 
	; All of these run in foreground.
	; Note v4rinttp is multi-process and does not use job.m (see v4rinttp.m for why)
	; Others are single process
	do ^v4rinttp(1)
	do ^v4rinttp(2)
	do ^v4rinttp(3)
	d ^replrec
	d in1^dbfill("set")
	d in1^dbfill("ver")
	q
