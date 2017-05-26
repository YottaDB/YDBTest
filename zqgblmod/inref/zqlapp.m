zqlapp(bottom,top);
	W "ZQLAPP Started",!
	S $ZT="g ERROR"
	w "$zqgblmod of ^alongglobalnameforzqgblmod ",$zqgblmod(^alongglobalnameforzqgblmod),!
	w "$zqgblmod of ^b ",$zqgblmod(^b),!
	w "$zqgblmod of ^clongglobalnameforzqgblmod ",$zqgblmod(^clongglobalnameforzqgblmod),!
	w "$zqgblmod of ^d ",$zqgblmod(^d),!
	w "$zqgblmod of ^e ",$zqgblmod(^e),!
	w !,"Followings globals should be checked manually",!
	F i=bottom:1:top D
	.  S apply=1
	.  if ($zqgblmod(^alongglobalnameforzqgblmod(i)))'=0 set apply=0  w "^alongglobalnameforzqgblmod(",i,") ",!
	.  if ($zqgblmod(^b(i)))'=0 set apply=0  w "^b(",i,") ",!
	.  if ($zqgblmod(^clongglobalnameforzqgblmod(i)))'=0 set apply=0  w "^clongglobalnameforzqgblmod(",i,") ",!
	.  if ($zqgblmod(^d(i)))'=0 set apply=0  w "^d(",i,") ",!
	.  if ($zqgblmod(^e(i)))'=0 set apply=0  w "^e(",i,") ",!
	.  if apply=1 D
	.  . TStart ():Serial
	.  . set ^alongglobalnameforzqgblmod(i)=i
	.  . set ^b(i)=i
	.  . set ^clongglobalnameforzqgblmod(i)=i
	.  . set ^d(i)=i
	.  . set ^e(i)=i
	.  . TCommit
	s fail=0
	w "$zqgblmod of ^aa ",$zqgblmod(^aa),!
	w "$zqgblmod of ^bb ",$zqgblmod(^bb),!
	w "$zqgblmod of ^cc ",$zqgblmod(^cc),!
	w "$zqgblmod of ^dd ",$zqgblmod(^dd),!
	w "$zqgblmod of ^ee ",$zqgblmod(^ee),!
	w "Check variables which was never applied",!
	w "Following globals was never applied but zqgblmod is doubtful...",!
	F i=bottom:1:top D
	.  if ($zqgblmod(^aa(i)))'=0 w "^aa(",i,") ",! s fail=1
	.  if ($zqgblmod(^bb(i)))'=0 w "^bb(",i,") ",! s fail=1
	.  if ($zqgblmod(^cc(i)))'=0 w "^cc(",i,") ",! s fail=1
	.  if ($zqgblmod(^dd(i)))'=0 w "^dd(",i,") ",! s fail=1
	.  if ($zqgblmod(^ee(i)))'=0 w "^ee(",i,") ",! s fail=1
	if fail=1 w "TEST FAILED for globals never applied",!
	W "ZQLAPP Ends",!
	Q		
ERROR	S $ZT=""
	ZSHOW "*"
	ZM +$ZS
