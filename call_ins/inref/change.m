chgint
     Use 0
     S intrst=0.5
     W !,"interest rate is currently ",intrst
     I intrst'=1.0 Set intrst=100 W !,"success",!
     W !,"$TEST = ",$TEST
     W !,"interest rate is NOW ",intrst,!
     Q
