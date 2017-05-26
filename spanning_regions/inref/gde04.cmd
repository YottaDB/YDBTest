! Test mix of RANGE and POINT type subscripted names at various subscript levels
add -name X             -region=xreg
add -name X(0:2)        -region=x02reg
add -name X(1)          -region=x1reg
add -name X(1,1:9)      -region=x119reg
add -name X(1,2)        -region=x12reg
add -name X(1,2,"a":)   -region=x12azreg
add -name X(1,2,"x")    -region=x12xreg
add -name X(1,2,"x",4)  -region=x12x4reg
!
! the map that gets created in the .gld for the above name specifications is the following
! X              <-- DEFAULT
! X(0)           <-- XREG
! X(1)           <-- X02REG
! X(1,1)         <-- X1REG
! X(1,2)         <-- X119REG
! X(1,2,"a")     <-- X12REG
! X(1,2,"x")     <-- X12AZREG
! X(1,2,"x",4)   <-- X12XREG
! X(1,2,"x",4)++ <-- X12X4REG
! X(1,2,"x")++   <-- X12XREG
! X(1,2)++       <-- X12AZREG
! X(1,9)         <-- X119REG
! X(1)++         <-- X1REG
! X(2)           <-- X02REG
! X)             <-- XREG
! $c(255)...     <-- DEFAULT
exit
add -region X119REG -dyn=X119REG -stdnullcoll
add -segment X119REG -file=X119REG.dat
add -region X12REG -dyn=X12REG -stdnullcoll
add -segment X12REG -file=X12REG.dat
add -region X12X4REG -dyn=X12X4REG -stdnullcoll
add -segment X12X4REG -file=X12X4REG.dat
add -region X12XREG -dyn=X12XREG -stdnullcoll
add -segment X12XREG -file=X12XREG.dat
add -region X02REG -dyn=X02REG -stdnullcoll
add -segment X02REG -file=X02REG.dat
add -region X1REG -dyn=X1REG -stdnullcoll
add -segment X1REG -file=X1REG.dat
add -region X12AZREG -dyn=X12AZREG -stdnullcoll
add -segment X12AZREG -file=X12AZREG.dat
add -region XREG -dyn=XREG -stdnullcoll
add -segment XREG -file=XREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
show -map -reg=X1REG

