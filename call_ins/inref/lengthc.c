#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <locale.h>
#include <wchar.h>
#include "shrenv.h"
#include "gtm_stdio.h" 
#include "gtmxc_types.h"

xc_long_t lengthc(int count,gtm_char_t* mbstring,gtm_char_t* mbstring2)
{
	char err[500];
	xc_char_t *upper;
	xc_long_t length;
	wchar_t *w1,*w2,*w3;
	int n1,n2,len1,len2,len3;

	setlocale(LC_ALL, "");

	upper = (char *)malloc(strlen(mbstring) * sizeof(char));
	n1 = strlen(mbstring) * sizeof(wchar_t);
	w1 = (wchar_t *)malloc(n1);
	len1 = mbstowcs(w1,mbstring,n1);
	length = wcslen(w1);

	n2 = strlen(mbstring2) * sizeof(wchar_t);
	w2 = (wchar_t *)malloc(n2);
	len2 = mbstowcs(w2,mbstring2,n2);

	w3 = (wchar_t *)malloc(n1+n2);
	wcscpy(w3,w1);
	wcscat(w3,w2);
	len3 = wcslen(w3);
	
	PRINTF("\nC2(lengthc.c) in C->M->C->M\n");
	PRINTF("In C2:The length of \"%s\" is : %d\n",mbstring,len1);
	PRINTF("In C2:The length of \"%s\" is : %d\n",mbstring2,len2);
	PRINTF("In C2:The length of concatenated string \"%ls\" is : %d\n",w3,len3);
	PRINTF("In C2:Now gtm_ci('ucase',upper,mbstring) will call into M2\n");
	fflush(stdout);
	if (gtm_ci("ucase",upper,mbstring))
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s \n",err);
		fflush(stdout);
	}
	PRINTF("In C2:Call into ucase^ucase returned the upper case of %s as :%s\n",mbstring,upper);
	fflush(stdout);
	
	return length;
}
