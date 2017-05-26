zjustify ;
		; Identify the $ZCHSET value and set corresponding local vars to proceed appropriately
		; since the steps and the M-arrays used from unicodesampledata.m will vary based on that
		set maxstrchar=^maxucplen
		set maxstrbyte=^maxutf8len
		if ("UTF-8"=$ZCHSET) do
		. write !,"******* Testing JUSTIFY for the entire unicode sample data range *******",!
		. write "All the unicode strings below will be right justified in the box",!
		. ; will write a nice box of characters, with the str() array written inside right justified.
		. ; because of combining characters few strings might appear to have side stepped a bit
		. ; but that is just the way it apperas, check for cursor position to be 62 in that case
		. ; to confirm it falls within the box.62 is derived as 59(maxucplen)+2("|")+1 at the end
		. for x=1:1:(maxstrchar+2) write "_"
		. write !
		. for i=1:1:^cntstr do
		. . if (-1'=^width(i)) write "|",$JUSTIFY(^str(i),maxstrchar-(^width(i)-^ucplen(i))),"|",!
		. for x=1:1:maxstrchar+2 write "_"
		. write !
		. for i=1:1:^cntstr do
		. . if (-1'=^width(i)) do ^examine($ZWIDTH($JUSTIFY(^str(i),maxstrchar)),maxstrchar+(^width(i)-^ucplen(i)),^str(i)_" "_^comments(i)_" not Justified properly ")
		. ; repeat the same box technique for $ZJUSTIFY
		. ; however this will not write a box as ZJUSTIFY operates on bytes counts
		. ; so to ensure correct results compare it with a text file stored in the system
		. do boxcompare("zjustify")
		. ;
		. ;
		. ; the calculation maxstrbyte-(utf8len(i)-width(i)) below is derived as follows.
		. ; For eg. let's take str="āăą" - a three character string where each character consists of two bytes and maxstrbyte=10
		. ; then $ZJUSTIFY(^str(i),maxstrbyte) will give 4+3=7 chars ==> 4 because when you
		. ; zjustify (3*2,10) only 4 is left to be filled. Now zwidth will also give 7
		. ; as the number of columns required to show 4 spaces followed by "āăą" unicode strings.
		. ; Looking at the right side ofthe expression we have maxstrbyte-(utf8len(i)-width(i)) i.e. 10-(6-3) = 7
		. ; so this expression will hold good for all unicode strings
		. for i=1:1:^cntstr if (-1'=^width(i)) do ^examine($ZWIDTH($ZJUSTIFY(^str(i),maxstrbyte)),maxstrbyte-(^utf8len(i)-^width(i)),^str(i)_" "_^comments(i)_" not Zjustified to "_maxstrbyte_" length")
		;
		;
		if ("M"=$ZCHSET) do
		. ; examine  cheks cannot be done due to ZWIDTH on M mode will return -1 for unprintable chars
		. write !,"******* Testing ZJUSTIFY for the entire unicode sample data range *******",!
		. ; box technique here as well for both JUSTIFY and ZJUSTIFY. But since everyone operates on byte counts
		. ; we will have NO box produced.
		. do boxcompare("zjustify")
		. write !,"******* Testing JUSTIFY for the entire unicode sample data range *******",!
		. do boxcompare("justify")
basic;
		write !,"******* Testing ZJUSTIFY,JUSTIFY for a sample unicode literal ä *******",!
		set c1="   Aä"
		set c2="  Aä"
		set s="Aä"
		set j1=$JUSTIFY(s,5)
		set j2=$ZJUSTIFY(s,5)
		if ("UTF-8"=$ZCHSET) do
		. do ^examine(j1,c1,"ERROR 1 from basic")
		. do ^examine(j2,c2,"ERROR 2 from basic")
		else  do multiequal^examine(j1,j2,c2,"ERROR 3 from basic")
indirection ;
		write !,"******* Testing ZJUSTIFY,JUSTIFY for indirection *******",!
		set instr="^str"
		if ("UTF-8"=$ZCHSET) do
		. for i=1:1:^cntstr if (-1'=^width(i)) do ^examine($ZWIDTH($ZJUSTIFY(@instr@(i),maxstrbyte)),maxstrbyte-(^utf8len(i)-^width(i)),^str(i)_" "_^comments(i)_" not Zjustified to "_maxstrbyte_" length")
		. for i=1:1:^cntstr if (-1'=^width(i)) do ^examine($ZWIDTH($JUSTIFY(@instr@(i),maxstrchar)),maxstrchar+(^width(i)-^ucplen(i)),^str(i)_" "_^comments(i)_" not Justified properly ")
rounding ;
		write !,"******* Testing ZJUSTIFY,JUSTIFY for rounding off third argument *******",!
		set file="rounding"_$ZCHSET_".out"
		open file:(newversion)
		use file
		for func="$JUSTIFY","$ZJUSTIFY" do
		. for i=-1000,-10,-2,-1,0,1,10,100,1E6 for j=-.05,-.043,0,.003,.55 s ij=i+j w @func@(ij,15,3),!
		. for i=-1000,-10,-2,-1,0,1,10,100,1E6 for j=-.05,-.043,0,.003,.55 s ij=i+j w @func@(ij,15),!
		. for i=-1000,-10,-2,-1,0,1,10,100,1E6 for j=-.05,-.043,0,.003,.55 s ij=i+j w @func@(ij,15,10),!
		. for i=-1000,-10,-2,-1,0,1,10,100,1E6 for j=-.05,-.043,0,.003,.55 s ij=i+j w @func@(ij,15,0),!
		. for i=-1000,-10,-2,-1,0,1,10,100,1E6 for j=-.05,-.043,0,.003,.55 s ij=i+j w @func@(ij,15,1),!
		. for i=-1000,-10,-2,-1,0,1,10,100,1E6 for j=-.05,-.043,0,.003,.55 s ij=i+j w @func@(ij,15,2),!
		; check some invalid cases as well and confirm nothing funny happens
		write $ZJUSTIFY($CHAR(50)_.9999,10,2),! ; should give a result 3 properly right justified
		write $ZJUSTIFY($CHAR(100)_.999,10,4),! ; should give a result 0.0000 properly right justified
		; some unicode string like a full width "A" char
		write $ZJUSTIFY($CHAR(239,188,161)_.5555,5,1),! ; should give a result 0.0 properly right justified
		close file
		set diffarg="diff rounding"_$ZCHSET_".out $gtm_tst/$tst/outref/rounding"_$ZCHSET_".out"
		ZSYSTEM diffarg
		quit
boxcompare(tmparg) ;
		set arg="$"_tmparg
		set file=tmparg_$ZCHSET_".out"
		open file:(newversion)
		use file
		for x=1:1:(maxstrbyte+2) write "_"
		write !
		for i=1:1:^cntstr if (0<$GET(^width(i))) write "|",@arg@(^str(i),maxstrbyte),"|",!
		for x=1:1:maxstrbyte+2 write "_"
		write !
		close file
		;
		set diffarg="diff "_tmparg_$ZCHSET_".out $gtm_tst/$tst/outref/"_tmparg_$ZCHSET_".out"
		ZSYSTEM diffarg
		quit
