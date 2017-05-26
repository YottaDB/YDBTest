;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm6901	;
altreg	;
	set $zgbldir="alt.gld"
	write "# Using ",$zgbldir," ^x goes to : ",$view("REGION","^x"),!
	write $ztrigger("item","+^x -commands=S -xecute=""do alttrig^gtm6901"" -name=xyz"),!
	set $zgbldir="mumps.gld"
	write "# Using ",$zgbldir," ^x goes to : ",$view("REGION","^x"),!
	write "Adding a non-matching trigger with the same name as a visible trigger (in mumps.gld) should error out",!
	write $ztrigger("item","+^x -commands=S -xecute=""do mumpstrig^gtm6901"" -name=xyz"),!
	write "Adding a matching trigger with the same name as a visible trigger (in mumps.gld) should NOT error out",!
	write $ztrigger("item","+^x -commands=S -xecute=""do alttrig^gtm6901"" -name=xyz"),!
	write "# if trigger spec matches but name does not, it should not be deleted and a helpful error message should be printed",!
	write $ztrigger("item","-^x -commands=S -xecute=""do alttrig^gtm6901"" -name=xyz2"),!
	write $ztrigger("select","*"),!
	;
	; If two gbldirs have same triggers, check if the right trigger is invoked depending on the current gbldir
	set $zgbldir="alt.gld"
	write "# Using ",$zgbldir," ^a goes to : ",$view("REGION","^a"),!
	write $ztrigger("item","+^a(sub=:) -commands=S,K -xecute=""do alttrig^gtm6901"" -name=atrig"),!
	set $zgbldir="mumps.gld"
	write "# Using ",$zgbldir," ^a goes to : ",$view("REGION","^a"),!
	write $ztrigger("item","+^a(sub=:) -commands=S,K -xecute=""do mumpstrig^gtm6901"" -name=atrig"),!
	set $zgbldir="alt.gld"
	write "# Using ",$zgbldir," ^a goes to : ",$view("REGION","^a"),!
	write "# DEFAULT too has a ^a trigger that was set by mumps.gld",!
	write $ztrigger("select","*"),!
	set $zgbldir="alt.gld"   write "# Using "_$zgbldir_" set ^a - check the fired trigger",!  set ^a(0)=$zgbldir
	set $zgbldir="mumps.gld" write "# Using "_$zgbldir_" set ^a - check the fired trigger",!  set ^a(0)=$zgbldir

	set $zgbldir="alt.gld"
	write $ztrigger("item","-atrig"),!
	quit

alttrig	;
	write "# In trigger code  : alttrig^gtm6901   ; Level : ",$ztlevel,!
	if (0=sub) do
	. write "# Set ^a(1) without changing $zgbldir",! set ^a(1)=$zgbldir_" 1"
	if (1=sub) do
	. write "# Set ^a(2) after changing $zgbldir to mumps.gld",! set $zgbldir="mumps.gld" set ^a(2)=$zgbldir_" 2"
	if (3=sub) do
	. write "# Naked reference without changing $zgbldir : ",$zgbldir,!
	. s ^a(4)=$zgbldir_" 4"
	. s ^(5)=$zgbldir_" 5"
	if (4=sub) do
	. write "# set ^(5) here i.e naked reference",!
	. s ^(5)=$zgbldir_" 5"
	if (5=sub) do
	. write "# Should have been called by naked reference",!
	write "# End trigger code : alttrig^gtm6901   ; Level : ",$ztlevel,!
	quit

mumpstrig	;
	write "# In trigger code  : mumpstrig^gtm6901 ; Level : ",$ztlevel,!
	if (0=sub) do
	. set $zgbldir="alt.gld"
	. write "# Naked reference after changing $zgbldir to : ",$zgbldir,!
	. set ^a(4)=4
	. write "# kill ^(5) here i.e naked reference",!
	. kill ^(5)
	if (2=sub) do
	. write "# Extended reference of alt.gld ",! set ^|"alt.gld"|a(3)=3
	write "# End trigger code : mumpstrig^gtm6901 ; Level : ",$ztlevel,!
	quit
