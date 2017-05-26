! The blow is used in dollardata.m
add ~name x(1)   ~reg=REG1
add ~name x(1,2) ~reg=REG2
add ~name x(1,3) ~reg=REG3
add ~name x(2)   ~reg=REG1
add ~name x(3)   ~reg=REG2
add ~name x(4)   ~reg=REG3
add ~name x(5)   ~reg=REG1
add ~name x(6)   ~reg=REG2
add ~name x(7)   ~reg=REG3
!!
! The below is used in dollarorder.m
add ~name a(01:11) ~reg=REG1
add ~name a(11:21) ~reg=REG2
add ~name a(21:31) ~reg=REG3
add ~name a(31:41) ~reg=REG1
add ~name a(40,1:10) ~reg=REG2
add ~name a(40,5,1:10) ~reg=REG3
add ~name a(40,5,8,1:10) ~reg=REG1
add ~name a(41:51) ~reg=REG2
add ~name a(51:61) ~reg=REG3
!!
add ~region REG1 ~dyn=REG1
change ~region REG1 ~std
add ~segment REG1 ~file=REG1
add ~region REG2 ~dyn=REG2
change ~region REG2 ~std
add ~segment REG2 ~file=REG2
add ~region REG3 ~dyn=REG3
change ~region REG3 ~std
add ~segment REG3 ~file=REG3
change ~region DEFAULT ~std
