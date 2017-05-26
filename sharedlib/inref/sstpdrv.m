sstpdrv	;
creafn;
	write "In creafn",!
	set maxline=10000
	set zsfn="zsteps.csh"
	open zsfn:newversion
	use zsfn
	write "#!/usr/local/bin/tcsh -f",!
	write "$gtm_exe/mumps -dir << \aaa",!
	set zrostr="set $zro=""./sh_zsteps"_$ztrnlnm("gt_ld_shl_suffix")_""""
	write zrostr,!
	write "do drive^sstpdrv",!
	for i=1:1:maxline write "zstep",!
	write "do verify^sstpdrv",!
	write "\aaa",!
	close zsfn
	quit
drive;
	set $ZT="set $ZT="""" g ERROR^sstpdrv"
	set maxline=10000
	;set $zstep="set myvar(longname90123456789012345678901)=""A""  set %zsaveio=$io use $p w:$x ! w $zpos,?20,"":"" zp @$zpos  use %zsaveio zbreak @$zpos"
	set $zstep="set myvar(longname90123456789012345678901)=""A""  zbreak @$zpos"
	zbreak zstpmain+3^zstpmain:"set myvar(longname90123456789012345678901)=""A"" zstep"
	zshow "SB"
	d ^zstpmain
	q
verify;
	write "In verify",!
	set %errno=0
	set maxline=10000
	f i=1:1:maxline do
	. if $get(myvar(i))'="A" write "Verify Fail for index ",i," Expected A"," Found ",$get(myvar(i)),! set %errno=%errno+1
	if %errno=0  write "Verify Passed",!
	q
ERROR	ZSHOW "*"
	q
