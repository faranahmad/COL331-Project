
obj/user/testbss:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 fa 00 00 00       	call   80012b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	c7 04 24 00 15 80 00 	movl   $0x801500,(%esp)
  800040:	e8 63 02 00 00       	call   8002a8 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800045:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  80004c:	eb 35                	jmp    800083 <umain+0x50>
		if (bigarray[i] != 0)
  80004e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800051:	8b 04 85 20 20 80 00 	mov    0x802020(,%eax,4),%eax
  800058:	85 c0                	test   %eax,%eax
  80005a:	74 23                	je     80007f <umain+0x4c>
			panic("bigarray[%d] isn't cleared!\n", i);
  80005c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80005f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800063:	c7 44 24 08 20 15 80 	movl   $0x801520,0x8(%esp)
  80006a:	00 
  80006b:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800072:	00 
  800073:	c7 04 24 3d 15 80 00 	movl   $0x80153d,(%esp)
  80007a:	e8 0e 01 00 00       	call   80018d <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  80007f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  800083:	81 7d f4 ff ff 0f 00 	cmpl   $0xfffff,-0xc(%ebp)
  80008a:	7e c2                	jle    80004e <umain+0x1b>
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80008c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800093:	eb 11                	jmp    8000a6 <umain+0x73>
		bigarray[i] = i;
  800095:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800098:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80009b:	89 14 85 20 20 80 00 	mov    %edx,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  8000a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8000a6:	81 7d f4 ff ff 0f 00 	cmpl   $0xfffff,-0xc(%ebp)
  8000ad:	7e e6                	jle    800095 <umain+0x62>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8000b6:	eb 38                	jmp    8000f0 <umain+0xbd>
		if (bigarray[i] != i)
  8000b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000bb:	8b 14 85 20 20 80 00 	mov    0x802020(,%eax,4),%edx
  8000c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000c5:	39 c2                	cmp    %eax,%edx
  8000c7:	74 23                	je     8000ec <umain+0xb9>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d0:	c7 44 24 08 4c 15 80 	movl   $0x80154c,0x8(%esp)
  8000d7:	00 
  8000d8:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000df:	00 
  8000e0:	c7 04 24 3d 15 80 00 	movl   $0x80153d,(%esp)
  8000e7:	e8 a1 00 00 00       	call   80018d <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8000f0:	81 7d f4 ff ff 0f 00 	cmpl   $0xfffff,-0xc(%ebp)
  8000f7:	7e bf                	jle    8000b8 <umain+0x85>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000f9:	c7 04 24 74 15 80 00 	movl   $0x801574,(%esp)
  800100:	e8 a3 01 00 00       	call   8002a8 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  800105:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  80010c:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  80010f:	c7 44 24 08 a7 15 80 	movl   $0x8015a7,0x8(%esp)
  800116:	00 
  800117:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80011e:	00 
  80011f:	c7 04 24 3d 15 80 00 	movl   $0x80153d,(%esp)
  800126:	e8 62 00 00 00       	call   80018d <_panic>

0080012b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800131:	e8 e0 0e 00 00       	call   801016 <sys_getenvid>
  800136:	25 ff 03 00 00       	and    $0x3ff,%eax
  80013b:	c1 e0 02             	shl    $0x2,%eax
  80013e:	89 c2                	mov    %eax,%edx
  800140:	c1 e2 05             	shl    $0x5,%edx
  800143:	29 c2                	sub    %eax,%edx
  800145:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80014b:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800150:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800154:	7e 0a                	jle    800160 <libmain+0x35>
		binaryname = argv[0];
  800156:	8b 45 0c             	mov    0xc(%ebp),%eax
  800159:	8b 00                	mov    (%eax),%eax
  80015b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800160:	8b 45 0c             	mov    0xc(%ebp),%eax
  800163:	89 44 24 04          	mov    %eax,0x4(%esp)
  800167:	8b 45 08             	mov    0x8(%ebp),%eax
  80016a:	89 04 24             	mov    %eax,(%esp)
  80016d:	e8 c1 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800172:	e8 02 00 00 00       	call   800179 <exit>
}
  800177:	c9                   	leave  
  800178:	c3                   	ret    

00800179 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80017f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800186:	e8 48 0e 00 00       	call   800fd3 <sys_env_destroy>
}
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	53                   	push   %ebx
  800191:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800194:	8d 45 14             	lea    0x14(%ebp),%eax
  800197:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019a:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001a0:	e8 71 0e 00 00       	call   801016 <sys_getenvid>
  8001a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bb:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  8001c2:	e8 e1 00 00 00       	call   8002a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	e8 6b 00 00 00       	call   800244 <vcprintf>
	cprintf("\n");
  8001d9:	c7 04 24 eb 15 80 00 	movl   $0x8015eb,(%esp)
  8001e0:	e8 c3 00 00 00       	call   8002a8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e5:	cc                   	int3   
  8001e6:	eb fd                	jmp    8001e5 <_panic+0x58>

008001e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8001ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f1:	8b 00                	mov    (%eax),%eax
  8001f3:	8d 48 01             	lea    0x1(%eax),%ecx
  8001f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f9:	89 0a                	mov    %ecx,(%edx)
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	89 d1                	mov    %edx,%ecx
  800200:	8b 55 0c             	mov    0xc(%ebp),%edx
  800203:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800207:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020a:	8b 00                	mov    (%eax),%eax
  80020c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800211:	75 20                	jne    800233 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800213:	8b 45 0c             	mov    0xc(%ebp),%eax
  800216:	8b 00                	mov    (%eax),%eax
  800218:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021b:	83 c2 08             	add    $0x8,%edx
  80021e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800222:	89 14 24             	mov    %edx,(%esp)
  800225:	e8 23 0d 00 00       	call   800f4d <sys_cputs>
		b->idx = 0;
  80022a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800233:	8b 45 0c             	mov    0xc(%ebp),%eax
  800236:	8b 40 04             	mov    0x4(%eax),%eax
  800239:	8d 50 01             	lea    0x1(%eax),%edx
  80023c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023f:	89 50 04             	mov    %edx,0x4(%eax)
}
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80024d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800254:	00 00 00 
	b.cnt = 0;
  800257:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800261:	8b 45 0c             	mov    0xc(%ebp),%eax
  800264:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800268:	8b 45 08             	mov    0x8(%ebp),%eax
  80026b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800275:	89 44 24 04          	mov    %eax,0x4(%esp)
  800279:	c7 04 24 e8 01 80 00 	movl   $0x8001e8,(%esp)
  800280:	e8 bd 01 00 00       	call   800442 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800285:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80028b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800295:	83 c0 08             	add    $0x8,%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	e8 ad 0c 00 00       	call   800f4d <sys_cputs>

	return b.cnt;
  8002a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ae:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8002b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002be:	89 04 24             	mov    %eax,(%esp)
  8002c1:	e8 7e ff ff ff       	call   800244 <vcprintf>
  8002c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8002c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8002cc:	c9                   	leave  
  8002cd:	c3                   	ret    

