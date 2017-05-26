! Test miscellaneous scenarios
add -name XY          -region=DEFAULT
add -name XY("a":"b") -region=DEFAULT
add -name XY("b":"d") -region=XREG
add -name XY("d":"f") -region=DEFAULT
add -name XY("g":"h") -region=XREG
exit
add -region XREG -dyn=XREG -stdnullcoll
add -segment XREG -file=XREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
