bal(anum,lbal)
     S lbal=$P(^ACCT(anum,4),"|",1)
     W !,"******************************************",!
     W !,"$ZLEVEL = ",$zlevel
     ZGOTO 0
     W !,"I am here",!
     Q
int(anum,intrst,intytd)
     S intrst=$P(^ACCT(anum,4),"|",3)
     S intytd=$P(^ACCT(anum,6),"|",1)
     Q
chgint(anum,intrst)
     Use 0
     I intrst<1.0 S intrst=2.5
     Q 
extbal(anum)
     N lbal
     S lbal=$P(^ACCT(anum,4),"|",1)
     Q lbal
ccode(anum)
     N ccode
     S ccode=$P(^ACCT(anum,3),"|",2)
     Q ccode
