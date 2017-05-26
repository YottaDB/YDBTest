#include "shrenv.h"
#include "gtm_stdio.h"
#include "gtm_stdlib.h"
#include "gtm_string.h"
#include "gtmxc_types.h"
#include <string.h>
#include <locale.h>
#include <wchar.h>

void xc_wcscat	(int count,
		 xc_char_t **in_data1,
		 xc_char_t **in_data2,
		 xc_char_t **out_data)
{
	wchar_t *w1, *w2;
	int n1,n2,len;
	setlocale(LC_ALL, "");

	n1 = (int)(strlen(*in_data1) * sizeof(wchar_t));
	w1 = (wchar_t *)malloc(n1);
	len = (int)mbstowcs(w1,*in_data1,n1);	
	n2 = (int)(strlen(*in_data2) * sizeof(wchar_t));
	w2 = (wchar_t *)malloc(n2+n1);
	len = (int)mbstowcs(w2,*in_data2,n2);	
	wcscat(w2,w1);
        (void)SPRINTF(*out_data,"%ls",w2);
	fflush(stdout);
	
}
