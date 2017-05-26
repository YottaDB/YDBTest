text4	; Test of $TEXT function - Calls texttst and text1-3 routines
	W "In text4 beginning calls to other routines",!,!
	W !
	D OUT^texttst
	W !
	W "returned from call to texttest at entryref out",!,!
	W !
	D STS^texttst
	W !
	W "returned after accessing texttst at sts+10",!,!
	W "calling text2",!,!
	G IN^text2
	W !
ASS	W "calling text3",!,!
	D ^text3
	W !
	W "returned from text3",!,!
	D IN^text2
	W !
END	W "all over",!,!	
