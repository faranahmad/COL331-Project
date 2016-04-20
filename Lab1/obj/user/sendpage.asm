
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 bb 01 00 00       	call   8001ec <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 27 15 00 00       	call   801565 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800044:	85 c0                	test   %eax,%eax
  800046:	0f 85 c1 00 00 00    	jne    80010d <umain+0xda>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  80004c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800053:	00 
  800054:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  80005b:	00 
  80005c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005f:	89 04 24             	mov    %eax,(%esp)
  800062:	e8 c0 16 00 00       	call   801727 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800067:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006a:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  800071:	00 
  800072:	89 44 24 04          	mov    %eax,0x4(%esp)
  800076:	c7 04 24 ec 1c 80 00 	movl   $0x801cec,(%esp)
  80007d:	e8 8c 02 00 00       	call   80030e <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800082:	a1 00 30 80 00       	mov    0x803000,%eax
  800087:	89 04 24             	mov    %eax,(%esp)
  80008a:	e8 2f 09 00 00       	call   8009be <strlen>
  80008f:	89 c2                	mov    %eax,%edx
  800091:	a1 00 30 80 00       	mov    0x803000,%eax
  800096:	89 54 24 08          	mov    %edx,0x8(%esp)
  80009a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009e:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a5:	e8 9f 0a 00 00       	call   800b49 <strncmp>
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	75 0c                	jne    8000ba <umain+0x87>
			cprintf("child received correct message\n");
  8000ae:	c7 04 24 00 1d 80 00 	movl   $0x801d00,(%esp)
  8000b5:	e8 54 02 00 00       	call   80030e <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000ba:	a1 04 30 80 00       	mov    0x803004,%eax
  8000bf:	89 04 24             	mov    %eax,(%esp)
  8000c2:	e8 f7 08 00 00       	call   8009be <strlen>
  8000c7:	83 c0 01             	add    $0x1,%eax
  8000ca:	89 c2                	mov    %eax,%edx
  8000cc:	a1 04 30 80 00       	mov    0x803004,%eax
  8000d1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d9:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000e0:	e8 63 0c 00 00       	call   800d48 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000e8:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000ef:	00 
  8000f0:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000f7:	00 
  8000f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ff:	00 
  800100:	89 04 24             	mov    %eax,(%esp)
  800103:	e8 bb 16 00 00       	call   8017c3 <ipc_send>
		return;
  800108:	e9 dd 00 00 00       	jmp    8001ea <umain+0x1b7>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80010d:	a1 0c 30 80 00       	mov    0x80300c,%eax
  800112:	8b 40 48             	mov    0x48(%eax),%eax
  800115:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80011c:	00 
  80011d:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  800124:	00 
  800125:	89 04 24             	mov    %eax,(%esp)
  800128:	e8 d7 0f 00 00       	call   801104 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  80012d:	a1 00 30 80 00       	mov    0x803000,%eax
  800132:	89 04 24             	mov    %eax,(%esp)
  800135:	e8 84 08 00 00       	call   8009be <strlen>
  80013a:	83 c0 01             	add    $0x1,%eax
  80013d:	89 c2                	mov    %eax,%edx
  80013f:	a1 00 30 80 00       	mov    0x803000,%eax
  800144:	89 54 24 08          	mov    %edx,0x8(%esp)
  800148:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014c:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800153:	e8 f0 0b 00 00       	call   800d48 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800158:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80015b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800162:	00 
  800163:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80016a:	00 
  80016b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800172:	00 
  800173:	89 04 24             	mov    %eax,(%esp)
  800176:	e8 48 16 00 00       	call   8017c3 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80017b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800182:	00 
  800183:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80018a:	00 
  80018b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80018e:	89 04 24             	mov    %eax,(%esp)
  800191:	e8 91 15 00 00       	call   801727 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800196:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800199:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  8001a0:	00 
  8001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a5:	c7 04 24 ec 1c 80 00 	movl   $0x801cec,(%esp)
  8001ac:	e8 5d 01 00 00       	call   80030e <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001b1:	a1 04 30 80 00       	mov    0x803004,%eax
  8001b6:	89 04 24             	mov    %eax,(%esp)
  8001b9:	e8 00 08 00 00       	call   8009be <strlen>
  8001be:	89 c2                	mov    %eax,%edx
  8001c0:	a1 04 30 80 00       	mov    0x803004,%eax
  8001c5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cd:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001d4:	e8 70 09 00 00       	call   800b49 <strncmp>
  8001d9:	85 c0                	test   %eax,%eax
  8001db:	75 0c                	jne    8001e9 <umain+0x1b6>
		cprintf("parent received correct message\n");
  8001dd:	c7 04 24 20 1d 80 00 	movl   $0x801d20,(%esp)
  8001e4:	e8 25 01 00 00       	call   80030e <cprintf>
	return;
  8001e9:	90                   	nop
}
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8001f2:	e8 85 0e 00 00       	call   80107c <sys_getenvid>
  8001f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001fc:	c1 e0 02             	shl    $0x2,%eax
  8001ff:	89 c2                	mov    %eax,%edx
  800201:	c1 e2 05             	shl    $0x5,%edx
  800204:	29 c2                	sub    %eax,%edx
  800206:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80020c:	a3 0c 30 80 00       	mov    %eax,0x80300c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800211:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800215:	7e 0a                	jle    800221 <libmain+0x35>
		binaryname = argv[0];
  800217:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021a:	8b 00                	mov    (%eax),%eax
  80021c:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  800221:	8b 45 0c             	mov    0xc(%ebp),%eax
  800224:	89 44 24 04          	mov    %eax,0x4(%esp)
  800228:	8b 45 08             	mov    0x8(%ebp),%eax
  80022b:	89 04 24             	mov    %eax,(%esp)
  80022e:	e8 00 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800233:	e8 02 00 00 00       	call   80023a <exit>
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800247:	e8 ed 0d 00 00       	call   801039 <sys_env_destroy>
}
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800254:	8b 45 0c             	mov    0xc(%ebp),%eax
  800257:	8b 00                	mov    (%eax),%eax
  800259:	8d 48 01             	lea    0x1(%eax),%ecx
  80025c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025f:	89 0a                	mov    %ecx,(%edx)
  800261:	8b 55 08             	mov    0x8(%ebp),%edx
  800264:	89 d1                	mov    %edx,%ecx
  800266:	8b 55 0c             	mov    0xc(%ebp),%edx
  800269:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  80026d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800270:	8b 00                	mov    (%eax),%eax
  800272:	3d ff 00 00 00       	cmp    $0xff,%eax
  800277:	75 20                	jne    800299 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800279:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027c:	8b 00                	mov    (%eax),%eax
  80027e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800281:	83 c2 08             	add    $0x8,%edx
  800284:	89 44 24 04          	mov    %eax,0x4(%esp)
  800288:	89 14 24             	mov    %edx,(%esp)
  80028b:	e8 23 0d 00 00       	call   800fb3 <sys_cputs>
		b->idx = 0;
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
  800293:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800299:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029c:	8b 40 04             	mov    0x4(%eax),%eax
  80029f:	8d 50 01             	lea    0x1(%eax),%edx
  8002a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a5:	89 50 04             	mov    %edx,0x4(%eax)
}
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ba:	00 00 00 
	b.cnt = 0;
  8002bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002c4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002df:	c7 04 24 4e 02 80 00 	movl   $0x80024e,(%esp)
  8002e6:	e8 bd 01 00 00       	call   8004a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002eb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002fb:	83 c0 08             	add    $0x8,%eax
  8002fe:	89 04 24             	mov    %eax,(%esp)
  800301:	e8 ad 0c 00 00       	call   800fb3 <sys_cputs>

	return b.cnt;
  800306:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80030c:	c9                   	leave  
  80030d:	c3                   	ret    

0080030e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800314:	8d 45 0c             	lea    0xc(%ebp),%eax
  800317:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80031a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80031d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800321:	8b 45 08             	mov    0x8(%ebp),%eax
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	e8 7e ff ff ff       	call   8002aa <vcprintf>
  80032c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80032f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800332:	c9                   	leave  
  800333:	c3                   	ret    

00800334 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	53                   	push   %ebx
  800338:	83 ec 34             	sub    $0x34,%esp
  80033b:	8b 45 10             	mov    0x10(%ebp),%eax
  80033e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800341:	8b 45 14             	mov    0x14(%ebp),%eax
  800344:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800347:	8b 45 18             	mov    0x18(%ebp),%eax
  80034a:	ba 00 00 00 00       	mov    $0x0,%edx
  80034f:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800352:	77 72                	ja     8003c6 <printnum+0x92>
  800354:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800357:	72 05                	jb     80035e <printnum+0x2a>
  800359:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80035c:	77 68                	ja     8003c6 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80035e:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800361:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800364:	8b 45 18             	mov    0x18(%ebp),%eax
  800367:	ba 00 00 00 00       	mov    $0x0,%edx
  80036c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800370:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800374:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800377:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80037a:	89 04 24             	mov    %eax,(%esp)
  80037d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800381:	e8 8a 16 00 00       	call   801a10 <__udivdi3>
  800386:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800389:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  80038d:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800391:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800394:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800398:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003aa:	89 04 24             	mov    %eax,(%esp)
  8003ad:	e8 82 ff ff ff       	call   800334 <printnum>
  8003b2:	eb 1c                	jmp    8003d0 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bb:	8b 45 20             	mov    0x20(%ebp),%eax
  8003be:	89 04 24             	mov    %eax,(%esp)
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c4:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c6:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8003ca:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8003ce:	7f e4                	jg     8003b4 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003d0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8003db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8003de:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003e2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003e6:	89 04 24             	mov    %eax,(%esp)
  8003e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003ed:	e8 4e 17 00 00       	call   801b40 <__umoddi3>
  8003f2:	05 28 1e 80 00       	add    $0x801e28,%eax
  8003f7:	0f b6 00             	movzbl (%eax),%eax
  8003fa:	0f be c0             	movsbl %al,%eax
  8003fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800400:	89 54 24 04          	mov    %edx,0x4(%esp)
  800404:	89 04 24             	mov    %eax,(%esp)
  800407:	8b 45 08             	mov    0x8(%ebp),%eax
  80040a:	ff d0                	call   *%eax
}
  80040c:	83 c4 34             	add    $0x34,%esp
  80040f:	5b                   	pop    %ebx
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800415:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800419:	7e 14                	jle    80042f <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80041b:	8b 45 08             	mov    0x8(%ebp),%eax
  80041e:	8b 00                	mov    (%eax),%eax
  800420:	8d 48 08             	lea    0x8(%eax),%ecx
  800423:	8b 55 08             	mov    0x8(%ebp),%edx
  800426:	89 0a                	mov    %ecx,(%edx)
  800428:	8b 50 04             	mov    0x4(%eax),%edx
  80042b:	8b 00                	mov    (%eax),%eax
  80042d:	eb 30                	jmp    80045f <getuint+0x4d>
	else if (lflag)
  80042f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800433:	74 16                	je     80044b <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800435:	8b 45 08             	mov    0x8(%ebp),%eax
  800438:	8b 00                	mov    (%eax),%eax
  80043a:	8d 48 04             	lea    0x4(%eax),%ecx
  80043d:	8b 55 08             	mov    0x8(%ebp),%edx
  800440:	89 0a                	mov    %ecx,(%edx)
  800442:	8b 00                	mov    (%eax),%eax
  800444:	ba 00 00 00 00       	mov    $0x0,%edx
  800449:	eb 14                	jmp    80045f <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80044b:	8b 45 08             	mov    0x8(%ebp),%eax
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	8d 48 04             	lea    0x4(%eax),%ecx
  800453:	8b 55 08             	mov    0x8(%ebp),%edx
  800456:	89 0a                	mov    %ecx,(%edx)
  800458:	8b 00                	mov    (%eax),%eax
  80045a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80045f:	5d                   	pop    %ebp
  800460:	c3                   	ret    