008002ce <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 34             	sub    $0x34,%esp
  8002d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002db:	8b 45 14             	mov    0x14(%ebp),%eax
  8002de:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e1:	8b 45 18             	mov    0x18(%ebp),%eax
  8002e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e9:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002ec:	77 72                	ja     800360 <printnum+0x92>
  8002ee:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002f1:	72 05                	jb     8002f8 <printnum+0x2a>
  8002f3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002f6:	77 68                	ja     800360 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f8:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002fb:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002fe:	8b 45 18             	mov    0x18(%ebp),%eax
  800301:	ba 00 00 00 00       	mov    $0x0,%edx
  800306:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80030e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800311:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800314:	89 04 24             	mov    %eax,(%esp)
  800317:	89 54 24 04          	mov    %edx,0x4(%esp)
  80031b:	e8 50 0f 00 00       	call   801270 <__udivdi3>
  800320:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800323:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800327:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80032b:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80032e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800332:	89 44 24 08          	mov    %eax,0x8(%esp)
  800336:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80033a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80033d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800341:	8b 45 08             	mov    0x8(%ebp),%eax
  800344:	89 04 24             	mov    %eax,(%esp)
  800347:	e8 82 ff ff ff       	call   8002ce <printnum>
  80034c:	eb 1c                	jmp    80036a <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80034e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800351:	89 44 24 04          	mov    %eax,0x4(%esp)
  800355:	8b 45 20             	mov    0x20(%ebp),%eax
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	8b 45 08             	mov    0x8(%ebp),%eax
  80035e:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800360:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800364:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800368:	7f e4                	jg     80034e <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80036a:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80036d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800372:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800375:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800378:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80037c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800380:	89 04 24             	mov    %eax,(%esp)
  800383:	89 54 24 04          	mov    %edx,0x4(%esp)
  800387:	e8 14 10 00 00       	call   8013a0 <__umoddi3>
  80038c:	05 c8 16 80 00       	add    $0x8016c8,%eax
  800391:	0f b6 00             	movzbl (%eax),%eax
  800394:	0f be c0             	movsbl %al,%eax
  800397:	8b 55 0c             	mov    0xc(%ebp),%edx
  80039a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80039e:	89 04 24             	mov    %eax,(%esp)
  8003a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a4:	ff d0                	call   *%eax
}
  8003a6:	83 c4 34             	add    $0x34,%esp
  8003a9:	5b                   	pop    %ebx
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003af:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003b3:	7e 14                	jle    8003c9 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b8:	8b 00                	mov    (%eax),%eax
  8003ba:	8d 48 08             	lea    0x8(%eax),%ecx
  8003bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c0:	89 0a                	mov    %ecx,(%edx)
  8003c2:	8b 50 04             	mov    0x4(%eax),%edx
  8003c5:	8b 00                	mov    (%eax),%eax
  8003c7:	eb 30                	jmp    8003f9 <getuint+0x4d>
	else if (lflag)
  8003c9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003cd:	74 16                	je     8003e5 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8003cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d2:	8b 00                	mov    (%eax),%eax
  8003d4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003da:	89 0a                	mov    %ecx,(%edx)
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e3:	eb 14                	jmp    8003f9 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8003e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e8:	8b 00                	mov    (%eax),%eax
  8003ea:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f0:	89 0a                	mov    %ecx,(%edx)
  8003f2:	8b 00                	mov    (%eax),%eax
  8003f4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003fe:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800402:	7e 14                	jle    800418 <getint+0x1d>
		return va_arg(*ap, long long);
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	8b 00                	mov    (%eax),%eax
  800409:	8d 48 08             	lea    0x8(%eax),%ecx
  80040c:	8b 55 08             	mov    0x8(%ebp),%edx
  80040f:	89 0a                	mov    %ecx,(%edx)
  800411:	8b 50 04             	mov    0x4(%eax),%edx
  800414:	8b 00                	mov    (%eax),%eax
  800416:	eb 28                	jmp    800440 <getint+0x45>
	else if (lflag)
  800418:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80041c:	74 12                	je     800430 <getint+0x35>
		return va_arg(*ap, long);
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	8b 00                	mov    (%eax),%eax
  800423:	8d 48 04             	lea    0x4(%eax),%ecx
  800426:	8b 55 08             	mov    0x8(%ebp),%edx
  800429:	89 0a                	mov    %ecx,(%edx)
  80042b:	8b 00                	mov    (%eax),%eax
  80042d:	99                   	cltd   
  80042e:	eb 10                	jmp    800440 <getint+0x45>
	else
		return va_arg(*ap, int);
  800430:	8b 45 08             	mov    0x8(%ebp),%eax
  800433:	8b 00                	mov    (%eax),%eax
  800435:	8d 48 04             	lea    0x4(%eax),%ecx
  800438:	8b 55 08             	mov    0x8(%ebp),%edx
  80043b:	89 0a                	mov    %ecx,(%edx)
  80043d:	8b 00                	mov    (%eax),%eax
  80043f:	99                   	cltd   
}
  800440:	5d                   	pop    %ebp
  800441:	c3                   	ret    

