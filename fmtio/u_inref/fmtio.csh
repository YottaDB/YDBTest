#
# Initialization. define environment variables.
#
# 'go' format is not supported in UTF-8 mode
# Since the subtest explicitly checks the go format (to load using %GI and mupip load), it is forced to run in M mode
$switch_chset M >&! switch_chset.out
echo ""
echo FORMAT IO
echo ""
#
$gtm_tst/com/dbcreate.csh fmtio 1 125 700 1536 1000 256
setenv gtmgbldir "./fmtio.gld"
#
# Step 1. Fill the database
#
$GTM << aaa
	do aaa^fmtio
aaa
if ("os390" == "$gtm_test_osname") then
	if (-f gtmcore) then
		mv gtmcore fmtiogtmcore1
	endif
else
	if (-f core) then
		mv core fmtiocore1
	endif
endif 
#
# Step 2. extract a1.zwr, b1.zwr and b1.glo
#
$MUPIP extract -format=zwr -select="^a" a1.zwr >&! temp1.tmp
if ( $status != 0 ) then
    echo ERROR1.
    exit 1
endif
$MUPIP extract -format=zwr -select="^b" b1.zwr >&! temp2.tmp
if ( $status != 0 ) then
    echo ERROR2.
    exit 1
endif
$MUPIP extract -format=go -select="^b" b1.glo >&! temp3.tmp
if ( $status != 0 ) then
    echo ERROR3.
    exit 1
endif
#
# Step 3. _GO.m a2.zwr, b2.zwr and b2.glo
#
$GTM << \bbb  >&! go.log
w "d ^%GO",!
d ^%GO
a

a2.zwr
zwr
a2.zwr
w "d ^%GO",!
d ^%GO
b

b2.zwr

b2.zwr
w "d ^%GO",!
d ^%GO
b

b2.glo
go
b2.glo
h
\bbb
if ("os390" == "$gtm_test_osname") then
	if (-f gtmcore) then
		mv gtmcore fmtiogtmcore2
	endif
else
	if (-f core) then
		mv core fmtiocore2
	endif
endif 
#
# Step 4. _GI.m all 6 files.
#
$GTM << \ccc >&! tempa.tmp
w "d ^fmtio(""set0"",""a"")",!   d ^fmtio("set0","a")
w "d ^%GI"                       d ^%GI
a1.zwr

w "d ^fmtio(""check"",""a"")",!  d ^fmtio("check","a")
w "d ^fmtio(""set0"",""a"")",!   d ^fmtio("set0","a")
w "d ^%GI",!                     d ^%GI
a2.zwr

w "d ^fmtio(""check"",""a"")",!  d ^fmtio("check","a")
w "d ^fmtio(""set0"",""b"")",!   d ^fmtio("set0","b")
w "d ^%GI",!                     d ^%GI
b1.zwr

w "d ^fmtio(""check"",""b"")",!  d ^fmtio("check","b")
w "d ^fmtio(""set0"",""b"")",!   d ^fmtio("set0","b")
w "d ^%GI",!                     d ^%GI
b1.glo

w "d ^fmtio(""check"",""b"")",!  d ^fmtio("check","b")
w "d ^fmtio(""set0"",""b"")",!   d ^fmtio("set0","b")
w "d ^%GI",!                     d ^%GI
b2.zwr

w "d ^fmtio(""check"",""b"")",!  d ^fmtio("check","b")
w "d ^fmtio(""set0"",""b"")",!   d ^fmtio("set0","b")
w "d ^%GI",!                     d ^%GI
b2.glo

w "d ^fmtio(""check"",""b"")",!  d ^fmtio("check","b")
h
\ccc
if ("os390" == "$gtm_test_osname") then
	if (-f gtmcore) then
		mv gtmcore fmtiogtmcore3
	endif
else
	if (-f core) then
		mv core fmtiocore3
	endif
endif 
#
# Step 5. mupip load all six.
#
if ($?gtm_chset) then
	if ($gtm_chset == "UTF-8") then
		# Make extract file compatible with UTF-8 load
		foreach file (a2.zwr b2.zwr b2.glo)
			mv $file ${file}1
			sed 's/'$file'/& UTF-8/g' ${file}1 > $file
		end
	endif
endif
$GTM << ddd
	do ddd^fmtio
ddd
if ("os390" == "$gtm_test_osname") then
	if (-f gtmcore) then
		mv gtmcore fmtiogtmcore4
	endif
else
	if (-f core) then
		mv core fmtiocore4
	endif
endif 
$MUPIP load a1.zwr  >&! temp4.tmp
if ( $status != 0 ) then
    echo ERROR4.
    exit 1
endif
$GTM << eee
	do eee^fmtio
eee
if ("os390" == "$gtm_test_osname") then
	if (-f gtmcore) then
		mv gtmcore fmtiogtmcore5
	endif
else
	if (-f core) then
		mv core fmtiocore5
	endif
endif 
$MUPIP load a2.zwr  >&! temp5.tmp
if ( $status != 0 ) then
    echo ERROR5.
    exit 1
endif
$GTM << fff
	do fff^fmtio
fff
if ("os390" == "$gtm_test_osname") then
	if (-f gtmcore) then
		mv gtmcore fmtiogtmcore6
	endif
else
	if (-f core) then
		mv core fmtiocore6
	endif
endif 
$MUPIP load b1.zwr  >&! temp6.tmp
if ( $status != 0 ) then
    echo ERROR6.
    exit 1
endif
$GTM << ggg
	do ggg^fmtio
ggg
if ("os390" == "$gtm_test_osname") then
	if (-f gtmcore) then
		mv gtmcore fmtiogtmcore7
	endif
else
	if (-f core) then
		mv core fmtiocore7
	endif
endif 
$MUPIP load b1.glo  >&! temp7.tmp
if ( $status != 0 ) then
    echo ERROR7.
    exit 1
endif
$GTM << hhh
	do hhh^fmtio
hhh
if ("os390" == "$gtm_test_osname") then
	if (-f gtmcore) then
		mv gtmcore fmtiogtmcore8
	endif
else
	if (-f core) then
		mv core fmtiocore8
	endif
endif 
$MUPIP load b2.zwr  >&! temp8.tmp
if ( $status != 0 ) then
    echo ERROR8.
    exit 1
endif
$GTM << iii
	do iii^fmtio
iii
if ("os390" == "$gtm_test_osname") then
	if (-f gtmcore) then
		mv gtmcore fmtiogtmcore9
	endif
else
	if (-f core) then
		mv core fmtiocore9
	endif
endif 
$MUPIP load b2.glo  >&! temp9.tmp
if ( $status != 0 ) then
    echo ERROR9.
    exit 1
endif
$GTM << jjj
	do jjj^fmtio
jjj
if ("os390" == "$gtm_test_osname") then
	if (-f gtmcore) then
		mv gtmcore fmtiogtmcorea
	endif
else
	if (-f core) then
		mv core fmtiocorea
	endif
endif 
$gtm_tst/com/dbcheck.csh 
$grep "Restored" tempa.tmp
$grep "LOAD" temp?.tmp
#
echo "END of fmtio test."
#