00800461 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800461:	55                   	push   %ebp
  800462:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800464:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800468:	7e 14                	jle    80047e <getint+0x1d>
		return va_arg(*ap, long long);
  80046a:	8b 45 08             	mov    0x8(%ebp),%eax
  80046d:	8b 00                	mov    (%eax),%eax
  80046f:	8d 48 08             	lea    0x8(%eax),%ecx
  800472:	8b 55 08             	mov    0x8(%ebp),%edx
  800475:	89 0a                	mov    %ecx,(%edx)
  800477:	8b 50 04             	mov    0x4(%eax),%edx
  80047a:	8b 00                	mov    (%eax),%eax
  80047c:	eb 28                	jmp    8004a6 <getint+0x45>
	else if (lflag)
  80047e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800482:	74 12                	je     800496 <getint+0x35>
		return va_arg(*ap, long);
  800484:	8b 45 08             	mov    0x8(%ebp),%eax
  800487:	8b 00                	mov    (%eax),%eax
  800489:	8d 48 04             	lea    0x4(%eax),%ecx
  80048c:	8b 55 08             	mov    0x8(%ebp),%edx
  80048f:	89 0a                	mov    %ecx,(%edx)
  800491:	8b 00                	mov    (%eax),%eax
  800493:	99                   	cltd   
  800494:	eb 10                	jmp    8004a6 <getint+0x45>
	else
		return va_arg(*ap, int);
  800496:	8b 45 08             	mov    0x8(%ebp),%eax
  800499:	8b 00                	mov    (%eax),%eax
  80049b:	8d 48 04             	lea    0x4(%eax),%ecx
  80049e:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a1:	89 0a                	mov    %ecx,(%edx)
  8004a3:	8b 00                	mov    (%eax),%eax
  8004a5:	99                   	cltd   
}
  8004a6:	5d                   	pop    %ebp
  8004a7:	c3                   	ret    

008004a8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	56                   	push   %esi
  8004ac:	53                   	push   %ebx
  8004ad:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004b0:	eb 18                	jmp    8004ca <vprintfmt+0x22>
			if (ch == '\0')
  8004b2:	85 db                	test   %ebx,%ebx
  8004b4:	75 05                	jne    8004bb <vprintfmt+0x13>
				return;
  8004b6:	e9 05 04 00 00       	jmp    8008c0 <vprintfmt+0x418>
			putch(ch, putdat);
  8004bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c2:	89 1c 24             	mov    %ebx,(%esp)
  8004c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c8:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8004cd:	8d 50 01             	lea    0x1(%eax),%edx
  8004d0:	89 55 10             	mov    %edx,0x10(%ebp)
  8004d3:	0f b6 00             	movzbl (%eax),%eax
  8004d6:	0f b6 d8             	movzbl %al,%ebx
  8004d9:	83 fb 25             	cmp    $0x25,%ebx
  8004dc:	75 d4                	jne    8004b2 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8004de:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8004e2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8004e9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004f0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8004f7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800501:	8d 50 01             	lea    0x1(%eax),%edx
  800504:	89 55 10             	mov    %edx,0x10(%ebp)
  800507:	0f b6 00             	movzbl (%eax),%eax
  80050a:	0f b6 d8             	movzbl %al,%ebx
  80050d:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800510:	83 f8 55             	cmp    $0x55,%eax
  800513:	0f 87 76 03 00 00    	ja     80088f <vprintfmt+0x3e7>
  800519:	8b 04 85 4c 1e 80 00 	mov    0x801e4c(,%eax,4),%eax
  800520:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800522:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800526:	eb d6                	jmp    8004fe <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800528:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80052c:	eb d0                	jmp    8004fe <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80052e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800535:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800538:	89 d0                	mov    %edx,%eax
  80053a:	c1 e0 02             	shl    $0x2,%eax
  80053d:	01 d0                	add    %edx,%eax
  80053f:	01 c0                	add    %eax,%eax
  800541:	01 d8                	add    %ebx,%eax
  800543:	83 e8 30             	sub    $0x30,%eax
  800546:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800549:	8b 45 10             	mov    0x10(%ebp),%eax
  80054c:	0f b6 00             	movzbl (%eax),%eax
  80054f:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800552:	83 fb 2f             	cmp    $0x2f,%ebx
  800555:	7e 0b                	jle    800562 <vprintfmt+0xba>
  800557:	83 fb 39             	cmp    $0x39,%ebx
  80055a:	7f 06                	jg     800562 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80055c:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800560:	eb d3                	jmp    800535 <vprintfmt+0x8d>
			goto process_precision;
  800562:	eb 33                	jmp    800597 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8d 50 04             	lea    0x4(%eax),%edx
  80056a:	89 55 14             	mov    %edx,0x14(%ebp)
  80056d:	8b 00                	mov    (%eax),%eax
  80056f:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800572:	eb 23                	jmp    800597 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800574:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800578:	79 0c                	jns    800586 <vprintfmt+0xde>
				width = 0;
  80057a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800581:	e9 78 ff ff ff       	jmp    8004fe <vprintfmt+0x56>
  800586:	e9 73 ff ff ff       	jmp    8004fe <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80058b:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800592:	e9 67 ff ff ff       	jmp    8004fe <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800597:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80059b:	79 12                	jns    8005af <vprintfmt+0x107>
				width = precision, precision = -1;
  80059d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8005aa:	e9 4f ff ff ff       	jmp    8004fe <vprintfmt+0x56>
  8005af:	e9 4a ff ff ff       	jmp    8004fe <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005b4:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8005b8:	e9 41 ff ff ff       	jmp    8004fe <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 50 04             	lea    0x4(%eax),%edx
  8005c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c6:	8b 00                	mov    (%eax),%eax
  8005c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005cb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005cf:	89 04 24             	mov    %eax,(%esp)
  8005d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d5:	ff d0                	call   *%eax
			break;
  8005d7:	e9 de 02 00 00       	jmp    8008ba <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8005e7:	85 db                	test   %ebx,%ebx
  8005e9:	79 02                	jns    8005ed <vprintfmt+0x145>
				err = -err;
  8005eb:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ed:	83 fb 09             	cmp    $0x9,%ebx
  8005f0:	7f 0b                	jg     8005fd <vprintfmt+0x155>
  8005f2:	8b 34 9d 00 1e 80 00 	mov    0x801e00(,%ebx,4),%esi
  8005f9:	85 f6                	test   %esi,%esi
  8005fb:	75 23                	jne    800620 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8005fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800601:	c7 44 24 08 39 1e 80 	movl   $0x801e39,0x8(%esp)
  800608:	00 
  800609:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800610:	8b 45 08             	mov    0x8(%ebp),%eax
  800613:	89 04 24             	mov    %eax,(%esp)
  800616:	e8 ac 02 00 00       	call   8008c7 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80061b:	e9 9a 02 00 00       	jmp    8008ba <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800620:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800624:	c7 44 24 08 42 1e 80 	movl   $0x801e42,0x8(%esp)
  80062b:	00 
  80062c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80062f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800633:	8b 45 08             	mov    0x8(%ebp),%eax
  800636:	89 04 24             	mov    %eax,(%esp)
  800639:	e8 89 02 00 00       	call   8008c7 <printfmt>
			break;
  80063e:	e9 77 02 00 00       	jmp    8008ba <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 50 04             	lea    0x4(%eax),%edx
  800649:	89 55 14             	mov    %edx,0x14(%ebp)
  80064c:	8b 30                	mov    (%eax),%esi
  80064e:	85 f6                	test   %esi,%esi
  800650:	75 05                	jne    800657 <vprintfmt+0x1af>
				p = "(null)";
  800652:	be 45 1e 80 00       	mov    $0x801e45,%esi
			if (width > 0 && padc != '-')
  800657:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80065b:	7e 37                	jle    800694 <vprintfmt+0x1ec>
  80065d:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800661:	74 31                	je     800694 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800663:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800666:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066a:	89 34 24             	mov    %esi,(%esp)
  80066d:	e8 72 03 00 00       	call   8009e4 <strnlen>
  800672:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800675:	eb 17                	jmp    80068e <vprintfmt+0x1e6>
					putch(padc, putdat);
  800677:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80067b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80067e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800682:	89 04 24             	mov    %eax,(%esp)
  800685:	8b 45 08             	mov    0x8(%ebp),%eax
  800688:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80068e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800692:	7f e3                	jg     800677 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800694:	eb 38                	jmp    8006ce <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800696:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80069a:	74 1f                	je     8006bb <vprintfmt+0x213>
  80069c:	83 fb 1f             	cmp    $0x1f,%ebx
  80069f:	7e 05                	jle    8006a6 <vprintfmt+0x1fe>
  8006a1:	83 fb 7e             	cmp    $0x7e,%ebx
  8006a4:	7e 15                	jle    8006bb <vprintfmt+0x213>
					putch('?', putdat);
  8006a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ad:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	ff d0                	call   *%eax
  8006b9:	eb 0f                	jmp    8006ca <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8006bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c2:	89 1c 24             	mov    %ebx,(%esp)
  8006c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c8:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ca:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8006ce:	89 f0                	mov    %esi,%eax
  8006d0:	8d 70 01             	lea    0x1(%eax),%esi
  8006d3:	0f b6 00             	movzbl (%eax),%eax
  8006d6:	0f be d8             	movsbl %al,%ebx
  8006d9:	85 db                	test   %ebx,%ebx
  8006db:	74 10                	je     8006ed <vprintfmt+0x245>
  8006dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006e1:	78 b3                	js     800696 <vprintfmt+0x1ee>
  8006e3:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8006e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006eb:	79 a9                	jns    800696 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ed:	eb 17                	jmp    800706 <vprintfmt+0x25e>
				putch(' ', putdat);
  8006ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800700:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800702:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800706:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80070a:	7f e3                	jg     8006ef <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80070c:	e9 a9 01 00 00       	jmp    8008ba <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800711:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800714:	89 44 24 04          	mov    %eax,0x4(%esp)
  800718:	8d 45 14             	lea    0x14(%ebp),%eax
  80071b:	89 04 24             	mov    %eax,(%esp)
  80071e:	e8 3e fd ff ff       	call   800461 <getint>
  800723:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800726:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800729:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80072f:	85 d2                	test   %edx,%edx
  800731:	79 26                	jns    800759 <vprintfmt+0x2b1>
				putch('-', putdat);
  800733:	8b 45 0c             	mov    0xc(%ebp),%eax
  800736:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073a:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800741:	8b 45 08             	mov    0x8(%ebp),%eax
  800744:	ff d0                	call   *%eax
				num = -(long long) num;
  800746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800749:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80074c:	f7 d8                	neg    %eax
  80074e:	83 d2 00             	adc    $0x0,%edx
  800751:	f7 da                	neg    %edx
  800753:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800756:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800759:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800760:	e9 e1 00 00 00       	jmp    800846 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800765:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800768:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076c:	8d 45 14             	lea    0x14(%ebp),%eax
  80076f:	89 04 24             	mov    %eax,(%esp)
  800772:	e8 9b fc ff ff       	call   800412 <getuint>
  800777:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80077a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  80077d:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800784:	e9 bd 00 00 00       	jmp    800846 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  800789:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  800790:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800793:	89 44 24 04          	mov    %eax,0x4(%esp)
  800797:	8d 45 14             	lea    0x14(%ebp),%eax
  80079a:	89 04 24             	mov    %eax,(%esp)
  80079d:	e8 70 fc ff ff       	call   800412 <getuint>
  8007a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  8007a8:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007af:	89 54 24 18          	mov    %edx,0x18(%esp)
  8007b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007b6:	89 54 24 14          	mov    %edx,0x14(%esp)
  8007ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	89 04 24             	mov    %eax,(%esp)
  8007d9:	e8 56 fb ff ff       	call   800334 <printnum>
			break;
  8007de:	e9 d7 00 00 00       	jmp    8008ba <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  8007e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ea:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	ff d0                	call   *%eax
			putch('x', putdat);
  8007f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fd:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8d 50 04             	lea    0x4(%eax),%edx
  80080f:	89 55 14             	mov    %edx,0x14(%ebp)
  800812:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800814:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800817:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80081e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800825:	eb 1f                	jmp    800846 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800827:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80082a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082e:	8d 45 14             	lea    0x14(%ebp),%eax
  800831:	89 04 24             	mov    %eax,(%esp)
  800834:	e8 d9 fb ff ff       	call   800412 <getuint>
  800839:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80083c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80083f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800846:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80084a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80084d:	89 54 24 18          	mov    %edx,0x18(%esp)
  800851:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800854:	89 54 24 14          	mov    %edx,0x14(%esp)
  800858:	89 44 24 10          	mov    %eax,0x10(%esp)
  80085c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800862:	89 44 24 08          	mov    %eax,0x8(%esp)
  800866:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80086a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	89 04 24             	mov    %eax,(%esp)
  800877:	e8 b8 fa ff ff       	call   800334 <printnum>
			break;
  80087c:	eb 3c                	jmp    8008ba <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80087e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800881:	89 44 24 04          	mov    %eax,0x4(%esp)
  800885:	89 1c 24             	mov    %ebx,(%esp)
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	ff d0                	call   *%eax
			break;
  80088d:	eb 2b                	jmp    8008ba <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80088f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800892:	89 44 24 04          	mov    %eax,0x4(%esp)
  800896:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008a2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8008a6:	eb 04                	jmp    8008ac <vprintfmt+0x404>
  8008a8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8008ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8008af:	83 e8 01             	sub    $0x1,%eax
  8008b2:	0f b6 00             	movzbl (%eax),%eax
  8008b5:	3c 25                	cmp    $0x25,%al
  8008b7:	75 ef                	jne    8008a8 <vprintfmt+0x400>
				/* do nothing */;
			break;
  8008b9:	90                   	nop
		}
	}
  8008ba:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008bb:	e9 0a fc ff ff       	jmp    8004ca <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8008c0:	83 c4 40             	add    $0x40,%esp
  8008c3:	5b                   	pop    %ebx
  8008c4:	5e                   	pop    %esi
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8008cd:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8008d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008da:	8b 45 10             	mov    0x10(%ebp),%eax
  8008dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	89 04 24             	mov    %eax,(%esp)
  8008ee:	e8 b5 fb ff ff       	call   8004a8 <vprintfmt>
	va_end(ap);
}
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8008f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fb:	8b 40 08             	mov    0x8(%eax),%eax
  8008fe:	8d 50 01             	lea    0x1(%eax),%edx
  800901:	8b 45 0c             	mov    0xc(%ebp),%eax
  800904:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800907:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090a:	8b 10                	mov    (%eax),%edx
  80090c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090f:	8b 40 04             	mov    0x4(%eax),%eax
  800912:	39 c2                	cmp    %eax,%edx
  800914:	73 12                	jae    800928 <sprintputch+0x33>
		*b->buf++ = ch;
  800916:	8b 45 0c             	mov    0xc(%ebp),%eax
  800919:	8b 00                	mov    (%eax),%eax
  80091b:	8d 48 01             	lea    0x1(%eax),%ecx
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800921:	89 0a                	mov    %ecx,(%edx)
  800923:	8b 55 08             	mov    0x8(%ebp),%edx
  800926:	88 10                	mov    %dl,(%eax)
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800936:	8b 45 0c             	mov    0xc(%ebp),%eax
  800939:	8d 50 ff             	lea    -0x1(%eax),%edx
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	01 d0                	add    %edx,%eax
  800941:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800944:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80094b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80094f:	74 06                	je     800957 <vsnprintf+0x2d>
  800951:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800955:	7f 07                	jg     80095e <vsnprintf+0x34>
		return -E_INVAL;
  800957:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80095c:	eb 2a                	jmp    800988 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80095e:	8b 45 14             	mov    0x14(%ebp),%eax
  800961:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800965:	8b 45 10             	mov    0x10(%ebp),%eax
  800968:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80096f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800973:	c7 04 24 f5 08 80 00 	movl   $0x8008f5,(%esp)
  80097a:	e8 29 fb ff ff       	call   8004a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80097f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800982:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800985:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800990:	8d 45 14             	lea    0x14(%ebp),%eax
  800993:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800996:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800999:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80099d:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	89 04 24             	mov    %eax,(%esp)
  8009b1:	e8 74 ff ff ff       	call   80092a <vsnprintf>
  8009b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8009b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009cb:	eb 08                	jmp    8009d5 <strlen+0x17>
		n++;
  8009cd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	0f b6 00             	movzbl (%eax),%eax
  8009db:	84 c0                	test   %al,%al
  8009dd:	75 ee                	jne    8009cd <strlen+0xf>
		n++;
	return n;
  8009df:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009f1:	eb 0c                	jmp    8009ff <strnlen+0x1b>
		n++;
  8009f3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009fb:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  8009ff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a03:	74 0a                	je     800a0f <strnlen+0x2b>
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	0f b6 00             	movzbl (%eax),%eax
  800a0b:	84 c0                	test   %al,%al
  800a0d:	75 e4                	jne    8009f3 <strnlen+0xf>
		n++;
	return n;
  800a0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800a20:	90                   	nop
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8d 50 01             	lea    0x1(%eax),%edx
  800a27:	89 55 08             	mov    %edx,0x8(%ebp)
  800a2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a30:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a33:	0f b6 12             	movzbl (%edx),%edx
  800a36:	88 10                	mov    %dl,(%eax)
  800a38:	0f b6 00             	movzbl (%eax),%eax
  800a3b:	84 c0                	test   %al,%al
  800a3d:	75 e2                	jne    800a21 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800a3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	89 04 24             	mov    %eax,(%esp)
  800a50:	e8 69 ff ff ff       	call   8009be <strlen>
  800a55:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800a58:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	01 c2                	add    %eax,%edx
  800a60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a67:	89 14 24             	mov    %edx,(%esp)
  800a6a:	e8 a5 ff ff ff       	call   800a14 <strcpy>
	return dst;
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800a80:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800a87:	eb 23                	jmp    800aac <strncpy+0x38>
		*dst++ = *src;
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8d 50 01             	lea    0x1(%eax),%edx
  800a8f:	89 55 08             	mov    %edx,0x8(%ebp)
  800a92:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a95:	0f b6 12             	movzbl (%edx),%edx
  800a98:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9d:	0f b6 00             	movzbl (%eax),%eax
  800aa0:	84 c0                	test   %al,%al
  800aa2:	74 04                	je     800aa8 <strncpy+0x34>
			src++;
  800aa4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800aac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800aaf:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ab2:	72 d5                	jb     800a89 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800ab4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800ab7:	c9                   	leave  
  800ab8:	c3                   	ret    