00800442 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	56                   	push   %esi
  800446:	53                   	push   %ebx
  800447:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044a:	eb 18                	jmp    800464 <vprintfmt+0x22>
			if (ch == '\0')
  80044c:	85 db                	test   %ebx,%ebx
  80044e:	75 05                	jne    800455 <vprintfmt+0x13>
				return;
  800450:	e9 05 04 00 00       	jmp    80085a <vprintfmt+0x418>
			putch(ch, putdat);
  800455:	8b 45 0c             	mov    0xc(%ebp),%eax
  800458:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045c:	89 1c 24             	mov    %ebx,(%esp)
  80045f:	8b 45 08             	mov    0x8(%ebp),%eax
  800462:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800464:	8b 45 10             	mov    0x10(%ebp),%eax
  800467:	8d 50 01             	lea    0x1(%eax),%edx
  80046a:	89 55 10             	mov    %edx,0x10(%ebp)
  80046d:	0f b6 00             	movzbl (%eax),%eax
  800470:	0f b6 d8             	movzbl %al,%ebx
  800473:	83 fb 25             	cmp    $0x25,%ebx
  800476:	75 d4                	jne    80044c <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800478:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80047c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800483:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80048a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800491:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 45 10             	mov    0x10(%ebp),%eax
  80049b:	8d 50 01             	lea    0x1(%eax),%edx
  80049e:	89 55 10             	mov    %edx,0x10(%ebp)
  8004a1:	0f b6 00             	movzbl (%eax),%eax
  8004a4:	0f b6 d8             	movzbl %al,%ebx
  8004a7:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8004aa:	83 f8 55             	cmp    $0x55,%eax
  8004ad:	0f 87 76 03 00 00    	ja     800829 <vprintfmt+0x3e7>
  8004b3:	8b 04 85 ec 16 80 00 	mov    0x8016ec(,%eax,4),%eax
  8004ba:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8004bc:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8004c0:	eb d6                	jmp    800498 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c2:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8004c6:	eb d0                	jmp    800498 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8004cf:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d2:	89 d0                	mov    %edx,%eax
  8004d4:	c1 e0 02             	shl    $0x2,%eax
  8004d7:	01 d0                	add    %edx,%eax
  8004d9:	01 c0                	add    %eax,%eax
  8004db:	01 d8                	add    %ebx,%eax
  8004dd:	83 e8 30             	sub    $0x30,%eax
  8004e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e6:	0f b6 00             	movzbl (%eax),%eax
  8004e9:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004ec:	83 fb 2f             	cmp    $0x2f,%ebx
  8004ef:	7e 0b                	jle    8004fc <vprintfmt+0xba>
  8004f1:	83 fb 39             	cmp    $0x39,%ebx
  8004f4:	7f 06                	jg     8004fc <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f6:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004fa:	eb d3                	jmp    8004cf <vprintfmt+0x8d>
			goto process_precision;
  8004fc:	eb 33                	jmp    800531 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8004fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800501:	8d 50 04             	lea    0x4(%eax),%edx
  800504:	89 55 14             	mov    %edx,0x14(%ebp)
  800507:	8b 00                	mov    (%eax),%eax
  800509:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80050c:	eb 23                	jmp    800531 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80050e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800512:	79 0c                	jns    800520 <vprintfmt+0xde>
				width = 0;
  800514:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80051b:	e9 78 ff ff ff       	jmp    800498 <vprintfmt+0x56>
  800520:	e9 73 ff ff ff       	jmp    800498 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800525:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80052c:	e9 67 ff ff ff       	jmp    800498 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800531:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800535:	79 12                	jns    800549 <vprintfmt+0x107>
				width = precision, precision = -1;
  800537:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80053d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800544:	e9 4f ff ff ff       	jmp    800498 <vprintfmt+0x56>
  800549:	e9 4a ff ff ff       	jmp    800498 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054e:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800552:	e9 41 ff ff ff       	jmp    800498 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8d 50 04             	lea    0x4(%eax),%edx
  80055d:	89 55 14             	mov    %edx,0x14(%ebp)
  800560:	8b 00                	mov    (%eax),%eax
  800562:	8b 55 0c             	mov    0xc(%ebp),%edx
  800565:	89 54 24 04          	mov    %edx,0x4(%esp)
  800569:	89 04 24             	mov    %eax,(%esp)
  80056c:	8b 45 08             	mov    0x8(%ebp),%eax
  80056f:	ff d0                	call   *%eax
			break;
  800571:	e9 de 02 00 00       	jmp    800854 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800581:	85 db                	test   %ebx,%ebx
  800583:	79 02                	jns    800587 <vprintfmt+0x145>
				err = -err;
  800585:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800587:	83 fb 09             	cmp    $0x9,%ebx
  80058a:	7f 0b                	jg     800597 <vprintfmt+0x155>
  80058c:	8b 34 9d a0 16 80 00 	mov    0x8016a0(,%ebx,4),%esi
  800593:	85 f6                	test   %esi,%esi
  800595:	75 23                	jne    8005ba <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800597:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80059b:	c7 44 24 08 d9 16 80 	movl   $0x8016d9,0x8(%esp)
  8005a2:	00 
  8005a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ad:	89 04 24             	mov    %eax,(%esp)
  8005b0:	e8 ac 02 00 00       	call   800861 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8005b5:	e9 9a 02 00 00       	jmp    800854 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005be:	c7 44 24 08 e2 16 80 	movl   $0x8016e2,0x8(%esp)
  8005c5:	00 
  8005c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d0:	89 04 24             	mov    %eax,(%esp)
  8005d3:	e8 89 02 00 00       	call   800861 <printfmt>
			break;
  8005d8:	e9 77 02 00 00       	jmp    800854 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	8b 30                	mov    (%eax),%esi
  8005e8:	85 f6                	test   %esi,%esi
  8005ea:	75 05                	jne    8005f1 <vprintfmt+0x1af>
				p = "(null)";
  8005ec:	be e5 16 80 00       	mov    $0x8016e5,%esi
			if (width > 0 && padc != '-')
  8005f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f5:	7e 37                	jle    80062e <vprintfmt+0x1ec>
  8005f7:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005fb:	74 31                	je     80062e <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800600:	89 44 24 04          	mov    %eax,0x4(%esp)
  800604:	89 34 24             	mov    %esi,(%esp)
  800607:	e8 72 03 00 00       	call   80097e <strnlen>
  80060c:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80060f:	eb 17                	jmp    800628 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800611:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800615:	8b 55 0c             	mov    0xc(%ebp),%edx
  800618:	89 54 24 04          	mov    %edx,0x4(%esp)
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	8b 45 08             	mov    0x8(%ebp),%eax
  800622:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800624:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800628:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80062c:	7f e3                	jg     800611 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062e:	eb 38                	jmp    800668 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800630:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800634:	74 1f                	je     800655 <vprintfmt+0x213>
  800636:	83 fb 1f             	cmp    $0x1f,%ebx
  800639:	7e 05                	jle    800640 <vprintfmt+0x1fe>
  80063b:	83 fb 7e             	cmp    $0x7e,%ebx
  80063e:	7e 15                	jle    800655 <vprintfmt+0x213>
					putch('?', putdat);
  800640:	8b 45 0c             	mov    0xc(%ebp),%eax
  800643:	89 44 24 04          	mov    %eax,0x4(%esp)
  800647:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80064e:	8b 45 08             	mov    0x8(%ebp),%eax
  800651:	ff d0                	call   *%eax
  800653:	eb 0f                	jmp    800664 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800655:	8b 45 0c             	mov    0xc(%ebp),%eax
  800658:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065c:	89 1c 24             	mov    %ebx,(%esp)
  80065f:	8b 45 08             	mov    0x8(%ebp),%eax
  800662:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800664:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800668:	89 f0                	mov    %esi,%eax
  80066a:	8d 70 01             	lea    0x1(%eax),%esi
  80066d:	0f b6 00             	movzbl (%eax),%eax
  800670:	0f be d8             	movsbl %al,%ebx
  800673:	85 db                	test   %ebx,%ebx
  800675:	74 10                	je     800687 <vprintfmt+0x245>
  800677:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067b:	78 b3                	js     800630 <vprintfmt+0x1ee>
  80067d:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800681:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800685:	79 a9                	jns    800630 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800687:	eb 17                	jmp    8006a0 <vprintfmt+0x25e>
				putch(' ', putdat);
  800689:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800690:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800697:	8b 45 08             	mov    0x8(%ebp),%eax
  80069a:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8006a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a4:	7f e3                	jg     800689 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8006a6:	e9 a9 01 00 00       	jmp    800854 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b5:	89 04 24             	mov    %eax,(%esp)
  8006b8:	e8 3e fd ff ff       	call   8003fb <getint>
  8006bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006c0:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006c9:	85 d2                	test   %edx,%edx
  8006cb:	79 26                	jns    8006f3 <vprintfmt+0x2b1>
				putch('-', putdat);
  8006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006db:	8b 45 08             	mov    0x8(%ebp),%eax
  8006de:	ff d0                	call   *%eax
				num = -(long long) num;
  8006e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006e6:	f7 d8                	neg    %eax
  8006e8:	83 d2 00             	adc    $0x0,%edx
  8006eb:	f7 da                	neg    %edx
  8006ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006f0:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006f3:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006fa:	e9 e1 00 00 00       	jmp    8007e0 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800702:	89 44 24 04          	mov    %eax,0x4(%esp)
  800706:	8d 45 14             	lea    0x14(%ebp),%eax
  800709:	89 04 24             	mov    %eax,(%esp)
  80070c:	e8 9b fc ff ff       	call   8003ac <getuint>
  800711:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800714:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800717:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80071e:	e9 bd 00 00 00       	jmp    8007e0 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  800723:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  80072a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80072d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800731:	8d 45 14             	lea    0x14(%ebp),%eax
  800734:	89 04 24             	mov    %eax,(%esp)
  800737:	e8 70 fc ff ff       	call   8003ac <getuint>
  80073c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80073f:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  800742:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800746:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800749:	89 54 24 18          	mov    %edx,0x18(%esp)
  80074d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800750:	89 54 24 14          	mov    %edx,0x14(%esp)
  800754:	89 44 24 10          	mov    %eax,0x10(%esp)
  800758:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80075b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800762:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800766:	8b 45 0c             	mov    0xc(%ebp),%eax
  800769:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076d:	8b 45 08             	mov    0x8(%ebp),%eax
  800770:	89 04 24             	mov    %eax,(%esp)
  800773:	e8 56 fb ff ff       	call   8002ce <printnum>
			break;
  800778:	e9 d7 00 00 00       	jmp    800854 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  80077d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800780:	89 44 24 04          	mov    %eax,0x4(%esp)
  800784:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	ff d0                	call   *%eax
			putch('x', putdat);
  800790:	8b 45 0c             	mov    0xc(%ebp),%eax
  800793:	89 44 24 04          	mov    %eax,0x4(%esp)
  800797:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8d 50 04             	lea    0x4(%eax),%edx
  8007a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ac:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007b8:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8007bf:	eb 1f                	jmp    8007e0 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007cb:	89 04 24             	mov    %eax,(%esp)
  8007ce:	e8 d9 fb ff ff       	call   8003ac <getuint>
  8007d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8007d9:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e0:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e7:	89 54 24 18          	mov    %edx,0x18(%esp)
  8007eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007ee:	89 54 24 14          	mov    %edx,0x14(%esp)
  8007f2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800800:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800804:	8b 45 0c             	mov    0xc(%ebp),%eax
  800807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	89 04 24             	mov    %eax,(%esp)
  800811:	e8 b8 fa ff ff       	call   8002ce <printnum>
			break;
  800816:	eb 3c                	jmp    800854 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800818:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081f:	89 1c 24             	mov    %ebx,(%esp)
  800822:	8b 45 08             	mov    0x8(%ebp),%eax
  800825:	ff d0                	call   *%eax
			break;
  800827:	eb 2b                	jmp    800854 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800829:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800830:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  80083c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800840:	eb 04                	jmp    800846 <vprintfmt+0x404>
  800842:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800846:	8b 45 10             	mov    0x10(%ebp),%eax
  800849:	83 e8 01             	sub    $0x1,%eax
  80084c:	0f b6 00             	movzbl (%eax),%eax
  80084f:	3c 25                	cmp    $0x25,%al
  800851:	75 ef                	jne    800842 <vprintfmt+0x400>
				/* do nothing */;
			break;
  800853:	90                   	nop
		}
	}
  800854:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800855:	e9 0a fc ff ff       	jmp    800464 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80085a:	83 c4 40             	add    $0x40,%esp
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800867:	8d 45 14             	lea    0x14(%ebp),%eax
  80086a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80086d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800870:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800874:	8b 45 10             	mov    0x10(%ebp),%eax
  800877:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	89 04 24             	mov    %eax,(%esp)
  800888:	e8 b5 fb ff ff       	call   800442 <vprintfmt>
	va_end(ap);
}
  80088d:	c9                   	leave  
  80088e:	c3                   	ret    

