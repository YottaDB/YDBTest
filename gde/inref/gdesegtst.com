t -s -bl=512
t -s -ext=200
a -s
a -s  -f=a
a -s 1 -f=a
a -s a
a -s a -nof
a -s a -f
a -s a -f=a -f=a
a -s a2345678901234567 -f=a
a -s a234567890123456 -f=a -acc=bad
a -s a -f=
a -s a -f=a2345678901234567890123456789012345678901
a -s a -f=a -acc=
a -s a -f=a -acc=1
a -s a -f=a -all=two
a -s a -f=a -acc=bg -all=9
a -s a -f=a -acc=mm -all=16777217
a -s a -f=a -acc=bg -bu=63
a -s a -f=a -acc=mm -bu=63
a -s node -acc=mm -def -ext=65535 -f=a2345678::device:[directory.subdirectory]file.type;1
a -s device -f=a23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
a -s directory -f=node::device:[a234567890123456789012345678901234567890.subdirectory]file.type;1
a -s subdirectory -f=node::device:[directory.a234567890123456789012345678901234567890]file.type;1
a -s file -f=node::device:[directory.subdirectory]a234567890123456789012345678901234567890.type;1
a -s type -f=node::device:[directory.subdirectory]file.a234567890123456789012345678901234567890;1
a -s version -f=node::device:[directory.subdirectory]file.type;1234567
a -s toolong -f=node::a234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234:[directory.subdire
a -s a -acc=bg -glo=63 -f=node::a23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123:[director
a -s a -f=a -acc=bg -glo=4097
a -s a -f=a -acc=bg -glo=4096 -wind=10
a -s a -f=a -acc=bg -glo=64 -def
a -s a -f=a -acc=mm -glo=10
a -s a -f=a -acc=mm -lock=9
a -s a -f=a -acc=bg -lock=201
a -s a -f=a -acc=mm -lock=10 -wind=10
a -s a -f=a -acc=bg -lock=200 -wind=10
c -s b -f=b
c -s a -f=b
a -s b -f=b
a -s b -f=b
r -s a b
r -s a c
c -s a -acc=bg
r -s a c
r -s a c
d -s a
d -s c
sh -s c
v -s c
a -s a -f=b
sh -s a
sh -s
v -s a
v -s
@gde2lvltst