00800ab9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800ac5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ac9:	74 33                	je     800afe <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800acb:	eb 17                	jmp    800ae4 <strlcpy+0x2b>
			*dst++ = *src++;
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	8d 50 01             	lea    0x1(%eax),%edx
  800ad3:	89 55 08             	mov    %edx,0x8(%ebp)
  800ad6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad9:	8d 4a 01             	lea    0x1(%edx),%ecx
  800adc:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800adf:	0f b6 12             	movzbl (%edx),%edx
  800ae2:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ae4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ae8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aec:	74 0a                	je     800af8 <strlcpy+0x3f>
  800aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af1:	0f b6 00             	movzbl (%eax),%eax
  800af4:	84 c0                	test   %al,%al
  800af6:	75 d5                	jne    800acd <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800afe:	8b 55 08             	mov    0x8(%ebp),%edx
  800b01:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b04:	29 c2                	sub    %eax,%edx
  800b06:	89 d0                	mov    %edx,%eax
}
  800b08:	c9                   	leave  
  800b09:	c3                   	ret    

00800b0a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800b0d:	eb 08                	jmp    800b17 <strcmp+0xd>
		p++, q++;
  800b0f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b13:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	0f b6 00             	movzbl (%eax),%eax
  800b1d:	84 c0                	test   %al,%al
  800b1f:	74 10                	je     800b31 <strcmp+0x27>
  800b21:	8b 45 08             	mov    0x8(%ebp),%eax
  800b24:	0f b6 10             	movzbl (%eax),%edx
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2a:	0f b6 00             	movzbl (%eax),%eax
  800b2d:	38 c2                	cmp    %al,%dl
  800b2f:	74 de                	je     800b0f <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	0f b6 00             	movzbl (%eax),%eax
  800b37:	0f b6 d0             	movzbl %al,%edx
  800b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3d:	0f b6 00             	movzbl (%eax),%eax
  800b40:	0f b6 c0             	movzbl %al,%eax
  800b43:	29 c2                	sub    %eax,%edx
  800b45:	89 d0                	mov    %edx,%eax
}
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800b4c:	eb 0c                	jmp    800b5a <strncmp+0x11>
		n--, p++, q++;
  800b4e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b52:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b56:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b5e:	74 1a                	je     800b7a <strncmp+0x31>
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	0f b6 00             	movzbl (%eax),%eax
  800b66:	84 c0                	test   %al,%al
  800b68:	74 10                	je     800b7a <strncmp+0x31>
  800b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6d:	0f b6 10             	movzbl (%eax),%edx
  800b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b73:	0f b6 00             	movzbl (%eax),%eax
  800b76:	38 c2                	cmp    %al,%dl
  800b78:	74 d4                	je     800b4e <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800b7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b7e:	75 07                	jne    800b87 <strncmp+0x3e>
		return 0;
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
  800b85:	eb 16                	jmp    800b9d <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	0f b6 00             	movzbl (%eax),%eax
  800b8d:	0f b6 d0             	movzbl %al,%edx
  800b90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b93:	0f b6 00             	movzbl (%eax),%eax
  800b96:	0f b6 c0             	movzbl %al,%eax
  800b99:	29 c2                	sub    %eax,%edx
  800b9b:	89 d0                	mov    %edx,%eax
}
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	83 ec 04             	sub    $0x4,%esp
  800ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba8:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800bab:	eb 14                	jmp    800bc1 <strchr+0x22>
		if (*s == c)
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb0:	0f b6 00             	movzbl (%eax),%eax
  800bb3:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800bb6:	75 05                	jne    800bbd <strchr+0x1e>
			return (char *) s;
  800bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbb:	eb 13                	jmp    800bd0 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bbd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc4:	0f b6 00             	movzbl (%eax),%eax
  800bc7:	84 c0                	test   %al,%al
  800bc9:	75 e2                	jne    800bad <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800bcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd0:	c9                   	leave  
  800bd1:	c3                   	ret    