0080088f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800892:	8b 45 0c             	mov    0xc(%ebp),%eax
  800895:	8b 40 08             	mov    0x8(%eax),%eax
  800898:	8d 50 01             	lea    0x1(%eax),%edx
  80089b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089e:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8008a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a4:	8b 10                	mov    (%eax),%edx
  8008a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a9:	8b 40 04             	mov    0x4(%eax),%eax
  8008ac:	39 c2                	cmp    %eax,%edx
  8008ae:	73 12                	jae    8008c2 <sprintputch+0x33>
		*b->buf++ = ch;
  8008b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b3:	8b 00                	mov    (%eax),%eax
  8008b5:	8d 48 01             	lea    0x1(%eax),%ecx
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bb:	89 0a                	mov    %ecx,(%edx)
  8008bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8008c0:	88 10                	mov    %dl,(%eax)
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d3:	8d 50 ff             	lea    -0x1(%eax),%edx
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	01 d0                	add    %edx,%eax
  8008db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008e5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008e9:	74 06                	je     8008f1 <vsnprintf+0x2d>
  8008eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008ef:	7f 07                	jg     8008f8 <vsnprintf+0x34>
		return -E_INVAL;
  8008f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f6:	eb 2a                	jmp    800922 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800902:	89 44 24 08          	mov    %eax,0x8(%esp)
  800906:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800909:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090d:	c7 04 24 8f 08 80 00 	movl   $0x80088f,(%esp)
  800914:	e8 29 fb ff ff       	call   800442 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800919:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80091c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80091f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800922:	c9                   	leave  
  800923:	c3                   	ret    

00800924 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80092a:	8d 45 14             	lea    0x14(%ebp),%eax
  80092d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800930:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800933:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800937:	8b 45 10             	mov    0x10(%ebp),%eax
  80093a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800941:	89 44 24 04          	mov    %eax,0x4(%esp)
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	89 04 24             	mov    %eax,(%esp)
  80094b:	e8 74 ff ff ff       	call   8008c4 <vsnprintf>
  800950:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800953:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80095e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800965:	eb 08                	jmp    80096f <strlen+0x17>
		n++;
  800967:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80096b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	0f b6 00             	movzbl (%eax),%eax
  800975:	84 c0                	test   %al,%al
  800977:	75 ee                	jne    800967 <strlen+0xf>
		n++;
	return n;
  800979:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80097c:	c9                   	leave  
  80097d:	c3                   	ret    

0080097e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800984:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80098b:	eb 0c                	jmp    800999 <strnlen+0x1b>
		n++;
  80098d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800991:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800995:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800999:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80099d:	74 0a                	je     8009a9 <strnlen+0x2b>
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	0f b6 00             	movzbl (%eax),%eax
  8009a5:	84 c0                	test   %al,%al
  8009a7:	75 e4                	jne    80098d <strnlen+0xf>
		n++;
	return n;
  8009a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009ac:	c9                   	leave  
  8009ad:	c3                   	ret    

008009ae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8009ba:	90                   	nop
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8d 50 01             	lea    0x1(%eax),%edx
  8009c1:	89 55 08             	mov    %edx,0x8(%ebp)
  8009c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009ca:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009cd:	0f b6 12             	movzbl (%edx),%edx
  8009d0:	88 10                	mov    %dl,(%eax)
  8009d2:	0f b6 00             	movzbl (%eax),%eax
  8009d5:	84 c0                	test   %al,%al
  8009d7:	75 e2                	jne    8009bb <strcpy+0xd>
		/* do nothing */;
	return ret;
  8009d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    

008009de <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	89 04 24             	mov    %eax,(%esp)
  8009ea:	e8 69 ff ff ff       	call   800958 <strlen>
  8009ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8009f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	01 c2                	add    %eax,%edx
  8009fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a01:	89 14 24             	mov    %edx,(%esp)
  800a04:	e8 a5 ff ff ff       	call   8009ae <strcpy>
	return dst;
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    

00800a0e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800a1a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800a21:	eb 23                	jmp    800a46 <strncpy+0x38>
		*dst++ = *src;
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8d 50 01             	lea    0x1(%eax),%edx
  800a29:	89 55 08             	mov    %edx,0x8(%ebp)
  800a2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2f:	0f b6 12             	movzbl (%edx),%edx
  800a32:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a37:	0f b6 00             	movzbl (%eax),%eax
  800a3a:	84 c0                	test   %al,%al
  800a3c:	74 04                	je     800a42 <strncpy+0x34>
			src++;
  800a3e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a42:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800a46:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a49:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a4c:	72 d5                	jb     800a23 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a51:	c9                   	leave  
  800a52:	c3                   	ret    

00800a53 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a5f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a63:	74 33                	je     800a98 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a65:	eb 17                	jmp    800a7e <strlcpy+0x2b>
			*dst++ = *src++;
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6a:	8d 50 01             	lea    0x1(%eax),%edx
  800a6d:	89 55 08             	mov    %edx,0x8(%ebp)
  800a70:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a73:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a76:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a79:	0f b6 12             	movzbl (%edx),%edx
  800a7c:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a7e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a82:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a86:	74 0a                	je     800a92 <strlcpy+0x3f>
  800a88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8b:	0f b6 00             	movzbl (%eax),%eax
  800a8e:	84 c0                	test   %al,%al
  800a90:	75 d5                	jne    800a67 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a98:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a9e:	29 c2                	sub    %eax,%edx
  800aa0:	89 d0                	mov    %edx,%eax
}
  800aa2:	c9                   	leave  
  800aa3:	c3                   	ret    

00800aa4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800aa7:	eb 08                	jmp    800ab1 <strcmp+0xd>
		p++, q++;
  800aa9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800aad:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	0f b6 00             	movzbl (%eax),%eax
  800ab7:	84 c0                	test   %al,%al
  800ab9:	74 10                	je     800acb <strcmp+0x27>
  800abb:	8b 45 08             	mov    0x8(%ebp),%eax
  800abe:	0f b6 10             	movzbl (%eax),%edx
  800ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac4:	0f b6 00             	movzbl (%eax),%eax
  800ac7:	38 c2                	cmp    %al,%dl
  800ac9:	74 de                	je     800aa9 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	0f b6 00             	movzbl (%eax),%eax
  800ad1:	0f b6 d0             	movzbl %al,%edx
  800ad4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad7:	0f b6 00             	movzbl (%eax),%eax
  800ada:	0f b6 c0             	movzbl %al,%eax
  800add:	29 c2                	sub    %eax,%edx
  800adf:	89 d0                	mov    %edx,%eax
}
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800ae6:	eb 0c                	jmp    800af4 <strncmp+0x11>
		n--, p++, q++;
  800ae8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800af0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800af4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800af8:	74 1a                	je     800b14 <strncmp+0x31>
  800afa:	8b 45 08             	mov    0x8(%ebp),%eax
  800afd:	0f b6 00             	movzbl (%eax),%eax
  800b00:	84 c0                	test   %al,%al
  800b02:	74 10                	je     800b14 <strncmp+0x31>
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	0f b6 10             	movzbl (%eax),%edx
  800b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0d:	0f b6 00             	movzbl (%eax),%eax
  800b10:	38 c2                	cmp    %al,%dl
  800b12:	74 d4                	je     800ae8 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800b14:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b18:	75 07                	jne    800b21 <strncmp+0x3e>
		return 0;
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1f:	eb 16                	jmp    800b37 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b21:	8b 45 08             	mov    0x8(%ebp),%eax
  800b24:	0f b6 00             	movzbl (%eax),%eax
  800b27:	0f b6 d0             	movzbl %al,%edx
  800b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2d:	0f b6 00             	movzbl (%eax),%eax
  800b30:	0f b6 c0             	movzbl %al,%eax
  800b33:	29 c2                	sub    %eax,%edx
  800b35:	89 d0                	mov    %edx,%eax
}
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	83 ec 04             	sub    $0x4,%esp
  800b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b42:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b45:	eb 14                	jmp    800b5b <strchr+0x22>
		if (*s == c)
  800b47:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4a:	0f b6 00             	movzbl (%eax),%eax
  800b4d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b50:	75 05                	jne    800b57 <strchr+0x1e>
			return (char *) s;
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	eb 13                	jmp    800b6a <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b57:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	0f b6 00             	movzbl (%eax),%eax
  800b61:	84 c0                	test   %al,%al
  800b63:	75 e2                	jne    800b47 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 04             	sub    $0x4,%esp
  800b72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b75:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b78:	eb 11                	jmp    800b8b <strfind+0x1f>
		if (*s == c)
  800b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7d:	0f b6 00             	movzbl (%eax),%eax
  800b80:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b83:	75 02                	jne    800b87 <strfind+0x1b>
			break;
  800b85:	eb 0e                	jmp    800b95 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b87:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	0f b6 00             	movzbl (%eax),%eax
  800b91:	84 c0                	test   %al,%al
  800b93:	75 e5                	jne    800b7a <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b95:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b98:	c9                   	leave  
  800b99:	c3                   	ret    

