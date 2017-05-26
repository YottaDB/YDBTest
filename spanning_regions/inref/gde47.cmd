! Test highest possible gblname and highest possible range end subscript
add -name zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz("zz":) -reg=ZZREG
add -name zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz("z":) -reg=ZREG
add -name yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy("yy":) -reg=YYREG
add -name yyyyyyyyyyyyyyyyyyyyyyyyyyyyyy("y":) -reg=YREG
exit
add -region ZREG -dyn=ZREG -stdnullcoll
add -segment ZREG -file=ZREG.dat
add -region ZZREG -dyn=ZZREG -stdnullcoll
add -segment ZZREG -file=ZZREG.dat
add -region YYREG -dyn=YYREG -stdnullcoll
add -segment YYREG -file=YYREG.dat
add -region YREG -dyn=YREG -stdnullcoll
add -segment YREG -file=YREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
