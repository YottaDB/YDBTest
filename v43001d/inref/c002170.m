c002170 ;
	; hold parent and nested lock and make a process wait for nested lock before releasing parent and nested lock 
	; the other process should get the nested lock as soon as we release it.
	;
	set ^lock=0
	set unix=$ZVersion'["VMS"
	if unix  job child^c002170:(output="child.mjo":error="child.mje")
	if 'unix job child^c002170:(nodetached:startup="startup.com":output="child.mjo":error="child.mje")
	;
	; ------------ grab locks ---------------------
	;
	write !,"Parent : Before acquiring Lock ^a(1) : $h = ",$h
	lock +^a(1)
	lock +^a
	set ^lock=1	; signal child to attempt acquiring ^a(1)
	;
	for  quit:^lock=2  h 1	; wait for child to attempt acquiring ^a(1)
	;
	; find out if child has started waiting for ^a(1)
	set unix=$ZVersion'["VMS"
	if unix  set lkzsystr="$gtm_dist/lke show -wait >& lkeshow.out; $convert_to_gtm_chset lkeshow.out"
	if 'unix set lkzsystr="lke show /wait /out=lkeshow.out"
	set found=0
	for  do  quit:found=1  hang 1
	.	zsystem lkzsystr
	.	set file="lkeshow.out"
	.	open file
	.	use file
	.	for  q:$zeof=1  do
	.	.	read line
	.	.	if $find(line,"Request")'=0 set found=1
	.	use $p
	;
	; ------------ release locks ---------------------
	;
	lock -^a
	lock -^a(1)
	write !,"Parent : After  releasing Lock ^a(1) : $h = ",$h
	;
	for  quit:^lock=3  hang 1	; wait for child to signal almost completion
	;
	; wait for child to halt out 
	;
	set unix=$ZVersion'["VMS"
	set dsefile="dsedump.out"
	if unix  set dszsystr="$gtm_dist/dse dump -file |& grep ""Reference count"" >& "_dsefile_"; $convert_to_gtm_chset "_dsefile
	if 'unix set dszsystr="@vinrefdir:dsedump.com"
	set refcnt=3
	for  do  quit:refcnt<3  hang 1
	.	zsystem dszsystr
	.	set file=dsefile
	.	open file
	.	use file
	.	read line
	.	use $p
	.	close file
        .       set count=0
        .       for i=1:1  quit:count=3  do
        .       .       set piece=$piece(line," ",i)
        .       .       if piece'="" set count=count+1
        .       set refcnt=piece
	write !
	quit
child	;
	for  quit:^lock=1  hang 1
	set ^lock=2	; signal c002170 to go ahead and release lock
	write !,"Child : Before acquiring Lock ^a(1) : $h = ",$h
	lock +^a(1)
	write !,"Child : After  acquiring Lock ^a(1) : $h = ",$h
	set ^lock=3
	quit
