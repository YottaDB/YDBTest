ztidrv	;drive tests of invalid $ZTRAPs
	S $ZT="w:$zv'[""VMS"" $zs,!,! set $ecode="""" ZG "_$ZL_":base+tst^"_$T(+0)
base	i $I(tst) w "do NOLAB^ztiref",!  do NOLAB^ztiref
	i $I(tst) w "do OFF^ztiref",!  do OFF^ztiref
	i $I(tst) w "do MOD^ztiref",!  do MOD^ztiref
	i $I(tst) w "do SUB4^ztiref",!  do SUB4^ztiref
	i $I(tst) w "do IND^ztiref",!  do IND^ztiref
	i $I(tst) w "do TST1^zticmd3",!  do TST1^zticmd3
	i $I(tst) w "do TST2^zticmd3",!  do TST2^zticmd3
	i $I(tst) w "do TST3^zticmd3",!  do TST3^zticmd3
	i $I(tst) w "do TST4^zticmd3",!  do TST4^zticmd3
	quit
