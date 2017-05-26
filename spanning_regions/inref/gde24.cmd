! Test miscellaneous scenarios
add -name X       -region=XREG
add -name X("a":) -region=DEFAULT
exit
add -region XREG -dyn=XREG -stdnullcoll
add -segment XREG -file=XREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
