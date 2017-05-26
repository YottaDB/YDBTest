     ; Save a record
savact(anum,lbal,int,intytd)
     S $P(^ACCT(anum,4),"|",1)=lbal
     S $P(^ACCT(anum,4),"|",3)=int
     S $P(^ACCT(anum,6),"|",1)=intytd
     Q
