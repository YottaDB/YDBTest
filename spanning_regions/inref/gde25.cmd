! Test miscellaneous scenarios
add -name X       -region=XREG
add -name X("a":) -region=YREG
exit
add -region XREG -dyn=XREG -stdnullcoll
add -segment XREG -file=XREG.dat
add -region YREG -dyn=YREG -stdnullcoll
add -segment YREG -file=YREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
