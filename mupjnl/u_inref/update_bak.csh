#! /usr/local/bin/tcsh -f
#$GTM << aaa
#	f i=1:1:1000 s ^a(i)=\$j(i,512)
#	f i=1:1:1000 s ^b(i)=\$j(i,512)
#	f i=1:1:1000 s ^c(i)=\$j(i,512)
#aaa	
$GTM << EOF
  d ^test77a
EOF
