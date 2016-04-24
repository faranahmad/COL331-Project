#include <inc/lib.h>
#include <inc/x86.h>

void
sleep(int sec)
{
	int currtime = sys_time_msec();
	int endtime = currtime + sec * 1000;

	if (currtime < 0 && currtime > -MAXERROR)
		panic("sys_time_msec: %e", currtime);
	if (endtime < currtime)
		panic("sleep: wrap");

	while (sys_time_msec() < endtime)
		sys_yield();
}

void
umain(int argc, char **argv)
{
	int i;
	for (i = 0; i < 50; i++)
		sys_yield();

	cprintf("starting sleeping ");
	for (i = 5; i >= 0; i--) {
		cprintf("%d ", i);
		sleep(1);
	}
	cprintf("Waking up again\n");
}