00800bd2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	83 ec 04             	sub    $0x4,%esp
  800bd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdb:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800bde:	eb 11                	jmp    800bf1 <strfind+0x1f>
		if (*s == c)
  800be0:	8b 45 08             	mov    0x8(%ebp),%eax
  800be3:	0f b6 00             	movzbl (%eax),%eax
  800be6:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800be9:	75 02                	jne    800bed <strfind+0x1b>
			break;
  800beb:	eb 0e                	jmp    800bfb <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bed:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf4:	0f b6 00             	movzbl (%eax),%eax
  800bf7:	84 c0                	test   %al,%al
  800bf9:	75 e5                	jne    800be0 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800bfb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bfe:	c9                   	leave  
  800bff:	c3                   	ret    

00800c00 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
	char *p;

	if (n == 0)
  800c04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c08:	75 05                	jne    800c0f <memset+0xf>
		return v;
  800c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0d:	eb 5c                	jmp    800c6b <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c12:	83 e0 03             	and    $0x3,%eax
  800c15:	85 c0                	test   %eax,%eax
  800c17:	75 41                	jne    800c5a <memset+0x5a>
  800c19:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1c:	83 e0 03             	and    $0x3,%eax
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	75 37                	jne    800c5a <memset+0x5a>
		c &= 0xFF;
  800c23:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2d:	c1 e0 18             	shl    $0x18,%eax
  800c30:	89 c2                	mov    %eax,%edx
  800c32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c35:	c1 e0 10             	shl    $0x10,%eax
  800c38:	09 c2                	or     %eax,%edx
  800c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3d:	c1 e0 08             	shl    $0x8,%eax
  800c40:	09 d0                	or     %edx,%eax
  800c42:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c45:	8b 45 10             	mov    0x10(%ebp),%eax
  800c48:	c1 e8 02             	shr    $0x2,%eax
  800c4b:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c53:	89 d7                	mov    %edx,%edi
  800c55:	fc                   	cld    
  800c56:	f3 ab                	rep stos %eax,%es:(%edi)
  800c58:	eb 0e                	jmp    800c68 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c60:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c63:	89 d7                	mov    %edx,%edi
  800c65:	fc                   	cld    
  800c66:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800c68:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800c77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c80:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c86:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c89:	73 6d                	jae    800cf8 <memmove+0x8a>
  800c8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c91:	01 d0                	add    %edx,%eax
  800c93:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c96:	76 60                	jbe    800cf8 <memmove+0x8a>
		s += n;
  800c98:	8b 45 10             	mov    0x10(%ebp),%eax
  800c9b:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800c9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca1:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ca7:	83 e0 03             	and    $0x3,%eax
  800caa:	85 c0                	test   %eax,%eax
  800cac:	75 2f                	jne    800cdd <memmove+0x6f>
  800cae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cb1:	83 e0 03             	and    $0x3,%eax
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	75 25                	jne    800cdd <memmove+0x6f>
  800cb8:	8b 45 10             	mov    0x10(%ebp),%eax
  800cbb:	83 e0 03             	and    $0x3,%eax
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	75 1b                	jne    800cdd <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cc5:	83 e8 04             	sub    $0x4,%eax
  800cc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ccb:	83 ea 04             	sub    $0x4,%edx
  800cce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cd1:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cd4:	89 c7                	mov    %eax,%edi
  800cd6:	89 d6                	mov    %edx,%esi
  800cd8:	fd                   	std    
  800cd9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cdb:	eb 18                	jmp    800cf5 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ce0:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ce3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ce6:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ce9:	8b 45 10             	mov    0x10(%ebp),%eax
  800cec:	89 d7                	mov    %edx,%edi
  800cee:	89 de                	mov    %ebx,%esi
  800cf0:	89 c1                	mov    %eax,%ecx
  800cf2:	fd                   	std    
  800cf3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cf5:	fc                   	cld    
  800cf6:	eb 45                	jmp    800d3d <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cfb:	83 e0 03             	and    $0x3,%eax
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	75 2b                	jne    800d2d <memmove+0xbf>
  800d02:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d05:	83 e0 03             	and    $0x3,%eax
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	75 21                	jne    800d2d <memmove+0xbf>
  800d0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d0f:	83 e0 03             	and    $0x3,%eax
  800d12:	85 c0                	test   %eax,%eax
  800d14:	75 17                	jne    800d2d <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d16:	8b 45 10             	mov    0x10(%ebp),%eax
  800d19:	c1 e8 02             	shr    $0x2,%eax
  800d1c:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d21:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d24:	89 c7                	mov    %eax,%edi
  800d26:	89 d6                	mov    %edx,%esi
  800d28:	fc                   	cld    
  800d29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d2b:	eb 10                	jmp    800d3d <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d30:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d33:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d36:	89 c7                	mov    %eax,%edi
  800d38:	89 d6                	mov    %edx,%esi
  800d3a:	fc                   	cld    
  800d3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d40:	83 c4 10             	add    $0x10,%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d4e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d51:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d58:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	89 04 24             	mov    %eax,(%esp)
  800d62:	e8 07 ff ff ff       	call   800c6e <memmove>
}
  800d67:	c9                   	leave  
  800d68:	c3                   	ret    

00800d69 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800d75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d78:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800d7b:	eb 30                	jmp    800dad <memcmp+0x44>
		if (*s1 != *s2)
  800d7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d80:	0f b6 10             	movzbl (%eax),%edx
  800d83:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d86:	0f b6 00             	movzbl (%eax),%eax
  800d89:	38 c2                	cmp    %al,%dl
  800d8b:	74 18                	je     800da5 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800d8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d90:	0f b6 00             	movzbl (%eax),%eax
  800d93:	0f b6 d0             	movzbl %al,%edx
  800d96:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d99:	0f b6 00             	movzbl (%eax),%eax
  800d9c:	0f b6 c0             	movzbl %al,%eax
  800d9f:	29 c2                	sub    %eax,%edx
  800da1:	89 d0                	mov    %edx,%eax
  800da3:	eb 1a                	jmp    800dbf <memcmp+0x56>
		s1++, s2++;
  800da5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800da9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dad:	8b 45 10             	mov    0x10(%ebp),%eax
  800db0:	8d 50 ff             	lea    -0x1(%eax),%edx
  800db3:	89 55 10             	mov    %edx,0x10(%ebp)
  800db6:	85 c0                	test   %eax,%eax
  800db8:	75 c3                	jne    800d7d <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dbf:	c9                   	leave  
  800dc0:	c3                   	ret    

00800dc1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800dc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	01 d0                	add    %edx,%eax
  800dcf:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800dd2:	eb 13                	jmp    800de7 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd7:	0f b6 10             	movzbl (%eax),%edx
  800dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddd:	38 c2                	cmp    %al,%dl
  800ddf:	75 02                	jne    800de3 <memfind+0x22>
			break;
  800de1:	eb 0c                	jmp    800def <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800de3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800de7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dea:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800ded:	72 e5                	jb     800dd4 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800def:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800df2:	c9                   	leave  
  800df3:	c3                   	ret    

00800df4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800dfa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800e01:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e08:	eb 04                	jmp    800e0e <strtol+0x1a>
		s++;
  800e0a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	0f b6 00             	movzbl (%eax),%eax
  800e14:	3c 20                	cmp    $0x20,%al
  800e16:	74 f2                	je     800e0a <strtol+0x16>
  800e18:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1b:	0f b6 00             	movzbl (%eax),%eax
  800e1e:	3c 09                	cmp    $0x9,%al
  800e20:	74 e8                	je     800e0a <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e22:	8b 45 08             	mov    0x8(%ebp),%eax
  800e25:	0f b6 00             	movzbl (%eax),%eax
  800e28:	3c 2b                	cmp    $0x2b,%al
  800e2a:	75 06                	jne    800e32 <strtol+0x3e>
		s++;
  800e2c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e30:	eb 15                	jmp    800e47 <strtol+0x53>
	else if (*s == '-')
  800e32:	8b 45 08             	mov    0x8(%ebp),%eax
  800e35:	0f b6 00             	movzbl (%eax),%eax
  800e38:	3c 2d                	cmp    $0x2d,%al
  800e3a:	75 0b                	jne    800e47 <strtol+0x53>
		s++, neg = 1;
  800e3c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e40:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e47:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e4b:	74 06                	je     800e53 <strtol+0x5f>
  800e4d:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800e51:	75 24                	jne    800e77 <strtol+0x83>
  800e53:	8b 45 08             	mov    0x8(%ebp),%eax
  800e56:	0f b6 00             	movzbl (%eax),%eax
  800e59:	3c 30                	cmp    $0x30,%al
  800e5b:	75 1a                	jne    800e77 <strtol+0x83>
  800e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e60:	83 c0 01             	add    $0x1,%eax
  800e63:	0f b6 00             	movzbl (%eax),%eax
  800e66:	3c 78                	cmp    $0x78,%al
  800e68:	75 0d                	jne    800e77 <strtol+0x83>
		s += 2, base = 16;
  800e6a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800e6e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800e75:	eb 2a                	jmp    800ea1 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800e77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e7b:	75 17                	jne    800e94 <strtol+0xa0>
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e80:	0f b6 00             	movzbl (%eax),%eax
  800e83:	3c 30                	cmp    $0x30,%al
  800e85:	75 0d                	jne    800e94 <strtol+0xa0>
		s++, base = 8;
  800e87:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e8b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800e92:	eb 0d                	jmp    800ea1 <strtol+0xad>
	else if (base == 0)
  800e94:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e98:	75 07                	jne    800ea1 <strtol+0xad>
		base = 10;
  800e9a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ea1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea4:	0f b6 00             	movzbl (%eax),%eax
  800ea7:	3c 2f                	cmp    $0x2f,%al
  800ea9:	7e 1b                	jle    800ec6 <strtol+0xd2>
  800eab:	8b 45 08             	mov    0x8(%ebp),%eax
  800eae:	0f b6 00             	movzbl (%eax),%eax
  800eb1:	3c 39                	cmp    $0x39,%al
  800eb3:	7f 11                	jg     800ec6 <strtol+0xd2>
			dig = *s - '0';
  800eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb8:	0f b6 00             	movzbl (%eax),%eax
  800ebb:	0f be c0             	movsbl %al,%eax
  800ebe:	83 e8 30             	sub    $0x30,%eax
  800ec1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ec4:	eb 48                	jmp    800f0e <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800ec6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec9:	0f b6 00             	movzbl (%eax),%eax
  800ecc:	3c 60                	cmp    $0x60,%al
  800ece:	7e 1b                	jle    800eeb <strtol+0xf7>
  800ed0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed3:	0f b6 00             	movzbl (%eax),%eax
  800ed6:	3c 7a                	cmp    $0x7a,%al
  800ed8:	7f 11                	jg     800eeb <strtol+0xf7>
			dig = *s - 'a' + 10;
  800eda:	8b 45 08             	mov    0x8(%ebp),%eax
  800edd:	0f b6 00             	movzbl (%eax),%eax
  800ee0:	0f be c0             	movsbl %al,%eax
  800ee3:	83 e8 57             	sub    $0x57,%eax
  800ee6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ee9:	eb 23                	jmp    800f0e <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800eeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800eee:	0f b6 00             	movzbl (%eax),%eax
  800ef1:	3c 40                	cmp    $0x40,%al
  800ef3:	7e 3d                	jle    800f32 <strtol+0x13e>
  800ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef8:	0f b6 00             	movzbl (%eax),%eax
  800efb:	3c 5a                	cmp    $0x5a,%al
  800efd:	7f 33                	jg     800f32 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
  800f02:	0f b6 00             	movzbl (%eax),%eax
  800f05:	0f be c0             	movsbl %al,%eax
  800f08:	83 e8 37             	sub    $0x37,%eax
  800f0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f11:	3b 45 10             	cmp    0x10(%ebp),%eax
  800f14:	7c 02                	jl     800f18 <strtol+0x124>
			break;
  800f16:	eb 1a                	jmp    800f32 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800f18:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800f1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f1f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f23:	89 c2                	mov    %eax,%edx
  800f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f28:	01 d0                	add    %edx,%eax
  800f2a:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800f2d:	e9 6f ff ff ff       	jmp    800ea1 <strtol+0xad>

	if (endptr)
  800f32:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f36:	74 08                	je     800f40 <strtol+0x14c>
		*endptr = (char *) s;
  800f38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800f40:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800f44:	74 07                	je     800f4d <strtol+0x159>
  800f46:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f49:	f7 d8                	neg    %eax
  800f4b:	eb 03                	jmp    800f50 <strtol+0x15c>
  800f4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800f50:	c9                   	leave  
  800f51:	c3                   	ret    

