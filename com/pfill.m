pfill	;
        ; act="set"  fills data in
	; act="ver"  verifies that the data is in data base
	; act="kill" kills the data from the database
in0(act,pno)
	set ITEM="Random database fill 0 ",ERR=0
	set prime=251
	set root(1)=6
	set root(2)=11
	set root(3)=14
	set root(4)=18
	set root(5)=19
	set root(6)=24
	set root(7)=26
	set root(8)=29
	set root(9)=30
	set root(10)=33
	do filling^pfill(act,prime,root(pno))
	quit

in1(act,pno)
	set ITEM="Random database fill 1 ",ERR=0
	set prime=503
	set root(1)=5
	set root(2)=10
	set root(3)=15
	set root(4)=17
	set root(5)=19
	set root(6)=20
	set root(7)=29
	set root(8)=30
	set root(9)=31
	set root(10)=34
	do filling^pfill(act,prime,root(pno))
	quit

in2(act,pno)
	set ITEM="Random database fill 2 ",ERR=0
	set prime=1009
	set root(1)=11
	set root(2)=17
	set root(3)=22
	set root(4)=26
	set root(5)=31
	do filling^pfill(act,prime,root(pno))
	quit

in3(act,pno)
	set ITEM="Random database fill 3 ",ERR=0
	set prime=10007
	set root(1)=5
	set root(2)=7
	set root(3)=10
	set root(4)=14
	set root(5)=15
	do filling^pfill(act,prime,root(pno))
	quit

in4(act,pno)
	set ITEM="Random database fill 4 ",ERR=0
	set prime=100003
	set root(1)=2
	set root(2)=3
	set root(3)=5
	set root(4)=7
	set root(5)=29
	do filling^pfill(act,prime,root(pno))
	quit

in5(act,pno)
	set ITEM="Data base fill 5 ",ERR=0
	set prime=1000003
	set root(1)=2
	set root(2)=5
	set root(3)=7
	set root(4)=11
	set root(5)=12
	do filling^pfill(act,prime,root(pno))
	quit


filling(act,prime,root)
	new ndx,shortgbl
	set ndx=1
	set shortgbl=$ztrnlnm("gtm_test_useshortglobals")
	for i=0:1:prime-2 do
	. set regname="abcdefghi" 
	. for j=i:1:i+8 do
	. .  set regindex=j#9+1
	. .  if shortgbl  set x="^"_$e(regname,regindex,regindex)_"(ndx)"
	. .  if 'shortgbl set x="^"_$e(regname,regindex,regindex)_"randomdatabasefilling(ndx)"
	. .  set y=$j(ndx,15)
	. .  if act="kill" kill @x
	. .  if act="set"  set @x=y 
	. .  if act="ver"  do EXAM(ITEM,x,y,@x)
	. set ndx=(ndx*root)#prime
	if ERR=0 write act," PASS",!
	quit


EXAM(item,pos,vcorr,vcomp)
	if vcorr=vcomp  quit
	write " ** FAIL ",item," verifying global ",pos,!
	write ?10,"CORRECT  = ",vcorr,!
	write ?10,"COMPUTED = ",vcomp,!
	set ERR=ERR+1
	quit
