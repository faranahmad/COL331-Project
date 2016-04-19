#include <inc/lib.h>
#include <inc/x86.h>
#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/string.h>


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


int checkInt(char* inp)
{
  int i=0;
  for (;i<strlen(inp);i++)
  {
    if ((inp[i]<'0') || (inp[i]>'9'))
    {
      if (inp[i]!=32)
        return 0;
    }
  }
  return 1;
}

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

int determinedaycode(long year)
{
  int daycode;
  int d1, d2, d3;
  
  d1 = (year - 1.)/ 4.0;
  d2 = (year - 1.)/ 100.;
  d3 = (year - 1.)/ 400.;
  daycode = (year + d1 - d2 + d3) %7;
  return daycode;
}


int determineleapyear(long year)
{
  if(((year% 4 == FALSE) && (year%100 != FALSE)) || (year%400 == FALSE))
  {
    days_in_month[2] = 29;
    return TRUE;
  }
  else
  {
    days_in_month[2] = 28;
    return FALSE;
  }
}

void calendar(long year, int daycode,int month1)
{
  if(year < 0)
  {
    cprintf("Wrong input year shuld be postive\n");
    return;
  }
  if(month1 < 0)
  {
    cprintf("Month is not correct enter 1...12\n");
    return;
  }
  int month, day;
  if(month1 == 0)
  {
  for ( month = 1; month <= 12; month++ )
  {
    cprintf("%s %ld", months[month],year);
    cprintf("\n\nSun  Mon  Tue  Wed  Thu  Fri  Sat\n" );
    
    // Correct the position for the first date
    for ( day = 1; day <= 1 + daycode * 5; day++ )
    {
      cprintf(" ");
    }
    
    // Print all the dates for one month
    for ( day = 1; day <= days_in_month[month]; day++ )
    {
      cprintf("%2d", day );
      
      // Is day before Sat? Else start next line Sun.
      if ( ( day + daycode ) % 7 > 0 )
        cprintf("   " );
      else
        cprintf("\n " );
    }
      // Set position for next month
      daycode = ( daycode + days_in_month[month] ) % 7;
  }
  }
  else{
    cprintf("%s %ld", months[month1],year);
    cprintf("\n\nSun  Mon  Tue  Wed  Thu  Fri  Sat\n" );
    
    // Correct the position for the first date
    for ( day = 1; day <= 1 + daycode * 5; day++ )
    {
      cprintf(" ");
    }
    // Print all the dates for one month
      // printf("reached here let s se whata happebs\n");
    for ( day = 1; day <= days_in_month[month1]; day++ )
    {
      cprintf("%2d", day );
      
      // Is day before Sat? Else start next line Sun.
      if ( ( day + daycode ) % 7 > 0 )
        cprintf("   " );
      else
        cprintf("\n " );
    }
      // Set position for next month
      daycode = ( daycode + days_in_month[month1] ) % 7;
  }
}


void umain(int argc, char **argv)
{
  if(argc > 2)
  {
    cprintf("incorrect input try again\n");
    return;
  }
  char *year;
  long year1;
  int daycode,leapyear,month;
  if(argc == 1)
  {
    struct rtcdate r;
    cmostime(&r);
    year1 = (long)(r.year);
    month = r.month;
    daycode = determinedaycode(year1);
    determineleapyear(year1);
    calendar(year1,daycode,month);
    cprintf("\n");
    cprintf("Today's Date : %d\n",r.day);
    return;
  }
  else
  {
    year = argv[1];
    if(checkInt(year) == 0)
    {
      cprintf("year should be a positive integer\n");
      return;
    }
  }
  year1 = strtol(year,NULL,10);
  month = 0;
  daycode = determinedaycode(year1);
  determineleapyear(year1);
  calendar(year1,daycode,month);
  cprintf("\n");
}