00800f52 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5e:	8b 55 10             	mov    0x10(%ebp),%edx
  800f61:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800f64:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800f67:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800f6a:	8b 75 20             	mov    0x20(%ebp),%esi
  800f6d:	cd 30                	int    $0x30
  800f6f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f76:	74 30                	je     800fa8 <syscall+0x56>
  800f78:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f7c:	7e 2a                	jle    800fa8 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f81:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f85:	8b 45 08             	mov    0x8(%ebp),%eax
  800f88:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f8c:	c7 44 24 08 a4 1f 80 	movl   $0x801fa4,0x8(%esp)
  800f93:	00 
  800f94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9b:	00 
  800f9c:	c7 04 24 c1 1f 80 00 	movl   $0x801fc1,(%esp)
  800fa3:	e8 75 09 00 00       	call   80191d <_panic>

	return ret;
  800fa8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800fab:	83 c4 3c             	add    $0x3c,%esp
  800fae:	5b                   	pop    %ebx
  800faf:	5e                   	pop    %esi
  800fb0:	5f                   	pop    %edi
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    

00800fb3 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800fb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fc3:	00 
  800fc4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fcb:	00 
  800fcc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fd3:	00 
  800fd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fdf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fe6:	00 
  800fe7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fee:	e8 5f ff ff ff       	call   800f52 <syscall>
}
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ffb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801002:	00 
  801003:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80100a:	00 
  80100b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801012:	00 
  801013:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80101a:	00 
  80101b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801022:	00 
  801023:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80102a:	00 
  80102b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801032:	e8 1b ff ff ff       	call   800f52 <syscall>
}
  801037:	c9                   	leave  
  801038:	c3                   	ret    

00801039 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80103f:	8b 45 08             	mov    0x8(%ebp),%eax
  801042:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801049:	00 
  80104a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801051:	00 
  801052:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801059:	00 
  80105a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801061:	00 
  801062:	89 44 24 08          	mov    %eax,0x8(%esp)
  801066:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80106d:	00 
  80106e:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801075:	e8 d8 fe ff ff       	call   800f52 <syscall>
}
  80107a:	c9                   	leave  
  80107b:	c3                   	ret    

0080107c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801082:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801089:	00 
  80108a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801091:	00 
  801092:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801099:	00 
  80109a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010a1:	00 
  8010a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010a9:	00 
  8010aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010b1:	00 
  8010b2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8010b9:	e8 94 fe ff ff       	call   800f52 <syscall>
}
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <sys_yield>:

void
sys_yield(void)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8010c6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010cd:	00 
  8010ce:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010d5:	00 
  8010d6:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010dd:	00 
  8010de:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010e5:	00 
  8010e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010ed:	00 
  8010ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010f5:	00 
  8010f6:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8010fd:	e8 50 fe ff ff       	call   800f52 <syscall>
}
  801102:	c9                   	leave  
  801103:	c3                   	ret    

00801104 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80110a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80110d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801110:	8b 45 08             	mov    0x8(%ebp),%eax
  801113:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80111a:	00 
  80111b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801122:	00 
  801123:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801127:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80112b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80112f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801136:	00 
  801137:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80113e:	e8 0f fe ff ff       	call   800f52 <syscall>
}
  801143:	c9                   	leave  
  801144:	c3                   	ret    

00801145 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	56                   	push   %esi
  801149:	53                   	push   %ebx
  80114a:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80114d:	8b 75 18             	mov    0x18(%ebp),%esi
  801150:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801153:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801156:	8b 55 0c             	mov    0xc(%ebp),%edx
  801159:	8b 45 08             	mov    0x8(%ebp),%eax
  80115c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801160:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  801164:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801168:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80116c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801170:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801177:	00 
  801178:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  80117f:	e8 ce fd ff ff       	call   800f52 <syscall>
}
  801184:	83 c4 20             	add    $0x20,%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5d                   	pop    %ebp
  80118a:	c3                   	ret    

0080118b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
  80118e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801191:	8b 55 0c             	mov    0xc(%ebp),%edx
  801194:	8b 45 08             	mov    0x8(%ebp),%eax
  801197:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80119e:	00 
  80119f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011a6:	00 
  8011a7:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011ae:	00 
  8011af:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011be:	00 
  8011bf:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  8011c6:	e8 87 fd ff ff       	call   800f52 <syscall>
}
  8011cb:	c9                   	leave  
  8011cc:	c3                   	ret    

008011cd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8011d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011e0:	00 
  8011e1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011e8:	00 
  8011e9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011f0:	00 
  8011f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801200:	00 
  801201:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801208:	e8 45 fd ff ff       	call   800f52 <syscall>
}
  80120d:	c9                   	leave  
  80120e:	c3                   	ret    

0080120f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801215:	8b 55 0c             	mov    0xc(%ebp),%edx
  801218:	8b 45 08             	mov    0x8(%ebp),%eax
  80121b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801222:	00 
  801223:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80122a:	00 
  80122b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801232:	00 
  801233:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801237:	89 44 24 08          	mov    %eax,0x8(%esp)
  80123b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801242:	00 
  801243:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80124a:	e8 03 fd ff ff       	call   800f52 <syscall>
}
  80124f:	c9                   	leave  
  801250:	c3                   	ret    

00801251 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801257:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80125a:	8b 55 10             	mov    0x10(%ebp),%edx
  80125d:	8b 45 08             	mov    0x8(%ebp),%eax
  801260:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801267:	00 
  801268:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80126c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801270:	8b 55 0c             	mov    0xc(%ebp),%edx
  801273:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801277:	89 44 24 08          	mov    %eax,0x8(%esp)
  80127b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801282:	00 
  801283:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  80128a:	e8 c3 fc ff ff       	call   800f52 <syscall>
}
  80128f:	c9                   	leave  
  801290:	c3                   	ret    

00801291 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801297:	8b 45 08             	mov    0x8(%ebp),%eax
  80129a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8012a1:	00 
  8012a2:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8012a9:	00 
  8012aa:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8012b1:	00 
  8012b2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012b9:	00 
  8012ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8012c5:	00 
  8012c6:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8012cd:	e8 80 fc ff ff       	call   800f52 <syscall>
}
  8012d2:	c9                   	leave  
  8012d3:	c3                   	ret    

008012d4 <pgfault>:
// map in our own private writable copy.
//

static void
pgfault(struct UTrapframe *utf)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  8012da:	8b 45 08             	mov    0x8(%ebp),%eax
  8012dd:	8b 00                	mov    (%eax),%eax
  8012df:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  8012e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e5:	8b 40 04             	mov    0x4(%eax),%eax
  8012e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t t = PGNUM(addr);
  8012eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ee:	c1 e8 0c             	shr    $0xc,%eax
  8012f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	pte_t pte = uvpt[t];
  8012f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8012f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012fe:	89 45 e8             	mov    %eax,-0x18(%ebp)
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  801301:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801304:	83 e0 02             	and    $0x2,%eax
  801307:	85 c0                	test   %eax,%eax
  801309:	74 0c                	je     801317 <pgfault+0x43>
  80130b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80130e:	25 00 08 00 00       	and    $0x800,%eax
  801313:	85 c0                	test   %eax,%eax
  801315:	75 1c                	jne    801333 <pgfault+0x5f>
		panic("permission denied in copy on write pgfault handler\n");
  801317:	c7 44 24 08 d0 1f 80 	movl   $0x801fd0,0x8(%esp)
  80131e:	00 
  80131f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801326:	00 
  801327:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  80132e:	e8 ea 05 00 00       	call   80191d <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	r = sys_page_alloc(0,PFTEMP,PTE_P|PTE_U|PTE_W);
  801333:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80133a:	00 
  80133b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801342:	00 
  801343:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80134a:	e8 b5 fd ff ff       	call   801104 <sys_page_alloc>
  80134f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if(r < 0)
  801352:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801356:	79 1c                	jns    801374 <pgfault+0xa0>
	{
		panic("page cant be allocated\n");
  801358:	c7 44 24 08 0f 20 80 	movl   $0x80200f,0x8(%esp)
  80135f:	00 
  801360:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801367:	00 
  801368:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  80136f:	e8 a9 05 00 00       	call   80191d <_panic>
	}
	memmove(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  801374:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801377:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80137a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80137d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801382:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801389:	00 
  80138a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138e:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801395:	e8 d4 f8 ff ff       	call   800c6e <memmove>
	int r1 = sys_page_map(0,PFTEMP,0,ROUNDDOWN(addr,PGSIZE),PTE_W|PTE_U|PTE_P);
  80139a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8013a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013a3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013a8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8013af:	00 
  8013b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013bb:	00 
  8013bc:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013c3:	00 
  8013c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013cb:	e8 75 fd ff ff       	call   801145 <sys_page_map>
  8013d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if(r1 < 0)
  8013d3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013d7:	79 1c                	jns    8013f5 <pgfault+0x121>
	{
		panic("page cant be mapped\n");
  8013d9:	c7 44 24 08 27 20 80 	movl   $0x802027,0x8(%esp)
  8013e0:	00 
  8013e1:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  8013e8:	00 
  8013e9:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  8013f0:	e8 28 05 00 00       	call   80191d <_panic>
	}	

	// panic("pgfault not implemented");
}
  8013f5:	c9                   	leave  
  8013f6:	c3                   	ret    

