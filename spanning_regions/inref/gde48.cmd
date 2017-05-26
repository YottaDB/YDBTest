! Test sub-ranges with common end-points
add -name x(1:10) -reg=XREG
add -name x(6:10) -reg=YREG
exit
add -region XREG -dyn=XREG -stdnullcoll
add -segment XREG -file=XREG.dat
add -region YREG -dyn=YREG -stdnullcoll
add -segment YREG -file=YREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
