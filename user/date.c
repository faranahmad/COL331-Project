#include <inc/lib.h>
#include <inc/x86.h>
#include <inc/mmu.h>
#include <inc/memlayout.h>



#define CMOS_PORT    0x70
#define CMOS_RETURN  0x71
#define CMOS_STATA   0x0a
#define CMOS_STATB   0x0b
#define CMOS_UIP    (1 << 7)        // RTC update in progress

#define SECS    0x00
#define MINS    0x02
#define HOURS   0x04
#define WEEKDAY 0x06
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

#define TRUE    1
#define FALSE   0


int days_in_month[]={0,31,28,31,30,31,30,31,31,30,31,30,31};
char *months[]=
{
  " ",
  "\n\n\nJanuary",
  "\n\n\nFebruary",
  "\n\n\nMarch",
  "\n\n\nApril",
  "\n\n\nMay",
  "\n\n\nJune",
  "\n\n\nJuly",
  "\n\n\nAugust",
  "\n\n\nSeptember",
  "\n\n\nOctober",
  "\n\n\nNovember",
  "\n\n\nDecember"
};


struct rtcdate {
  int second;
  int minute;
  int hour;
  int day;
  int month;
  int year;
  int weekday;
};

void
microdelay(int us)
{
}


static int cmos_read(int reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
}

static void fill_rtcdate(struct rtcdate *r)
{
  r->second = cmos_read(SECS);
  r->minute = cmos_read(MINS);
  r->hour   = cmos_read(HOURS);
  r->day    = cmos_read(DAY);
  r->month  = cmos_read(MONTH);
  r->year   = cmos_read(YEAR);
  r->weekday = cmos_read(WEEKDAY);
}


void cmostime(struct rtcdate *r)
{
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
    CONV(minute);
    CONV(hour  );
    CONV(day   );
    CONV(month );
    CONV(year  );
    CONV(weekday);

#undef     CONV
  }

  *r = t1;
  r->year += 2000;
}


void
umain(int argc, char **argv)
{
  if(argc > 2)
  {
  	cprintf("wrong input\n");
  	return;
  }
  if(argc == 2)
  {
  	char *inp = argv[1];
  	if(strlen(inp) > 2)
  	{
  		cprintf("wrong input\n");
  		return;
  	}
  	if(inp[0] != 32)
  	{
  		cprintf("wrong input\n");
  		return;
  	}
  }
  struct rtcdate r;
  cmostime(&r);
  cprintf("year : %d month : %d day : %d hour : %d minute : %d second : %d weekday : %d\n",r.year,r.month,r.day,r.hour,r.minute,r.second,r.weekday);
  // cprintf("i am environment %08x\n", thisenv->env_id);
}