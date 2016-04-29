#include <kern/UserProg.h>
#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/cmostime.c>

void User_data(int argc, char **argv)
{
  struct rtcdate r;
  cmostime(&r);
  cprintf("%d/%d/%d %d:%d:%d\n",
    r.year,
    r.month,
    r.day,
    r.hour,
    r.minute,
    r.second);
}