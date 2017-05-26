; routine that will either wait until a specific number of the given gvstat is reached or for a specified amount of time
; It is not an error if timeout is reached
; This lets test scripts to wait for a more deterministic period instead of sleeping for an aribitary value.

waitforgvstats
	set gvstat=$piece($zcmdline," ",1)
	set statcount=$piece($zcmdline," ",2)
	set waittime=+$piece($zcmdline," ",3)
	set:waittime=0 waittime=300 ; default is 5 minutes
	do FUNC^waitforgvstats(gvstat,statcount,waittime)
	quit

FUNC(gvstat,statcount,waittime)
	set startcount=0
	set increment=$translate(statcount,"+","")
	set gvstat=gvstat_":"
	set file="waitforgvstats.out"
	open file:append use file
	if ("+"=$extract(statcount,1)) do
	.	set reg="" for  set reg=$view("GVNEXT",reg)  quit:reg=""  set startcount=startcount+$piece($piece($view("GVSTATS",reg),gvstat,2),",",1)
	set curcount=startcount
	set endcount=startcount+increment
	set starttime=$horolog,sec=0
	write "Start time : ",$zdate(starttime,"DD-MON-YEAR 24:60:SS"),!
	write "Starting global set count : ",startcount,!
	for  quit:(curcount>endcount)!(sec>waittime)  do
	.	set cnt=0,reg="" for  set reg=$view("GVNEXT",reg)  quit:reg=""  set cnt=cnt+$piece($piece($view("GVSTATS",reg),gvstat,2),",",1)
	.	set curcount=cnt
	.	hang 1
	.	set sec=$$^difftime($horolog,starttime)
	write "End time : ",$zdate($horolog,"DD-MON-YEAR 24:60:SS"),!
	write "After ",sec," seconds, the current ",gvstat," value is ",curcount,!
	close file
	quit