00800b9a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b9e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ba2:	75 05                	jne    800ba9 <memset+0xf>
		return v;
  800ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba7:	eb 5c                	jmp    800c05 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	83 e0 03             	and    $0x3,%eax
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	75 41                	jne    800bf4 <memset+0x5a>
  800bb3:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb6:	83 e0 03             	and    $0x3,%eax
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	75 37                	jne    800bf4 <memset+0x5a>
		c &= 0xFF;
  800bbd:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc7:	c1 e0 18             	shl    $0x18,%eax
  800bca:	89 c2                	mov    %eax,%edx
  800bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcf:	c1 e0 10             	shl    $0x10,%eax
  800bd2:	09 c2                	or     %eax,%edx
  800bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd7:	c1 e0 08             	shl    $0x8,%eax
  800bda:	09 d0                	or     %edx,%eax
  800bdc:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bdf:	8b 45 10             	mov    0x10(%ebp),%eax
  800be2:	c1 e8 02             	shr    $0x2,%eax
  800be5:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800be7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bed:	89 d7                	mov    %edx,%edi
  800bef:	fc                   	cld    
  800bf0:	f3 ab                	rep stos %eax,%es:(%edi)
  800bf2:	eb 0e                	jmp    800c02 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bfd:	89 d7                	mov    %edx,%edi
  800bff:	fc                   	cld    
  800c00:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800c02:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800c11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c14:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800c17:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800c1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c20:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c23:	73 6d                	jae    800c92 <memmove+0x8a>
  800c25:	8b 45 10             	mov    0x10(%ebp),%eax
  800c28:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c2b:	01 d0                	add    %edx,%eax
  800c2d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c30:	76 60                	jbe    800c92 <memmove+0x8a>
		s += n;
  800c32:	8b 45 10             	mov    0x10(%ebp),%eax
  800c35:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800c38:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3b:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c41:	83 e0 03             	and    $0x3,%eax
  800c44:	85 c0                	test   %eax,%eax
  800c46:	75 2f                	jne    800c77 <memmove+0x6f>
  800c48:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c4b:	83 e0 03             	and    $0x3,%eax
  800c4e:	85 c0                	test   %eax,%eax
  800c50:	75 25                	jne    800c77 <memmove+0x6f>
  800c52:	8b 45 10             	mov    0x10(%ebp),%eax
  800c55:	83 e0 03             	and    $0x3,%eax
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	75 1b                	jne    800c77 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c5f:	83 e8 04             	sub    $0x4,%eax
  800c62:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c65:	83 ea 04             	sub    $0x4,%edx
  800c68:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c6b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c6e:	89 c7                	mov    %eax,%edi
  800c70:	89 d6                	mov    %edx,%esi
  800c72:	fd                   	std    
  800c73:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c75:	eb 18                	jmp    800c8f <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c77:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c7a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c80:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c83:	8b 45 10             	mov    0x10(%ebp),%eax
  800c86:	89 d7                	mov    %edx,%edi
  800c88:	89 de                	mov    %ebx,%esi
  800c8a:	89 c1                	mov    %eax,%ecx
  800c8c:	fd                   	std    
  800c8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c8f:	fc                   	cld    
  800c90:	eb 45                	jmp    800cd7 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c95:	83 e0 03             	and    $0x3,%eax
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	75 2b                	jne    800cc7 <memmove+0xbf>
  800c9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c9f:	83 e0 03             	and    $0x3,%eax
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	75 21                	jne    800cc7 <memmove+0xbf>
  800ca6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca9:	83 e0 03             	and    $0x3,%eax
  800cac:	85 c0                	test   %eax,%eax
  800cae:	75 17                	jne    800cc7 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cb0:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb3:	c1 e8 02             	shr    $0x2,%eax
  800cb6:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cbb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cbe:	89 c7                	mov    %eax,%edi
  800cc0:	89 d6                	mov    %edx,%esi
  800cc2:	fc                   	cld    
  800cc3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cc5:	eb 10                	jmp    800cd7 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ccd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cd0:	89 c7                	mov    %eax,%edi
  800cd2:	89 d6                	mov    %edx,%esi
  800cd4:	fc                   	cld    
  800cd5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800cd7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cda:	83 c4 10             	add    $0x10,%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ce8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ceb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf9:	89 04 24             	mov    %eax,(%esp)
  800cfc:	e8 07 ff ff ff       	call   800c08 <memmove>
}
  800d01:	c9                   	leave  
  800d02:	c3                   	ret    

00800d03 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800d09:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800d0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d12:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800d15:	eb 30                	jmp    800d47 <memcmp+0x44>
		if (*s1 != *s2)
  800d17:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d1a:	0f b6 10             	movzbl (%eax),%edx
  800d1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d20:	0f b6 00             	movzbl (%eax),%eax
  800d23:	38 c2                	cmp    %al,%dl
  800d25:	74 18                	je     800d3f <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800d27:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d2a:	0f b6 00             	movzbl (%eax),%eax
  800d2d:	0f b6 d0             	movzbl %al,%edx
  800d30:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d33:	0f b6 00             	movzbl (%eax),%eax
  800d36:	0f b6 c0             	movzbl %al,%eax
  800d39:	29 c2                	sub    %eax,%edx
  800d3b:	89 d0                	mov    %edx,%eax
  800d3d:	eb 1a                	jmp    800d59 <memcmp+0x56>
		s1++, s2++;
  800d3f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d43:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d47:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800d4d:	89 55 10             	mov    %edx,0x10(%ebp)
  800d50:	85 c0                	test   %eax,%eax
  800d52:	75 c3                	jne    800d17 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d59:	c9                   	leave  
  800d5a:	c3                   	ret    

00800d5b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d61:	8b 45 10             	mov    0x10(%ebp),%eax
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	01 d0                	add    %edx,%eax
  800d69:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d6c:	eb 13                	jmp    800d81 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d71:	0f b6 10             	movzbl (%eax),%edx
  800d74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d77:	38 c2                	cmp    %al,%dl
  800d79:	75 02                	jne    800d7d <memfind+0x22>
			break;
  800d7b:	eb 0c                	jmp    800d89 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d7d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d87:	72 e5                	jb     800d6e <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d8c:	c9                   	leave  
  800d8d:	c3                   	ret    