008013f7 <duppage>:
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
static int
duppage(envid_t envid, unsigned pn)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	83 ec 48             	sub    $0x48,%esp
	int r;
	
	// LAB 4: Your code here.
	uint32_t t = uvpt[pn];
  8013fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801400:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801407:	89 45 f4             	mov    %eax,-0xc(%ebp)
	void *va_pn = (void *)(pn*PGSIZE);
  80140a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140d:	c1 e0 0c             	shl    $0xc,%eax
  801410:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if((t && PTE_W) || (t && PTE_COW))
  801413:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801417:	75 0a                	jne    801423 <duppage+0x2c>
  801419:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80141d:	0f 84 ed 00 00 00    	je     801510 <duppage+0x119>
	{
		r = sys_page_map(0,va_pn,envid,va_pn,PTE_P|PTE_U|PTE_COW);
  801423:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80142a:	00 
  80142b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801432:	8b 45 08             	mov    0x8(%ebp),%eax
  801435:	89 44 24 08          	mov    %eax,0x8(%esp)
  801439:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801440:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801447:	e8 f9 fc ff ff       	call   801145 <sys_page_map>
  80144c:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if(r < 0)
  80144f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801453:	79 1c                	jns    801471 <duppage+0x7a>
		{
			panic("error in page map\n");
  801455:	c7 44 24 08 3c 20 80 	movl   $0x80203c,0x8(%esp)
  80145c:	00 
  80145d:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  801464:	00 
  801465:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  80146c:	e8 ac 04 00 00       	call   80191d <_panic>
		}
		int r1 = sys_page_map(envid,va_pn,0,va_pn,PTE_P|PTE_U|PTE_COW);
  801471:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801478:	00 
  801479:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801480:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801487:	00 
  801488:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148f:	8b 45 08             	mov    0x8(%ebp),%eax
  801492:	89 04 24             	mov    %eax,(%esp)
  801495:	e8 ab fc ff ff       	call   801145 <sys_page_map>
  80149a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if(r1 < 0)
  80149d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8014a1:	79 1c                	jns    8014bf <duppage+0xc8>
		{
			panic("error in page map\n");
  8014a3:	c7 44 24 08 3c 20 80 	movl   $0x80203c,0x8(%esp)
  8014aa:	00 
  8014ab:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8014b2:	00 
  8014b3:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  8014ba:	e8 5e 04 00 00       	call   80191d <_panic>
		}
		int r2 = sys_page_map(0,va_pn,0,va_pn,PTE_P|PTE_U|PTE_COW);
  8014bf:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8014c6:	00 
  8014c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014d5:	00 
  8014d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e4:	e8 5c fc ff ff       	call   801145 <sys_page_map>
  8014e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if(r2 < 0)
  8014ec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8014f0:	79 1c                	jns    80150e <duppage+0x117>
		{
			panic("error in page map\n");
  8014f2:	c7 44 24 08 3c 20 80 	movl   $0x80203c,0x8(%esp)
  8014f9:	00 
  8014fa:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801501:	00 
  801502:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  801509:	e8 0f 04 00 00       	call   80191d <_panic>
	
	// LAB 4: Your code here.
	uint32_t t = uvpt[pn];
	void *va_pn = (void *)(pn*PGSIZE);
	if((t && PTE_W) || (t && PTE_COW))
	{
  80150e:	eb 4e                	jmp    80155e <duppage+0x167>
			panic("error in page map\n");
		}
	}
	else
	{
		int r3 = sys_page_map(0,va_pn,envid,va_pn,PTE_U|PTE_P);
  801510:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801517:	00 
  801518:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80151f:	8b 45 08             	mov    0x8(%ebp),%eax
  801522:	89 44 24 08          	mov    %eax,0x8(%esp)
  801526:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801534:	e8 0c fc ff ff       	call   801145 <sys_page_map>
  801539:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if(r3 < 0)
  80153c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801540:	79 1c                	jns    80155e <duppage+0x167>
		{
			panic("error in page map\n");
  801542:	c7 44 24 08 3c 20 80 	movl   $0x80203c,0x8(%esp)
  801549:	00 
  80154a:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  801551:	00 
  801552:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  801559:	e8 bf 03 00 00       	call   80191d <_panic>
		}
	}
	// panic("duppage not implemented");
	return 0;
  80155e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801563:	c9                   	leave  
  801564:	c3                   	ret    

00801565 <fork>:


envid_t
fork(void)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	83 ec 38             	sub    $0x38,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80156b:	c7 04 24 d4 12 80 00 	movl   $0x8012d4,(%esp)
  801572:	e8 01 04 00 00       	call   801978 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801577:	b8 07 00 00 00       	mov    $0x7,%eax
  80157c:	cd 30                	int    $0x30
  80157e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  801581:	8b 45 e0             	mov    -0x20(%ebp),%eax
	envid_t envid = sys_exofork();
  801584:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (envid < 0)
  801587:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80158b:	79 1c                	jns    8015a9 <fork+0x44>
	{
		panic("sys_exofork not succeeded\n");
  80158d:	c7 44 24 08 4f 20 80 	movl   $0x80204f,0x8(%esp)
  801594:	00 
  801595:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  80159c:	00 
  80159d:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  8015a4:	e8 74 03 00 00       	call   80191d <_panic>
	}
	if (envid == 0)
  8015a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8015ad:	75 29                	jne    8015d8 <fork+0x73>
	{	
		thisenv = &envs[ENVX(sys_getenvid())];
  8015af:	e8 c8 fa ff ff       	call   80107c <sys_getenvid>
  8015b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015b9:	c1 e0 02             	shl    $0x2,%eax
  8015bc:	89 c2                	mov    %eax,%edx
  8015be:	c1 e2 05             	shl    $0x5,%edx
  8015c1:	29 c2                	sub    %eax,%edx
  8015c3:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8015c9:	a3 0c 30 80 00       	mov    %eax,0x80300c
		return 0;
  8015ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d3:	e9 2b 01 00 00       	jmp    801703 <fork+0x19e>
	}
	else
	{
		int p;
		for (p = 0; p < PGNUM(UTOP); p++) 
  8015d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8015df:	e9 9a 00 00 00       	jmp    80167e <fork+0x119>
		{
			if(p == PGNUM(UTOP) - 1)
  8015e4:	81 7d f4 ff eb 0e 00 	cmpl   $0xeebff,-0xc(%ebp)
  8015eb:	75 42                	jne    80162f <fork+0xca>
			{
				int r1 = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE), PTE_P|PTE_W|PTE_U);
  8015ed:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015f4:	00 
  8015f5:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015fc:	ee 
  8015fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801600:	89 04 24             	mov    %eax,(%esp)
  801603:	e8 fc fa ff ff       	call   801104 <sys_page_alloc>
  801608:	89 45 ec             	mov    %eax,-0x14(%ebp)
  				if(r1 < 0)
  80160b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80160f:	79 1c                	jns    80162d <fork+0xc8>
  				{
    				panic("sys_page_alloc failed\n");
  801611:	c7 44 24 08 6a 20 80 	movl   $0x80206a,0x8(%esp)
  801618:	00 
  801619:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801620:	00 
  801621:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  801628:	e8 f0 02 00 00       	call   80191d <_panic>
				}
				break;
  80162d:	eb 5d                	jmp    80168c <fork+0x127>
			}
			if((uvpd[PDX(p*PGSIZE)]&PTE_P))
  80162f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801632:	c1 e0 0c             	shl    $0xc,%eax
  801635:	c1 e8 16             	shr    $0x16,%eax
  801638:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80163f:	83 e0 01             	and    $0x1,%eax
  801642:	85 c0                	test   %eax,%eax
  801644:	74 34                	je     80167a <fork+0x115>
			{
				if((uvpt[p]&PTE_P) && (uvpt[p] & PTE_U))
  801646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801649:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801650:	83 e0 01             	and    $0x1,%eax
  801653:	85 c0                	test   %eax,%eax
  801655:	74 23                	je     80167a <fork+0x115>
  801657:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801661:	83 e0 04             	and    $0x4,%eax
  801664:	85 c0                	test   %eax,%eax
  801666:	74 12                	je     80167a <fork+0x115>
				{
					duppage(envid, p);
  801668:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801672:	89 04 24             	mov    %eax,(%esp)
  801675:	e8 7d fd ff ff       	call   8013f7 <duppage>
		return 0;
	}
	else
	{
		int p;
		for (p = 0; p < PGNUM(UTOP); p++) 
  80167a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  80167e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801681:	3d ff eb 0e 00       	cmp    $0xeebff,%eax
  801686:	0f 86 58 ff ff ff    	jbe    8015e4 <fork+0x7f>
				}
			}	
		}
  		
		extern void _pgfault_upcall();
		int r = sys_env_set_pgfault_upcall(envid,thisenv->env_pgfault_upcall);
  80168c:	a1 0c 30 80 00       	mov    0x80300c,%eax
  801691:	8b 40 64             	mov    0x64(%eax),%eax
  801694:	89 44 24 04          	mov    %eax,0x4(%esp)
  801698:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169b:	89 04 24             	mov    %eax,(%esp)
  80169e:	e8 6c fb ff ff       	call   80120f <sys_env_set_pgfault_upcall>
  8016a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    	if(r < 0)
  8016a6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8016aa:	79 1c                	jns    8016c8 <fork+0x163>
    	{
    		panic("sys_env_set_pgfault_upcall failed\n");
  8016ac:	c7 44 24 08 84 20 80 	movl   $0x802084,0x8(%esp)
  8016b3:	00 
  8016b4:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  8016bb:	00 
  8016bc:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  8016c3:	e8 55 02 00 00       	call   80191d <_panic>
    	}
  		int r2 = sys_env_set_status(envid, ENV_RUNNABLE);
  8016c8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8016cf:	00 
  8016d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d3:	89 04 24             	mov    %eax,(%esp)
  8016d6:	e8 f2 fa ff ff       	call   8011cd <sys_env_set_status>
  8016db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  		if(r2 < 0)
  8016de:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8016e2:	79 1c                	jns    801700 <fork+0x19b>
  		{
    		panic("sys_env_set_status failes\n");
  8016e4:	c7 44 24 08 a7 20 80 	movl   $0x8020a7,0x8(%esp)
  8016eb:	00 
  8016ec:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  8016f3:	00 
  8016f4:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  8016fb:	e8 1d 02 00 00       	call   80191d <_panic>
    	}
  		return envid;
  801700:	8b 45 f0             	mov    -0x10(%ebp),%eax
	}


	// panic("fork not implemented");
}
  801703:	c9                   	leave  
  801704:	c3                   	ret    

00801705 <sfork>:


// Challenge!
int
sfork(void)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80170b:	c7 44 24 08 c2 20 80 	movl   $0x8020c2,0x8(%esp)
  801712:	00 
  801713:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
  80171a:	00 
  80171b:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  801722:	e8 f6 01 00 00       	call   80191d <_panic>

