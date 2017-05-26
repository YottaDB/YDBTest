! Test map where X(2,"a") maps to same region as X(9) and in between is a ++ map entry X(2)++
! Similar to gde19.cmd but at a lower subscript level
add -name X           -region=xreg
add -name X(1:9)      -region=x19reg
add -name X(2,"a":)   -region=x2azreg
add -name X(2,"x")    -region=x2xreg
add -name X(2,"x",4)  -region=x2x4reg
exit
add -region X2X4REG -dyn=X2X4REG -stdnullcoll
add -segment X2X4REG -file=X2X4REG.dat
add -region X2AZREG -dyn=X2AZREG -stdnullcoll
add -segment X2AZREG -file=X2AZREG.dat
add -region X19REG -dyn=X19REG -stdnullcoll
add -segment X19REG -file=X19REG.dat
add -region X2XREG -dyn=X2XREG -stdnullcoll
add -segment X2XREG -file=X2XREG.dat
add -region XREG -dyn=XREG -stdnullcoll
add -segment XREG -file=XREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
show -map -reg=X2XREG

