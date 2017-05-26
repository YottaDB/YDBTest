bad
a a
a +
@gdetst.nonex
@gdenamtst
@gderegtst
@gdesegtst
c -r b -r=509
c -r b -r=508
c -r b -j=(be,buf=3)
c -r b -j=(be,buf=4)
c -s b -acc=mm
locks -r=$default
s -a
sp show default
log
log -on
log
sh
log -on=gdetst.tstlog
sh -t
log -off
sh -v
sh -m
v
v -v
v -m
v -t
e
d -n a
d -r a
d -s a
v -a
sh -m -r=a
sh -m -r=b
sh -a
se -f=other
a -n no -r=no
se -f=no
se -f=no -q
se -q
