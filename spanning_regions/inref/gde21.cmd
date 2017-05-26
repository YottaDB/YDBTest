! Test map where X("a") maps to same region as X)
! Similar to gde19.cmd but at a lower subscript level
add -name X         -region=xreg
add -name X("a":)   -region=xazreg
add -name X("x")    -region=xxreg
add -name X("x",4)  -region=xx4reg
exit
add -region XX4REG -dyn=XX4REG -stdnullcoll
add -segment XX4REG -file=XX4REG.dat
add -region XXREG -dyn=XXREG -stdnullcoll
add -segment XXREG -file=XXREG.dat
add -region XAZREG -dyn=XAZREG -stdnullcoll
add -segment XAZREG -file=XAZREG.dat
add -region XREG -dyn=XREG -stdnullcoll
add -segment XREG -file=XREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