00800d8e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d94:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d9b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800da2:	eb 04                	jmp    800da8 <strtol+0x1a>
		s++;
  800da4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800da8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dab:	0f b6 00             	movzbl (%eax),%eax
  800dae:	3c 20                	cmp    $0x20,%al
  800db0:	74 f2                	je     800da4 <strtol+0x16>
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
  800db5:	0f b6 00             	movzbl (%eax),%eax
  800db8:	3c 09                	cmp    $0x9,%al
  800dba:	74 e8                	je     800da4 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbf:	0f b6 00             	movzbl (%eax),%eax
  800dc2:	3c 2b                	cmp    $0x2b,%al
  800dc4:	75 06                	jne    800dcc <strtol+0x3e>
		s++;
  800dc6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dca:	eb 15                	jmp    800de1 <strtol+0x53>
	else if (*s == '-')
  800dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcf:	0f b6 00             	movzbl (%eax),%eax
  800dd2:	3c 2d                	cmp    $0x2d,%al
  800dd4:	75 0b                	jne    800de1 <strtol+0x53>
		s++, neg = 1;
  800dd6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dda:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800de5:	74 06                	je     800ded <strtol+0x5f>
  800de7:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800deb:	75 24                	jne    800e11 <strtol+0x83>
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
  800df0:	0f b6 00             	movzbl (%eax),%eax
  800df3:	3c 30                	cmp    $0x30,%al
  800df5:	75 1a                	jne    800e11 <strtol+0x83>
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfa:	83 c0 01             	add    $0x1,%eax
  800dfd:	0f b6 00             	movzbl (%eax),%eax
  800e00:	3c 78                	cmp    $0x78,%al
  800e02:	75 0d                	jne    800e11 <strtol+0x83>
		s += 2, base = 16;
  800e04:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800e08:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800e0f:	eb 2a                	jmp    800e3b <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800e11:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e15:	75 17                	jne    800e2e <strtol+0xa0>
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	0f b6 00             	movzbl (%eax),%eax
  800e1d:	3c 30                	cmp    $0x30,%al
  800e1f:	75 0d                	jne    800e2e <strtol+0xa0>
		s++, base = 8;
  800e21:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e25:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800e2c:	eb 0d                	jmp    800e3b <strtol+0xad>
	else if (base == 0)
  800e2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e32:	75 07                	jne    800e3b <strtol+0xad>
		base = 10;
  800e34:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3e:	0f b6 00             	movzbl (%eax),%eax
  800e41:	3c 2f                	cmp    $0x2f,%al
  800e43:	7e 1b                	jle    800e60 <strtol+0xd2>
  800e45:	8b 45 08             	mov    0x8(%ebp),%eax
  800e48:	0f b6 00             	movzbl (%eax),%eax
  800e4b:	3c 39                	cmp    $0x39,%al
  800e4d:	7f 11                	jg     800e60 <strtol+0xd2>
			dig = *s - '0';
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e52:	0f b6 00             	movzbl (%eax),%eax
  800e55:	0f be c0             	movsbl %al,%eax
  800e58:	83 e8 30             	sub    $0x30,%eax
  800e5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e5e:	eb 48                	jmp    800ea8 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e60:	8b 45 08             	mov    0x8(%ebp),%eax
  800e63:	0f b6 00             	movzbl (%eax),%eax
  800e66:	3c 60                	cmp    $0x60,%al
  800e68:	7e 1b                	jle    800e85 <strtol+0xf7>
  800e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6d:	0f b6 00             	movzbl (%eax),%eax
  800e70:	3c 7a                	cmp    $0x7a,%al
  800e72:	7f 11                	jg     800e85 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e74:	8b 45 08             	mov    0x8(%ebp),%eax
  800e77:	0f b6 00             	movzbl (%eax),%eax
  800e7a:	0f be c0             	movsbl %al,%eax
  800e7d:	83 e8 57             	sub    $0x57,%eax
  800e80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e83:	eb 23                	jmp    800ea8 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e85:	8b 45 08             	mov    0x8(%ebp),%eax
  800e88:	0f b6 00             	movzbl (%eax),%eax
  800e8b:	3c 40                	cmp    $0x40,%al
  800e8d:	7e 3d                	jle    800ecc <strtol+0x13e>
  800e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e92:	0f b6 00             	movzbl (%eax),%eax
  800e95:	3c 5a                	cmp    $0x5a,%al
  800e97:	7f 33                	jg     800ecc <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9c:	0f b6 00             	movzbl (%eax),%eax
  800e9f:	0f be c0             	movsbl %al,%eax
  800ea2:	83 e8 37             	sub    $0x37,%eax
  800ea5:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eab:	3b 45 10             	cmp    0x10(%ebp),%eax
  800eae:	7c 02                	jl     800eb2 <strtol+0x124>
			break;
  800eb0:	eb 1a                	jmp    800ecc <strtol+0x13e>
		s++, val = (val * base) + dig;
  800eb2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800eb6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800eb9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ebd:	89 c2                	mov    %eax,%edx
  800ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec2:	01 d0                	add    %edx,%eax
  800ec4:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800ec7:	e9 6f ff ff ff       	jmp    800e3b <strtol+0xad>

	if (endptr)
  800ecc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ed0:	74 08                	je     800eda <strtol+0x14c>
		*endptr = (char *) s;
  800ed2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800eda:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800ede:	74 07                	je     800ee7 <strtol+0x159>
  800ee0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ee3:	f7 d8                	neg    %eax
  800ee5:	eb 03                	jmp    800eea <strtol+0x15c>
  800ee7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800eea:	c9                   	leave  
  800eeb:	c3                   	ret    

00800eec <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	57                   	push   %edi
  800ef0:	56                   	push   %esi
  800ef1:	53                   	push   %ebx
  800ef2:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef8:	8b 55 10             	mov    0x10(%ebp),%edx
  800efb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800efe:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800f01:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800f04:	8b 75 20             	mov    0x20(%ebp),%esi
  800f07:	cd 30                	int    $0x30
  800f09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f10:	74 30                	je     800f42 <syscall+0x56>
  800f12:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f16:	7e 2a                	jle    800f42 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f22:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f26:	c7 44 24 08 44 18 80 	movl   $0x801844,0x8(%esp)
  800f2d:	00 
  800f2e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f35:	00 
  800f36:	c7 04 24 61 18 80 00 	movl   $0x801861,(%esp)
  800f3d:	e8 4b f2 ff ff       	call   80018d <_panic>

	return ret;
  800f42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800f45:	83 c4 3c             	add    $0x3c,%esp
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f53:	8b 45 08             	mov    0x8(%ebp),%eax
  800f56:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f5d:	00 
  800f5e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f65:	00 
  800f66:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f6d:	00 
  800f6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f71:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f79:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f80:	00 
  800f81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f88:	e8 5f ff ff ff       	call   800eec <syscall>
}
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    

00800f8f <sys_cgetc>:

int
sys_cgetc(void)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f95:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f9c:	00 
  800f9d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fa4:	00 
  800fa5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fac:	00 
  800fad:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fb4:	00 
  800fb5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fbc:	00 
  800fbd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fc4:	00 
  800fc5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800fcc:	e8 1b ff ff ff       	call   800eec <syscall>
}
  800fd1:	c9                   	leave  
  800fd2:	c3                   	ret    

00800fd3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fe3:	00 
  800fe4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800feb:	00 
  800fec:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ffb:	00 
  800ffc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801000:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801007:	00 
  801008:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  80100f:	e8 d8 fe ff ff       	call   800eec <syscall>
}
  801014:	c9                   	leave  
  801015:	c3                   	ret    

00801016 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80101c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801023:	00 
  801024:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80102b:	00 
  80102c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801033:	00 
  801034:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80103b:	00 
  80103c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801043:	00 
  801044:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80104b:	00 
  80104c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801053:	e8 94 fe ff ff       	call   800eec <syscall>
}
  801058:	c9                   	leave  
  801059:	c3                   	ret    

0080105a <sys_yield>:

void
sys_yield(void)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801060:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801067:	00 
  801068:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80106f:	00 
  801070:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801077:	00 
  801078:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80107f:	00 
  801080:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801087:	00 
  801088:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80108f:	00 
  801090:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801097:	e8 50 fe ff ff       	call   800eec <syscall>
}
  80109c:	c9                   	leave  
  80109d:	c3                   	ret    

0080109e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8010a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ad:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010b4:	00 
  8010b5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010bc:	00 
  8010bd:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010c1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010d0:	00 
  8010d1:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8010d8:	e8 0f fe ff ff       	call   800eec <syscall>
}
  8010dd:	c9                   	leave  
  8010de:	c3                   	ret    

