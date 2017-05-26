! Test miscellaneous scenarios
add -name X       -region=DEFAULT
add -name X("a":"b") -region=XREG
add -name X("b":"d") -region=XREG
add -name X("d":"f") -region=DEFAULT
add -name X("g":"h") -region=XREG
exit
add -region XREG -dyn=XREG -stdnullcoll
add -segment XREG -file=XREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
