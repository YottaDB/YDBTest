! Test that names with ranges that intersect but map to same region are superseded by a bigger range
! Also test names with levels of subscripts ranging anywhere from 1 to 31 in this test.
add -name X             -region=xreg
add -name X(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,"ef")       -region=x32reg
add -name X(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,0:2)        -region=x31reg
add -name X(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,1:5)        -region=x31reg
add -name X(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,3:"mm")     -region=x31reg
add -name X(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,"ef":"kk")  -region=x31reg
add -name X(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,31)            -region=x31reg
exit
add -region X31REG -dyn=X31REG -stdnullcoll
add -segment X31REG -file=X31REG.dat
add -region X32REG -dyn=X32REG -stdnullcoll
add -segment X32REG -file=X32REG.dat
add -region XREG -dyn=XREG -stdnullcoll
add -segment XREG -file=XREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
show -map -reg=X32REG