008010df <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	56                   	push   %esi
  8010e3:	53                   	push   %ebx
  8010e4:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8010e7:	8b 75 18             	mov    0x18(%ebp),%esi
  8010ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f6:	89 74 24 18          	mov    %esi,0x18(%esp)
  8010fa:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8010fe:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801102:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801106:	89 44 24 08          	mov    %eax,0x8(%esp)
  80110a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801111:	00 
  801112:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801119:	e8 ce fd ff ff       	call   800eec <syscall>
}
  80111e:	83 c4 20             	add    $0x20,%esp
  801121:	5b                   	pop    %ebx
  801122:	5e                   	pop    %esi
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    

00801125 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80112b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112e:	8b 45 08             	mov    0x8(%ebp),%eax
  801131:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801138:	00 
  801139:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801140:	00 
  801141:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801148:	00 
  801149:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80114d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801151:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801158:	00 
  801159:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801160:	e8 87 fd ff ff       	call   800eec <syscall>
}
  801165:	c9                   	leave  
  801166:	c3                   	ret    

00801167 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80116d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801170:	8b 45 08             	mov    0x8(%ebp),%eax
  801173:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80117a:	00 
  80117b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801182:	00 
  801183:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80118a:	00 
  80118b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80118f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801193:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80119a:	00 
  80119b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8011a2:	e8 45 fd ff ff       	call   800eec <syscall>
}
  8011a7:	c9                   	leave  
  8011a8:	c3                   	ret    

008011a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8011af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011bc:	00 
  8011bd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011c4:	00 
  8011c5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011cc:	00 
  8011cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011dc:	00 
  8011dd:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8011e4:	e8 03 fd ff ff       	call   800eec <syscall>
}
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    

008011eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8011f1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8011f4:	8b 55 10             	mov    0x10(%ebp),%edx
  8011f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fa:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801201:	00 
  801202:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801206:	89 54 24 10          	mov    %edx,0x10(%esp)
  80120a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801211:	89 44 24 08          	mov    %eax,0x8(%esp)
  801215:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80121c:	00 
  80121d:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801224:	e8 c3 fc ff ff       	call   800eec <syscall>
}
  801229:	c9                   	leave  
  80122a:	c3                   	ret    

0080122b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801231:	8b 45 08             	mov    0x8(%ebp),%eax
  801234:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80123b:	00 
  80123c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801243:	00 
  801244:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80124b:	00 
  80124c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801253:	00 
  801254:	89 44 24 08          	mov    %eax,0x8(%esp)
  801258:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80125f:	00 
  801260:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801267:	e8 80 fc ff ff       	call   800eec <syscall>
}
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    
  80126e:	66 90                	xchg   %ax,%ax

00801270 <__udivdi3>:
  801270:	55                   	push   %ebp
  801271:	57                   	push   %edi
  801272:	56                   	push   %esi
  801273:	83 ec 0c             	sub    $0xc,%esp
  801276:	8b 44 24 28          	mov    0x28(%esp),%eax
  80127a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80127e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801282:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801286:	85 c0                	test   %eax,%eax
  801288:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80128c:	89 ea                	mov    %ebp,%edx
  80128e:	89 0c 24             	mov    %ecx,(%esp)
  801291:	75 2d                	jne    8012c0 <__udivdi3+0x50>
  801293:	39 e9                	cmp    %ebp,%ecx
  801295:	77 61                	ja     8012f8 <__udivdi3+0x88>
  801297:	85 c9                	test   %ecx,%ecx
  801299:	89 ce                	mov    %ecx,%esi
  80129b:	75 0b                	jne    8012a8 <__udivdi3+0x38>
  80129d:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a2:	31 d2                	xor    %edx,%edx
  8012a4:	f7 f1                	div    %ecx
  8012a6:	89 c6                	mov    %eax,%esi
  8012a8:	31 d2                	xor    %edx,%edx
  8012aa:	89 e8                	mov    %ebp,%eax
  8012ac:	f7 f6                	div    %esi
  8012ae:	89 c5                	mov    %eax,%ebp
  8012b0:	89 f8                	mov    %edi,%eax
  8012b2:	f7 f6                	div    %esi
  8012b4:	89 ea                	mov    %ebp,%edx
  8012b6:	83 c4 0c             	add    $0xc,%esp
  8012b9:	5e                   	pop    %esi
  8012ba:	5f                   	pop    %edi
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    
  8012bd:	8d 76 00             	lea    0x0(%esi),%esi
  8012c0:	39 e8                	cmp    %ebp,%eax
  8012c2:	77 24                	ja     8012e8 <__udivdi3+0x78>
  8012c4:	0f bd e8             	bsr    %eax,%ebp
  8012c7:	83 f5 1f             	xor    $0x1f,%ebp
  8012ca:	75 3c                	jne    801308 <__udivdi3+0x98>
  8012cc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012d0:	39 34 24             	cmp    %esi,(%esp)
  8012d3:	0f 86 9f 00 00 00    	jbe    801378 <__udivdi3+0x108>
  8012d9:	39 d0                	cmp    %edx,%eax
  8012db:	0f 82 97 00 00 00    	jb     801378 <__udivdi3+0x108>
  8012e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012e8:	31 d2                	xor    %edx,%edx
  8012ea:	31 c0                	xor    %eax,%eax
  8012ec:	83 c4 0c             	add    $0xc,%esp
  8012ef:	5e                   	pop    %esi
  8012f0:	5f                   	pop    %edi
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    
  8012f3:	90                   	nop
  8012f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	89 f8                	mov    %edi,%eax
  8012fa:	f7 f1                	div    %ecx
  8012fc:	31 d2                	xor    %edx,%edx
  8012fe:	83 c4 0c             	add    $0xc,%esp
  801301:	5e                   	pop    %esi
  801302:	5f                   	pop    %edi
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    
  801305:	8d 76 00             	lea    0x0(%esi),%esi
  801308:	89 e9                	mov    %ebp,%ecx
  80130a:	8b 3c 24             	mov    (%esp),%edi
  80130d:	d3 e0                	shl    %cl,%eax
  80130f:	89 c6                	mov    %eax,%esi
  801311:	b8 20 00 00 00       	mov    $0x20,%eax
  801316:	29 e8                	sub    %ebp,%eax
  801318:	89 c1                	mov    %eax,%ecx
  80131a:	d3 ef                	shr    %cl,%edi
  80131c:	89 e9                	mov    %ebp,%ecx
  80131e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801322:	8b 3c 24             	mov    (%esp),%edi
  801325:	09 74 24 08          	or     %esi,0x8(%esp)
  801329:	89 d6                	mov    %edx,%esi
  80132b:	d3 e7                	shl    %cl,%edi
  80132d:	89 c1                	mov    %eax,%ecx
  80132f:	89 3c 24             	mov    %edi,(%esp)
  801332:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801336:	d3 ee                	shr    %cl,%esi
  801338:	89 e9                	mov    %ebp,%ecx
  80133a:	d3 e2                	shl    %cl,%edx
  80133c:	89 c1                	mov    %eax,%ecx
  80133e:	d3 ef                	shr    %cl,%edi
  801340:	09 d7                	or     %edx,%edi
  801342:	89 f2                	mov    %esi,%edx
  801344:	89 f8                	mov    %edi,%eax
  801346:	f7 74 24 08          	divl   0x8(%esp)
  80134a:	89 d6                	mov    %edx,%esi
  80134c:	89 c7                	mov    %eax,%edi
  80134e:	f7 24 24             	mull   (%esp)
  801351:	39 d6                	cmp    %edx,%esi
  801353:	89 14 24             	mov    %edx,(%esp)
  801356:	72 30                	jb     801388 <__udivdi3+0x118>
  801358:	8b 54 24 04          	mov    0x4(%esp),%edx
  80135c:	89 e9                	mov    %ebp,%ecx
  80135e:	d3 e2                	shl    %cl,%edx
  801360:	39 c2                	cmp    %eax,%edx
  801362:	73 05                	jae    801369 <__udivdi3+0xf9>
  801364:	3b 34 24             	cmp    (%esp),%esi
  801367:	74 1f                	je     801388 <__udivdi3+0x118>
  801369:	89 f8                	mov    %edi,%eax
  80136b:	31 d2                	xor    %edx,%edx
  80136d:	e9 7a ff ff ff       	jmp    8012ec <__udivdi3+0x7c>
  801372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801378:	31 d2                	xor    %edx,%edx
  80137a:	b8 01 00 00 00       	mov    $0x1,%eax
  80137f:	e9 68 ff ff ff       	jmp    8012ec <__udivdi3+0x7c>
  801384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801388:	8d 47 ff             	lea    -0x1(%edi),%eax
  80138b:	31 d2                	xor    %edx,%edx
  80138d:	83 c4 0c             	add    $0xc,%esp
  801390:	5e                   	pop    %esi
  801391:	5f                   	pop    %edi
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    
  801394:	66 90                	xchg   %ax,%ax
  801396:	66 90                	xchg   %ax,%ax
  801398:	66 90                	xchg   %ax,%ax
  80139a:	66 90                	xchg   %ax,%ax
  80139c:	66 90                	xchg   %ax,%ax
  80139e:	66 90                	xchg   %ax,%ax

