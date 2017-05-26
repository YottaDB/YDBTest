! Test lone mapping of unsubscripted gvn
add -name X*     -region=XREG
add -name X      -region=X1REG
add -name X(:)   -region=XREG
exit
add -region X1REG -dyn=X1REG -stdnullcoll
add -segment X1REG -file=X1REG.dat
add -region XREG -dyn=XREG -stdnullcoll
add -segment XREG -file=XREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
