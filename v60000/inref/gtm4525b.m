startwait(fillid,maxsleep)
  set i=$H,q=0
  for  quit:q  do
  . set delta=$$^difftime($H,i)
  . zwrite ^%jobwait,delta
  . write:(delta>maxsleep) "TEST-E-IMPTPSTARTTIMEOUT",!
  . set q=($get(^%imptp(fillid,"jsyncnt"))=4)!(delta>maxsleep)
  . quit:q
  . hang 1
  quit
