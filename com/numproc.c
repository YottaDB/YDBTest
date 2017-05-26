#include <unistd.h>
#include <stdio.h>

#if defined __hpux
#include <sys/param.h>
#include <sys/pstat.h>
#include <sys/unistd.h>
#endif

int main()
{
	long numcpus;
#if defined __hpux
	struct pst_dynamic psd;

	if (pstat_getdynamic(&psd, sizeof(psd), (size_t)1, 0) != -1)
		numcpus = psd.psd_proc_cnt;
	else
		numcpus = 1;
#else
	if ((numcpus = sysconf(_SC_NPROCESSORS_ONLN)) == -1)
	{
		numcpus = 1;
	}
#endif
	printf("%d\n", numcpus);
}

