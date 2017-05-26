! Test miscellaneous scenarios
add -name X       -region=DEFAULT
add -name X("a":) -region=XREG
exit
add -region XREG -dyn=XREG -stdnullcoll
add -segment XREG -file=XREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