00801727 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int r;
	if(pg != NULL)
  80172d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801731:	74 10                	je     801743 <ipc_recv+0x1c>
	{
		r = sys_ipc_recv(pg);
  801733:	8b 45 0c             	mov    0xc(%ebp),%eax
  801736:	89 04 24             	mov    %eax,(%esp)
  801739:	e8 53 fb ff ff       	call   801291 <sys_ipc_recv>
  80173e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801741:	eb 0f                	jmp    801752 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  801743:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80174a:	e8 42 fb ff ff       	call   801291 <sys_ipc_recv>
  80174f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}

	if(from_env_store != NULL && r == 0) 
  801752:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801756:	74 13                	je     80176b <ipc_recv+0x44>
  801758:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80175c:	75 0d                	jne    80176b <ipc_recv+0x44>
	{
		*from_env_store = thisenv->env_ipc_from;
  80175e:	a1 0c 30 80 00       	mov    0x80300c,%eax
  801763:	8b 50 74             	mov    0x74(%eax),%edx
  801766:	8b 45 08             	mov    0x8(%ebp),%eax
  801769:	89 10                	mov    %edx,(%eax)
	}
	if(from_env_store != NULL && r < 0)
  80176b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80176f:	74 0f                	je     801780 <ipc_recv+0x59>
  801771:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801775:	79 09                	jns    801780 <ipc_recv+0x59>
	{
		*from_env_store = 0;
  801777:	8b 45 08             	mov    0x8(%ebp),%eax
  80177a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}

	if(perm_store != NULL)
  801780:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801784:	74 28                	je     8017ae <ipc_recv+0x87>
	{
		if(r==0 && (uint32_t)pg<UTOP)
  801786:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80178a:	75 19                	jne    8017a5 <ipc_recv+0x7e>
  80178c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178f:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
  801794:	77 0f                	ja     8017a5 <ipc_recv+0x7e>
		{
			*perm_store = thisenv->env_ipc_perm;
  801796:	a1 0c 30 80 00       	mov    0x80300c,%eax
  80179b:	8b 50 78             	mov    0x78(%eax),%edx
  80179e:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a1:	89 10                	mov    %edx,(%eax)
  8017a3:	eb 09                	jmp    8017ae <ipc_recv+0x87>
		}
		else
		{
			*perm_store = 0;
  8017a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		}
	}
	if (r == 0)
  8017ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8017b2:	75 0a                	jne    8017be <ipc_recv+0x97>
	{
    	return thisenv->env_ipc_value;
  8017b4:	a1 0c 30 80 00       	mov    0x80300c,%eax
  8017b9:	8b 40 70             	mov    0x70(%eax),%eax
  8017bc:	eb 03                	jmp    8017c1 <ipc_recv+0x9a>
    } 
  	else
  	{
    	return r;
  8017be:	8b 45 f4             	mov    -0xc(%ebp),%eax
    }
	// panic("ipc_recv not implemented");
	// return 0;
}
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int r;
	if(pg == NULL)
  8017c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017cd:	75 4c                	jne    80181b <ipc_send+0x58>
	{
		r = sys_ipc_try_send(to_env,val,(void *)UTOP, perm);
  8017cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017d6:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8017dd:	ee 
  8017de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	89 04 24             	mov    %eax,(%esp)
  8017eb:	e8 61 fa ff ff       	call   801251 <sys_ipc_try_send>
  8017f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	if (r != 0 && r != -E_IPC_NOT_RECV)
  8017f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8017f7:	74 6e                	je     801867 <ipc_send+0xa4>
  8017f9:	83 7d f4 f8          	cmpl   $0xfffffff8,-0xc(%ebp)
  8017fd:	74 68                	je     801867 <ipc_send+0xa4>
    	{
    		panic("in ipc_send\n");
  8017ff:	c7 44 24 08 d8 20 80 	movl   $0x8020d8,0x8(%esp)
  801806:	00 
  801807:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  80180e:	00 
  80180f:	c7 04 24 e5 20 80 00 	movl   $0x8020e5,(%esp)
  801816:	e8 02 01 00 00       	call   80191d <_panic>
    	} 
	}
	else
	{
		r = sys_ipc_try_send(to_env,val,(void *)UTOP, perm);
  80181b:	8b 45 14             	mov    0x14(%ebp),%eax
  80181e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801822:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801829:	ee 
  80182a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801831:	8b 45 08             	mov    0x8(%ebp),%eax
  801834:	89 04 24             	mov    %eax,(%esp)
  801837:	e8 15 fa ff ff       	call   801251 <sys_ipc_try_send>
  80183c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	if (r != 0 && r != -E_IPC_NOT_RECV)
  80183f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801843:	74 22                	je     801867 <ipc_send+0xa4>
  801845:	83 7d f4 f8          	cmpl   $0xfffffff8,-0xc(%ebp)
  801849:	74 1c                	je     801867 <ipc_send+0xa4>
    	{
    		panic("in ipc_send\n");
  80184b:	c7 44 24 08 d8 20 80 	movl   $0x8020d8,0x8(%esp)
  801852:	00 
  801853:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
  80185a:	00 
  80185b:	c7 04 24 e5 20 80 00 	movl   $0x8020e5,(%esp)
  801862:	e8 b6 00 00 00       	call   80191d <_panic>
    	}	
	}
	while(r != 0)
  801867:	eb 58                	jmp    8018c1 <ipc_send+0xfe>
    //cprintf("[%x]ipc_send\n", thisenv->env_id);
	{
    	r = sys_ipc_try_send(to_env, val, pg ? pg : (void*)UTOP, perm);
  801869:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80186d:	74 05                	je     801874 <ipc_send+0xb1>
  80186f:	8b 45 10             	mov    0x10(%ebp),%eax
  801872:	eb 05                	jmp    801879 <ipc_send+0xb6>
  801874:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801879:	8b 55 14             	mov    0x14(%ebp),%edx
  80187c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801880:	89 44 24 08          	mov    %eax,0x8(%esp)
  801884:	8b 45 0c             	mov    0xc(%ebp),%eax
  801887:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	89 04 24             	mov    %eax,(%esp)
  801891:	e8 bb f9 ff ff       	call   801251 <sys_ipc_try_send>
  801896:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	if (r != 0 && r != -E_IPC_NOT_RECV) 
  801899:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80189d:	74 22                	je     8018c1 <ipc_send+0xfe>
  80189f:	83 7d f4 f8          	cmpl   $0xfffffff8,-0xc(%ebp)
  8018a3:	74 1c                	je     8018c1 <ipc_send+0xfe>
    	{
      		panic("in ipc_send\n");
  8018a5:	c7 44 24 08 d8 20 80 	movl   $0x8020d8,0x8(%esp)
  8018ac:	00 
  8018ad:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8018b4:	00 
  8018b5:	c7 04 24 e5 20 80 00 	movl   $0x8020e5,(%esp)
  8018bc:	e8 5c 00 00 00       	call   80191d <_panic>
    	if (r != 0 && r != -E_IPC_NOT_RECV)
    	{
    		panic("in ipc_send\n");
    	}	
	}
	while(r != 0)
  8018c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8018c5:	75 a2                	jne    801869 <ipc_send+0xa6>
    	{
      		panic("in ipc_send\n");
    	}
    } 
	// panic("ipc_send not implemented");
}
  8018c7:	c9                   	leave  
  8018c8:	c3                   	ret    

008018c9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  8018cf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8018d6:	eb 35                	jmp    80190d <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  8018d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018db:	c1 e0 02             	shl    $0x2,%eax
  8018de:	89 c2                	mov    %eax,%edx
  8018e0:	c1 e2 05             	shl    $0x5,%edx
  8018e3:	29 c2                	sub    %eax,%edx
  8018e5:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  8018eb:	8b 00                	mov    (%eax),%eax
  8018ed:	3b 45 08             	cmp    0x8(%ebp),%eax
  8018f0:	75 17                	jne    801909 <ipc_find_env+0x40>
			return envs[i].env_id;
  8018f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018f5:	c1 e0 02             	shl    $0x2,%eax
  8018f8:	89 c2                	mov    %eax,%edx
  8018fa:	c1 e2 05             	shl    $0x5,%edx
  8018fd:	29 c2                	sub    %eax,%edx
  8018ff:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  801905:	8b 00                	mov    (%eax),%eax
  801907:	eb 12                	jmp    80191b <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801909:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80190d:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  801914:	7e c2                	jle    8018d8 <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801916:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191b:	c9                   	leave  
  80191c:	c3                   	ret    

0080191d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	53                   	push   %ebx
  801921:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  801924:	8d 45 14             	lea    0x14(%ebp),%eax
  801927:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80192a:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  801930:	e8 47 f7 ff ff       	call   80107c <sys_getenvid>
  801935:	8b 55 0c             	mov    0xc(%ebp),%edx
  801938:	89 54 24 10          	mov    %edx,0x10(%esp)
  80193c:	8b 55 08             	mov    0x8(%ebp),%edx
  80193f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801943:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801947:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194b:	c7 04 24 f0 20 80 00 	movl   $0x8020f0,(%esp)
  801952:	e8 b7 e9 ff ff       	call   80030e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195e:	8b 45 10             	mov    0x10(%ebp),%eax
  801961:	89 04 24             	mov    %eax,(%esp)
  801964:	e8 41 e9 ff ff       	call   8002aa <vcprintf>
	cprintf("\n");
  801969:	c7 04 24 13 21 80 00 	movl   $0x802113,(%esp)
  801970:	e8 99 e9 ff ff       	call   80030e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801975:	cc                   	int3   
  801976:	eb fd                	jmp    801975 <_panic+0x58>

00801978 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  80197e:	a1 10 30 80 00       	mov    0x803010,%eax
  801983:	85 c0                	test   %eax,%eax
  801985:	75 55                	jne    8019dc <set_pgfault_handler+0x64>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE),PTE_U|PTE_P|PTE_W);
  801987:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80198e:	00 
  80198f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801996:	ee 
  801997:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199e:	e8 61 f7 ff ff       	call   801104 <sys_page_alloc>
  8019a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(r < 0)
  8019a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8019aa:	79 1c                	jns    8019c8 <set_pgfault_handler+0x50>
		{
			panic("sys_page_alloc_failed");
  8019ac:	c7 44 24 08 15 21 80 	movl   $0x802115,0x8(%esp)
  8019b3:	00 
  8019b4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8019bb:	00 
  8019bc:	c7 04 24 2b 21 80 00 	movl   $0x80212b,(%esp)
  8019c3:	e8 55 ff ff ff       	call   80191d <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8019c8:	c7 44 24 04 e6 19 80 	movl   $0x8019e6,0x4(%esp)
  8019cf:	00 
  8019d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d7:	e8 33 f8 ff ff       	call   80120f <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8019dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019df:	a3 10 30 80 00       	mov    %eax,0x803010
}
  8019e4:	c9                   	leave  
  8019e5:	c3                   	ret    

008019e6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8019e6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8019e7:	a1 10 30 80 00       	mov    0x803010,%eax
	call *%eax
  8019ec:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8019ee:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  8019f1:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  8019f5:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8019f8:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 0x28(%esp), %ecx
  8019fc:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  801a00:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//add $8, %esp
	popl %edx 
  801a02:	5a                   	pop    %edx
	popl %edx
  801a03:	5a                   	pop    %edx
	popal
  801a04:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  801a05:	83 c4 04             	add    $0x4,%esp
	popf
  801a08:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801a09:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801a0a:	c3                   	ret    
  801a0b:	66 90                	xchg   %ax,%ax
  801a0d:	66 90                	xchg   %ax,%ax
  801a0f:	90                   	nop

