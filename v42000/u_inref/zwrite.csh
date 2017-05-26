#!/usr/local/bin/tcsh -f
$GTM << aaa
d ^zwrset(10000)
zwr x("A","B",*)       
zshow "v":newvar
zwr x("A",*)       
k newvar
d ^zwrtest(10000)
aaa
