d9e02447
allreg1;
	for index=1:1:1000 do
	. set ^a(index)=index
	. set ^b(index)=index
	. set ^c(index)=index
	. set ^d(index)=index
	. set ^e(index)=index
	quit
allreg2;
	for index=1001:1:2000 do
	. set ^a(index)=index
	. set ^b(index)=index
	. set ^c(index)=index
	. set ^d(index)=index
	. set ^e(index)=index
	quit
partial;
	for index=2001:1:3000 do
	. set ^b(index)=index
	. set ^c(index)=index
	. set ^e(index)=index
	quit
verify;
	for index=1:1:2000 do
	. if $get(^a(index))'=index write "Verify fail for ^a(",index,"): Expected ",index," Found ",$get(^a(index)),!
	. if $get(^b(index))'=index write "Verify fail for ^b(",index,"): Expected ",index," Found ",$get(^b(index)),!
	. if $get(^c(index))'=index write "Verify fail for ^c(",index,"): Expected ",index," Found ",$get(^c(index)),!
	. if $get(^d(index))'=index write "Verify fail for ^d(",index,"): Expected ",index," Found ",$get(^d(index)),!
	. if $get(^e(index))'=index write "Verify fail for ^e(",index,"): Expected ",index," Found ",$get(^e(index)),!
	for index=2001:1:3000 do
	. if $get(^b(index))'=index write "Verify fail for ^b(",index,"): Expected ",index," Found ",$get(^b(index)),!
	. if $get(^c(index))'=index write "Verify fail for ^c(",index,"): Expected ",index," Found ",$get(^c(index)),!
	. if $get(^e(index))'=index write "Verify fail for ^e(",index,"): Expected ",index," Found ",$get(^e(index)),!
	quit
 