00801a10 <__udivdi3>:
  801a10:	55                   	push   %ebp
  801a11:	57                   	push   %edi
  801a12:	56                   	push   %esi
  801a13:	83 ec 0c             	sub    $0xc,%esp
  801a16:	8b 44 24 28          	mov    0x28(%esp),%eax
  801a1a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801a1e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801a22:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801a26:	85 c0                	test   %eax,%eax
  801a28:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a2c:	89 ea                	mov    %ebp,%edx
  801a2e:	89 0c 24             	mov    %ecx,(%esp)
  801a31:	75 2d                	jne    801a60 <__udivdi3+0x50>
  801a33:	39 e9                	cmp    %ebp,%ecx
  801a35:	77 61                	ja     801a98 <__udivdi3+0x88>
  801a37:	85 c9                	test   %ecx,%ecx
  801a39:	89 ce                	mov    %ecx,%esi
  801a3b:	75 0b                	jne    801a48 <__udivdi3+0x38>
  801a3d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a42:	31 d2                	xor    %edx,%edx
  801a44:	f7 f1                	div    %ecx
  801a46:	89 c6                	mov    %eax,%esi
  801a48:	31 d2                	xor    %edx,%edx
  801a4a:	89 e8                	mov    %ebp,%eax
  801a4c:	f7 f6                	div    %esi
  801a4e:	89 c5                	mov    %eax,%ebp
  801a50:	89 f8                	mov    %edi,%eax
  801a52:	f7 f6                	div    %esi
  801a54:	89 ea                	mov    %ebp,%edx
  801a56:	83 c4 0c             	add    $0xc,%esp
  801a59:	5e                   	pop    %esi
  801a5a:	5f                   	pop    %edi
  801a5b:	5d                   	pop    %ebp
  801a5c:	c3                   	ret    
  801a5d:	8d 76 00             	lea    0x0(%esi),%esi
  801a60:	39 e8                	cmp    %ebp,%eax
  801a62:	77 24                	ja     801a88 <__udivdi3+0x78>
  801a64:	0f bd e8             	bsr    %eax,%ebp
  801a67:	83 f5 1f             	xor    $0x1f,%ebp
  801a6a:	75 3c                	jne    801aa8 <__udivdi3+0x98>
  801a6c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801a70:	39 34 24             	cmp    %esi,(%esp)
  801a73:	0f 86 9f 00 00 00    	jbe    801b18 <__udivdi3+0x108>
  801a79:	39 d0                	cmp    %edx,%eax
  801a7b:	0f 82 97 00 00 00    	jb     801b18 <__udivdi3+0x108>
  801a81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801a88:	31 d2                	xor    %edx,%edx
  801a8a:	31 c0                	xor    %eax,%eax
  801a8c:	83 c4 0c             	add    $0xc,%esp
  801a8f:	5e                   	pop    %esi
  801a90:	5f                   	pop    %edi
  801a91:	5d                   	pop    %ebp
  801a92:	c3                   	ret    
  801a93:	90                   	nop
  801a94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a98:	89 f8                	mov    %edi,%eax
  801a9a:	f7 f1                	div    %ecx
  801a9c:	31 d2                	xor    %edx,%edx
  801a9e:	83 c4 0c             	add    $0xc,%esp
  801aa1:	5e                   	pop    %esi
  801aa2:	5f                   	pop    %edi
  801aa3:	5d                   	pop    %ebp
  801aa4:	c3                   	ret    
  801aa5:	8d 76 00             	lea    0x0(%esi),%esi
  801aa8:	89 e9                	mov    %ebp,%ecx
  801aaa:	8b 3c 24             	mov    (%esp),%edi
  801aad:	d3 e0                	shl    %cl,%eax
  801aaf:	89 c6                	mov    %eax,%esi
  801ab1:	b8 20 00 00 00       	mov    $0x20,%eax
  801ab6:	29 e8                	sub    %ebp,%eax
  801ab8:	89 c1                	mov    %eax,%ecx
  801aba:	d3 ef                	shr    %cl,%edi
  801abc:	89 e9                	mov    %ebp,%ecx
  801abe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801ac2:	8b 3c 24             	mov    (%esp),%edi
  801ac5:	09 74 24 08          	or     %esi,0x8(%esp)
  801ac9:	89 d6                	mov    %edx,%esi
  801acb:	d3 e7                	shl    %cl,%edi
  801acd:	89 c1                	mov    %eax,%ecx
  801acf:	89 3c 24             	mov    %edi,(%esp)
  801ad2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ad6:	d3 ee                	shr    %cl,%esi
  801ad8:	89 e9                	mov    %ebp,%ecx
  801ada:	d3 e2                	shl    %cl,%edx
  801adc:	89 c1                	mov    %eax,%ecx
  801ade:	d3 ef                	shr    %cl,%edi
  801ae0:	09 d7                	or     %edx,%edi
  801ae2:	89 f2                	mov    %esi,%edx
  801ae4:	89 f8                	mov    %edi,%eax
  801ae6:	f7 74 24 08          	divl   0x8(%esp)
  801aea:	89 d6                	mov    %edx,%esi
  801aec:	89 c7                	mov    %eax,%edi
  801aee:	f7 24 24             	mull   (%esp)
  801af1:	39 d6                	cmp    %edx,%esi
  801af3:	89 14 24             	mov    %edx,(%esp)
  801af6:	72 30                	jb     801b28 <__udivdi3+0x118>
  801af8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801afc:	89 e9                	mov    %ebp,%ecx
  801afe:	d3 e2                	shl    %cl,%edx
  801b00:	39 c2                	cmp    %eax,%edx
  801b02:	73 05                	jae    801b09 <__udivdi3+0xf9>
  801b04:	3b 34 24             	cmp    (%esp),%esi
  801b07:	74 1f                	je     801b28 <__udivdi3+0x118>
  801b09:	89 f8                	mov    %edi,%eax
  801b0b:	31 d2                	xor    %edx,%edx
  801b0d:	e9 7a ff ff ff       	jmp    801a8c <__udivdi3+0x7c>
  801b12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b18:	31 d2                	xor    %edx,%edx
  801b1a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b1f:	e9 68 ff ff ff       	jmp    801a8c <__udivdi3+0x7c>
  801b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b28:	8d 47 ff             	lea    -0x1(%edi),%eax
  801b2b:	31 d2                	xor    %edx,%edx
  801b2d:	83 c4 0c             	add    $0xc,%esp
  801b30:	5e                   	pop    %esi
  801b31:	5f                   	pop    %edi
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    
  801b34:	66 90                	xchg   %ax,%ax
  801b36:	66 90                	xchg   %ax,%ax
  801b38:	66 90                	xchg   %ax,%ax
  801b3a:	66 90                	xchg   %ax,%ax
  801b3c:	66 90                	xchg   %ax,%ax
  801b3e:	66 90                	xchg   %ax,%ax

00801b40 <__umoddi3>:
  801b40:	55                   	push   %ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	83 ec 14             	sub    $0x14,%esp
  801b46:	8b 44 24 28          	mov    0x28(%esp),%eax
  801b4a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801b4e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801b52:	89 c7                	mov    %eax,%edi
  801b54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b58:	8b 44 24 30          	mov    0x30(%esp),%eax
  801b5c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801b60:	89 34 24             	mov    %esi,(%esp)
  801b63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b67:	85 c0                	test   %eax,%eax
  801b69:	89 c2                	mov    %eax,%edx
  801b6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b6f:	75 17                	jne    801b88 <__umoddi3+0x48>
  801b71:	39 fe                	cmp    %edi,%esi
  801b73:	76 4b                	jbe    801bc0 <__umoddi3+0x80>
  801b75:	89 c8                	mov    %ecx,%eax
  801b77:	89 fa                	mov    %edi,%edx
  801b79:	f7 f6                	div    %esi
  801b7b:	89 d0                	mov    %edx,%eax
  801b7d:	31 d2                	xor    %edx,%edx
  801b7f:	83 c4 14             	add    $0x14,%esp
  801b82:	5e                   	pop    %esi
  801b83:	5f                   	pop    %edi
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    
  801b86:	66 90                	xchg   %ax,%ax
  801b88:	39 f8                	cmp    %edi,%eax
  801b8a:	77 54                	ja     801be0 <__umoddi3+0xa0>
  801b8c:	0f bd e8             	bsr    %eax,%ebp
  801b8f:	83 f5 1f             	xor    $0x1f,%ebp
  801b92:	75 5c                	jne    801bf0 <__umoddi3+0xb0>
  801b94:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b98:	39 3c 24             	cmp    %edi,(%esp)
  801b9b:	0f 87 e7 00 00 00    	ja     801c88 <__umoddi3+0x148>
  801ba1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ba5:	29 f1                	sub    %esi,%ecx
  801ba7:	19 c7                	sbb    %eax,%edi
  801ba9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801bad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bb1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bb5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801bb9:	83 c4 14             	add    $0x14,%esp
  801bbc:	5e                   	pop    %esi
  801bbd:	5f                   	pop    %edi
  801bbe:	5d                   	pop    %ebp
  801bbf:	c3                   	ret    
  801bc0:	85 f6                	test   %esi,%esi
  801bc2:	89 f5                	mov    %esi,%ebp
  801bc4:	75 0b                	jne    801bd1 <__umoddi3+0x91>
  801bc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bcb:	31 d2                	xor    %edx,%edx
  801bcd:	f7 f6                	div    %esi
  801bcf:	89 c5                	mov    %eax,%ebp
  801bd1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801bd5:	31 d2                	xor    %edx,%edx
  801bd7:	f7 f5                	div    %ebp
  801bd9:	89 c8                	mov    %ecx,%eax
  801bdb:	f7 f5                	div    %ebp
  801bdd:	eb 9c                	jmp    801b7b <__umoddi3+0x3b>
  801bdf:	90                   	nop
  801be0:	89 c8                	mov    %ecx,%eax
  801be2:	89 fa                	mov    %edi,%edx
  801be4:	83 c4 14             	add    $0x14,%esp
  801be7:	5e                   	pop    %esi
  801be8:	5f                   	pop    %edi
  801be9:	5d                   	pop    %ebp
  801bea:	c3                   	ret    
  801beb:	90                   	nop
  801bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	8b 04 24             	mov    (%esp),%eax
  801bf3:	be 20 00 00 00       	mov    $0x20,%esi
  801bf8:	89 e9                	mov    %ebp,%ecx
  801bfa:	29 ee                	sub    %ebp,%esi
  801bfc:	d3 e2                	shl    %cl,%edx
  801bfe:	89 f1                	mov    %esi,%ecx
  801c00:	d3 e8                	shr    %cl,%eax
  801c02:	89 e9                	mov    %ebp,%ecx
  801c04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c08:	8b 04 24             	mov    (%esp),%eax
  801c0b:	09 54 24 04          	or     %edx,0x4(%esp)
  801c0f:	89 fa                	mov    %edi,%edx
  801c11:	d3 e0                	shl    %cl,%eax
  801c13:	89 f1                	mov    %esi,%ecx
  801c15:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c19:	8b 44 24 10          	mov    0x10(%esp),%eax
  801c1d:	d3 ea                	shr    %cl,%edx
  801c1f:	89 e9                	mov    %ebp,%ecx
  801c21:	d3 e7                	shl    %cl,%edi
  801c23:	89 f1                	mov    %esi,%ecx
  801c25:	d3 e8                	shr    %cl,%eax
  801c27:	89 e9                	mov    %ebp,%ecx
  801c29:	09 f8                	or     %edi,%eax
  801c2b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801c2f:	f7 74 24 04          	divl   0x4(%esp)
  801c33:	d3 e7                	shl    %cl,%edi
  801c35:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c39:	89 d7                	mov    %edx,%edi
  801c3b:	f7 64 24 08          	mull   0x8(%esp)
  801c3f:	39 d7                	cmp    %edx,%edi
  801c41:	89 c1                	mov    %eax,%ecx
  801c43:	89 14 24             	mov    %edx,(%esp)
  801c46:	72 2c                	jb     801c74 <__umoddi3+0x134>
  801c48:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801c4c:	72 22                	jb     801c70 <__umoddi3+0x130>
  801c4e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801c52:	29 c8                	sub    %ecx,%eax
  801c54:	19 d7                	sbb    %edx,%edi
  801c56:	89 e9                	mov    %ebp,%ecx
  801c58:	89 fa                	mov    %edi,%edx
  801c5a:	d3 e8                	shr    %cl,%eax
  801c5c:	89 f1                	mov    %esi,%ecx
  801c5e:	d3 e2                	shl    %cl,%edx
  801c60:	89 e9                	mov    %ebp,%ecx
  801c62:	d3 ef                	shr    %cl,%edi
  801c64:	09 d0                	or     %edx,%eax
  801c66:	89 fa                	mov    %edi,%edx
  801c68:	83 c4 14             	add    $0x14,%esp
  801c6b:	5e                   	pop    %esi
  801c6c:	5f                   	pop    %edi
  801c6d:	5d                   	pop    %ebp
  801c6e:	c3                   	ret    
  801c6f:	90                   	nop
  801c70:	39 d7                	cmp    %edx,%edi
  801c72:	75 da                	jne    801c4e <__umoddi3+0x10e>
  801c74:	8b 14 24             	mov    (%esp),%edx
  801c77:	89 c1                	mov    %eax,%ecx
  801c79:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801c7d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801c81:	eb cb                	jmp    801c4e <__umoddi3+0x10e>
  801c83:	90                   	nop
  801c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c88:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801c8c:	0f 82 0f ff ff ff    	jb     801ba1 <__umoddi3+0x61>
  801c92:	e9 1a ff ff ff       	jmp    801bb1 <__umoddi3+0x71>