008013a0 <__umoddi3>:
  8013a0:	55                   	push   %ebp
  8013a1:	57                   	push   %edi
  8013a2:	56                   	push   %esi
  8013a3:	83 ec 14             	sub    $0x14,%esp
  8013a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013aa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013ae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8013b2:	89 c7                	mov    %eax,%edi
  8013b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8013bc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8013c0:	89 34 24             	mov    %esi,(%esp)
  8013c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	89 c2                	mov    %eax,%edx
  8013cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013cf:	75 17                	jne    8013e8 <__umoddi3+0x48>
  8013d1:	39 fe                	cmp    %edi,%esi
  8013d3:	76 4b                	jbe    801420 <__umoddi3+0x80>
  8013d5:	89 c8                	mov    %ecx,%eax
  8013d7:	89 fa                	mov    %edi,%edx
  8013d9:	f7 f6                	div    %esi
  8013db:	89 d0                	mov    %edx,%eax
  8013dd:	31 d2                	xor    %edx,%edx
  8013df:	83 c4 14             	add    $0x14,%esp
  8013e2:	5e                   	pop    %esi
  8013e3:	5f                   	pop    %edi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    
  8013e6:	66 90                	xchg   %ax,%ax
  8013e8:	39 f8                	cmp    %edi,%eax
  8013ea:	77 54                	ja     801440 <__umoddi3+0xa0>
  8013ec:	0f bd e8             	bsr    %eax,%ebp
  8013ef:	83 f5 1f             	xor    $0x1f,%ebp
  8013f2:	75 5c                	jne    801450 <__umoddi3+0xb0>
  8013f4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8013f8:	39 3c 24             	cmp    %edi,(%esp)
  8013fb:	0f 87 e7 00 00 00    	ja     8014e8 <__umoddi3+0x148>
  801401:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801405:	29 f1                	sub    %esi,%ecx
  801407:	19 c7                	sbb    %eax,%edi
  801409:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80140d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801411:	8b 44 24 08          	mov    0x8(%esp),%eax
  801415:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801419:	83 c4 14             	add    $0x14,%esp
  80141c:	5e                   	pop    %esi
  80141d:	5f                   	pop    %edi
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    
  801420:	85 f6                	test   %esi,%esi
  801422:	89 f5                	mov    %esi,%ebp
  801424:	75 0b                	jne    801431 <__umoddi3+0x91>
  801426:	b8 01 00 00 00       	mov    $0x1,%eax
  80142b:	31 d2                	xor    %edx,%edx
  80142d:	f7 f6                	div    %esi
  80142f:	89 c5                	mov    %eax,%ebp
  801431:	8b 44 24 04          	mov    0x4(%esp),%eax
  801435:	31 d2                	xor    %edx,%edx
  801437:	f7 f5                	div    %ebp
  801439:	89 c8                	mov    %ecx,%eax
  80143b:	f7 f5                	div    %ebp
  80143d:	eb 9c                	jmp    8013db <__umoddi3+0x3b>
  80143f:	90                   	nop
  801440:	89 c8                	mov    %ecx,%eax
  801442:	89 fa                	mov    %edi,%edx
  801444:	83 c4 14             	add    $0x14,%esp
  801447:	5e                   	pop    %esi
  801448:	5f                   	pop    %edi
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    
  80144b:	90                   	nop
  80144c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801450:	8b 04 24             	mov    (%esp),%eax
  801453:	be 20 00 00 00       	mov    $0x20,%esi
  801458:	89 e9                	mov    %ebp,%ecx
  80145a:	29 ee                	sub    %ebp,%esi
  80145c:	d3 e2                	shl    %cl,%edx
  80145e:	89 f1                	mov    %esi,%ecx
  801460:	d3 e8                	shr    %cl,%eax
  801462:	89 e9                	mov    %ebp,%ecx
  801464:	89 44 24 04          	mov    %eax,0x4(%esp)
  801468:	8b 04 24             	mov    (%esp),%eax
  80146b:	09 54 24 04          	or     %edx,0x4(%esp)
  80146f:	89 fa                	mov    %edi,%edx
  801471:	d3 e0                	shl    %cl,%eax
  801473:	89 f1                	mov    %esi,%ecx
  801475:	89 44 24 08          	mov    %eax,0x8(%esp)
  801479:	8b 44 24 10          	mov    0x10(%esp),%eax
  80147d:	d3 ea                	shr    %cl,%edx
  80147f:	89 e9                	mov    %ebp,%ecx
  801481:	d3 e7                	shl    %cl,%edi
  801483:	89 f1                	mov    %esi,%ecx
  801485:	d3 e8                	shr    %cl,%eax
  801487:	89 e9                	mov    %ebp,%ecx
  801489:	09 f8                	or     %edi,%eax
  80148b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80148f:	f7 74 24 04          	divl   0x4(%esp)
  801493:	d3 e7                	shl    %cl,%edi
  801495:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801499:	89 d7                	mov    %edx,%edi
  80149b:	f7 64 24 08          	mull   0x8(%esp)
  80149f:	39 d7                	cmp    %edx,%edi
  8014a1:	89 c1                	mov    %eax,%ecx
  8014a3:	89 14 24             	mov    %edx,(%esp)
  8014a6:	72 2c                	jb     8014d4 <__umoddi3+0x134>
  8014a8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8014ac:	72 22                	jb     8014d0 <__umoddi3+0x130>
  8014ae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014b2:	29 c8                	sub    %ecx,%eax
  8014b4:	19 d7                	sbb    %edx,%edi
  8014b6:	89 e9                	mov    %ebp,%ecx
  8014b8:	89 fa                	mov    %edi,%edx
  8014ba:	d3 e8                	shr    %cl,%eax
  8014bc:	89 f1                	mov    %esi,%ecx
  8014be:	d3 e2                	shl    %cl,%edx
  8014c0:	89 e9                	mov    %ebp,%ecx
  8014c2:	d3 ef                	shr    %cl,%edi
  8014c4:	09 d0                	or     %edx,%eax
  8014c6:	89 fa                	mov    %edi,%edx
  8014c8:	83 c4 14             	add    $0x14,%esp
  8014cb:	5e                   	pop    %esi
  8014cc:	5f                   	pop    %edi
  8014cd:	5d                   	pop    %ebp
  8014ce:	c3                   	ret    
  8014cf:	90                   	nop
  8014d0:	39 d7                	cmp    %edx,%edi
  8014d2:	75 da                	jne    8014ae <__umoddi3+0x10e>
  8014d4:	8b 14 24             	mov    (%esp),%edx
  8014d7:	89 c1                	mov    %eax,%ecx
  8014d9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8014dd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8014e1:	eb cb                	jmp    8014ae <__umoddi3+0x10e>
  8014e3:	90                   	nop
  8014e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8014ec:	0f 82 0f ff ff ff    	jb     801401 <__umoddi3+0x61>
  8014f2:	e9 1a ff ff ff       	jmp    801411 <__umoddi3+0x71>
