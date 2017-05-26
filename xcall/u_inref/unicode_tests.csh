echo "This section tests external calls using unicode string"
echo "######################################################"
$switch_chset "UTF-8"
set dir1 = "multi_ｂｙｔｅ_後漢書_𠞉𠟠_4byte"
mkdir $dir1
cd $dir1
source $gtm_tst/$tst/u_inref/make_unistring.csh
$GTM << EOF
write "do unistrtest",! do ^unistrtest
halt
EOF
cd ..
source $gtm_tst/$tst/u_inref/make_uniprealloc.csh
$GTM << EOF
write "do uniprealloc",! do ^uniprealloc
halt
EOF

source $gtm_tst/$tst/u_inref/make_unimaxprealloc.csh
$GTM << EOF
write "do unimaxprealloc",! do ^unimaxprealloc
halt
EOF

echo "######################################################"
echo "Section done..."
