
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 40 01 00 00       	call   800171 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  800039:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800040:	00 
  800041:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800048:	00 
  800049:	8d 45 e8             	lea    -0x18(%ebp),%eax
  80004c:	89 04 24             	mov    %eax,(%esp)
  80004f:	e8 b3 16 00 00       	call   801707 <ipc_recv>
  800054:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800057:	a1 04 30 80 00       	mov    0x803004,%eax
  80005c:	8b 40 5c             	mov    0x5c(%eax),%eax
  80005f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800062:	89 54 24 08          	mov    %edx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 20 1c 80 00 	movl   $0x801c20,(%esp)
  800071:	e8 78 02 00 00       	call   8002ee <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 ca 14 00 00       	call   801545 <fork>
  80007b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80007e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800082:	79 23                	jns    8000a7 <primeproc+0x74>
		panic("fork: %e", id);
  800084:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800087:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80008b:	c7 44 24 08 2c 1c 80 	movl   $0x801c2c,0x8(%esp)
  800092:	00 
  800093:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80009a:	00 
  80009b:	c7 04 24 35 1c 80 00 	movl   $0x801c35,(%esp)
  8000a2:	e8 2c 01 00 00       	call   8001d3 <_panic>
	if (id == 0)
  8000a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8000ab:	75 02                	jne    8000af <primeproc+0x7c>
		goto top;
  8000ad:	eb 8a                	jmp    800039 <primeproc+0x6>

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b6:	00 
  8000b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000be:	00 
  8000bf:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8000c2:	89 04 24             	mov    %eax,(%esp)
  8000c5:	e8 3d 16 00 00       	call   801707 <ipc_recv>
  8000ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (i % p)
  8000cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8000d0:	99                   	cltd   
  8000d1:	f7 7d f4             	idivl  -0xc(%ebp)
  8000d4:	89 d0                	mov    %edx,%eax
  8000d6:	85 c0                	test   %eax,%eax
  8000d8:	74 24                	je     8000fe <primeproc+0xcb>
			ipc_send(id, i, 0, 0);
  8000da:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8000dd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ec:	00 
  8000ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000f4:	89 04 24             	mov    %eax,(%esp)
  8000f7:	e8 a7 16 00 00       	call   8017a3 <ipc_send>
	}
  8000fc:	eb b1                	jmp    8000af <primeproc+0x7c>
  8000fe:	eb af                	jmp    8000af <primeproc+0x7c>

00800100 <umain>:
}

void
umain(int argc, char **argv)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	83 ec 28             	sub    $0x28,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  800106:	e8 3a 14 00 00       	call   801545 <fork>
  80010b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80010e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800112:	79 23                	jns    800137 <umain+0x37>
		panic("fork: %e", id);
  800114:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800117:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011b:	c7 44 24 08 2c 1c 80 	movl   $0x801c2c,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 35 1c 80 00 	movl   $0x801c35,(%esp)
  800132:	e8 9c 00 00 00       	call   8001d3 <_panic>
	if (id == 0)
  800137:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80013b:	75 05                	jne    800142 <umain+0x42>
		primeproc();
  80013d:	e8 f1 fe ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
  800142:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
		ipc_send(id, i, 0, 0);
  800149:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80014c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800153:	00 
  800154:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80015b:	00 
  80015c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800160:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800163:	89 04 24             	mov    %eax,(%esp)
  800166:	e8 38 16 00 00       	call   8017a3 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  80016b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		ipc_send(id, i, 0, 0);
  80016f:	eb d8                	jmp    800149 <umain+0x49>

00800171 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800177:	e8 e0 0e 00 00       	call   80105c <sys_getenvid>
  80017c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800181:	c1 e0 02             	shl    $0x2,%eax
  800184:	89 c2                	mov    %eax,%edx
  800186:	c1 e2 05             	shl    $0x5,%edx
  800189:	29 c2                	sub    %eax,%edx
  80018b:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  800191:	a3 04 30 80 00       	mov    %eax,0x803004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800196:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80019a:	7e 0a                	jle    8001a6 <libmain+0x35>
		binaryname = argv[0];
  80019c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019f:	8b 00                	mov    (%eax),%eax
  8001a1:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b0:	89 04 24             	mov    %eax,(%esp)
  8001b3:	e8 48 ff ff ff       	call   800100 <umain>

	// exit gracefully
	exit();
  8001b8:	e8 02 00 00 00       	call   8001bf <exit>
}
  8001bd:	c9                   	leave  
  8001be:	c3                   	ret    

008001bf <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001cc:	e8 48 0e 00 00       	call   801019 <sys_env_destroy>
}
  8001d1:	c9                   	leave  
  8001d2:	c3                   	ret    

008001d3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	53                   	push   %ebx
  8001d7:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8001da:	8d 45 14             	lea    0x14(%ebp),%eax
  8001dd:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e0:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001e6:	e8 71 0e 00 00       	call   80105c <sys_getenvid>
  8001eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ee:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800201:	c7 04 24 50 1c 80 00 	movl   $0x801c50,(%esp)
  800208:	e8 e1 00 00 00       	call   8002ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800210:	89 44 24 04          	mov    %eax,0x4(%esp)
  800214:	8b 45 10             	mov    0x10(%ebp),%eax
  800217:	89 04 24             	mov    %eax,(%esp)
  80021a:	e8 6b 00 00 00       	call   80028a <vcprintf>
	cprintf("\n");
  80021f:	c7 04 24 73 1c 80 00 	movl   $0x801c73,(%esp)
  800226:	e8 c3 00 00 00       	call   8002ee <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80022b:	cc                   	int3   
  80022c:	eb fd                	jmp    80022b <_panic+0x58>

0080022e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	8b 00                	mov    (%eax),%eax
  800239:	8d 48 01             	lea    0x1(%eax),%ecx
  80023c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023f:	89 0a                	mov    %ecx,(%edx)
  800241:	8b 55 08             	mov    0x8(%ebp),%edx
  800244:	89 d1                	mov    %edx,%ecx
  800246:	8b 55 0c             	mov    0xc(%ebp),%edx
  800249:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  80024d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800250:	8b 00                	mov    (%eax),%eax
  800252:	3d ff 00 00 00       	cmp    $0xff,%eax
  800257:	75 20                	jne    800279 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800259:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025c:	8b 00                	mov    (%eax),%eax
  80025e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800261:	83 c2 08             	add    $0x8,%edx
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	89 14 24             	mov    %edx,(%esp)
  80026b:	e8 23 0d 00 00       	call   800f93 <sys_cputs>
		b->idx = 0;
  800270:	8b 45 0c             	mov    0xc(%ebp),%eax
  800273:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800279:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027c:	8b 40 04             	mov    0x4(%eax),%eax
  80027f:	8d 50 01             	lea    0x1(%eax),%edx
  800282:	8b 45 0c             	mov    0xc(%ebp),%eax
  800285:	89 50 04             	mov    %edx,0x4(%eax)
}
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800293:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80029a:	00 00 00 
	b.cnt = 0;
  80029d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002a4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bf:	c7 04 24 2e 02 80 00 	movl   $0x80022e,(%esp)
  8002c6:	e8 bd 01 00 00       	call   800488 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002cb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002db:	83 c0 08             	add    $0x8,%eax
  8002de:	89 04 24             	mov    %eax,(%esp)
  8002e1:	e8 ad 0c 00 00       	call   800f93 <sys_cputs>

	return b.cnt;
  8002e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f4:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8002fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	e8 7e ff ff ff       	call   80028a <vcprintf>
  80030c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80030f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	53                   	push   %ebx
  800318:	83 ec 34             	sub    $0x34,%esp
  80031b:	8b 45 10             	mov    0x10(%ebp),%eax
  80031e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800321:	8b 45 14             	mov    0x14(%ebp),%eax
  800324:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800327:	8b 45 18             	mov    0x18(%ebp),%eax
  80032a:	ba 00 00 00 00       	mov    $0x0,%edx
  80032f:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800332:	77 72                	ja     8003a6 <printnum+0x92>
  800334:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800337:	72 05                	jb     80033e <printnum+0x2a>
  800339:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80033c:	77 68                	ja     8003a6 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80033e:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800341:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800344:	8b 45 18             	mov    0x18(%ebp),%eax
  800347:	ba 00 00 00 00       	mov    $0x0,%edx
  80034c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800350:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800357:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80035a:	89 04 24             	mov    %eax,(%esp)
  80035d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800361:	e8 2a 16 00 00       	call   801990 <__udivdi3>
  800366:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800369:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  80036d:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800371:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800374:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800378:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800380:	8b 45 0c             	mov    0xc(%ebp),%eax
  800383:	89 44 24 04          	mov    %eax,0x4(%esp)
  800387:	8b 45 08             	mov    0x8(%ebp),%eax
  80038a:	89 04 24             	mov    %eax,(%esp)
  80038d:	e8 82 ff ff ff       	call   800314 <printnum>
  800392:	eb 1c                	jmp    8003b0 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800394:	8b 45 0c             	mov    0xc(%ebp),%eax
  800397:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039b:	8b 45 20             	mov    0x20(%ebp),%eax
  80039e:	89 04 24             	mov    %eax,(%esp)
  8003a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a4:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a6:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8003aa:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8003ae:	7f e4                	jg     800394 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8003bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8003be:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003c2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003c6:	89 04 24             	mov    %eax,(%esp)
  8003c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003cd:	e8 ee 16 00 00       	call   801ac0 <__umoddi3>
  8003d2:	05 48 1d 80 00       	add    $0x801d48,%eax
  8003d7:	0f b6 00             	movzbl (%eax),%eax
  8003da:	0f be c0             	movsbl %al,%eax
  8003dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003e4:	89 04 24             	mov    %eax,(%esp)
  8003e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ea:	ff d0                	call   *%eax
}
  8003ec:	83 c4 34             	add    $0x34,%esp
  8003ef:	5b                   	pop    %ebx
  8003f0:	5d                   	pop    %ebp
  8003f1:	c3                   	ret    

008003f2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003f5:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003f9:	7e 14                	jle    80040f <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	8b 00                	mov    (%eax),%eax
  800400:	8d 48 08             	lea    0x8(%eax),%ecx
  800403:	8b 55 08             	mov    0x8(%ebp),%edx
  800406:	89 0a                	mov    %ecx,(%edx)
  800408:	8b 50 04             	mov    0x4(%eax),%edx
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	eb 30                	jmp    80043f <getuint+0x4d>
	else if (lflag)
  80040f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800413:	74 16                	je     80042b <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800415:	8b 45 08             	mov    0x8(%ebp),%eax
  800418:	8b 00                	mov    (%eax),%eax
  80041a:	8d 48 04             	lea    0x4(%eax),%ecx
  80041d:	8b 55 08             	mov    0x8(%ebp),%edx
  800420:	89 0a                	mov    %ecx,(%edx)
  800422:	8b 00                	mov    (%eax),%eax
  800424:	ba 00 00 00 00       	mov    $0x0,%edx
  800429:	eb 14                	jmp    80043f <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80042b:	8b 45 08             	mov    0x8(%ebp),%eax
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	8d 48 04             	lea    0x4(%eax),%ecx
  800433:	8b 55 08             	mov    0x8(%ebp),%edx
  800436:	89 0a                	mov    %ecx,(%edx)
  800438:	8b 00                	mov    (%eax),%eax
  80043a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80043f:	5d                   	pop    %ebp
  800440:	c3                   	ret    

00800441 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800444:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800448:	7e 14                	jle    80045e <getint+0x1d>
		return va_arg(*ap, long long);
  80044a:	8b 45 08             	mov    0x8(%ebp),%eax
  80044d:	8b 00                	mov    (%eax),%eax
  80044f:	8d 48 08             	lea    0x8(%eax),%ecx
  800452:	8b 55 08             	mov    0x8(%ebp),%edx
  800455:	89 0a                	mov    %ecx,(%edx)
  800457:	8b 50 04             	mov    0x4(%eax),%edx
  80045a:	8b 00                	mov    (%eax),%eax
  80045c:	eb 28                	jmp    800486 <getint+0x45>
	else if (lflag)
  80045e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800462:	74 12                	je     800476 <getint+0x35>
		return va_arg(*ap, long);
  800464:	8b 45 08             	mov    0x8(%ebp),%eax
  800467:	8b 00                	mov    (%eax),%eax
  800469:	8d 48 04             	lea    0x4(%eax),%ecx
  80046c:	8b 55 08             	mov    0x8(%ebp),%edx
  80046f:	89 0a                	mov    %ecx,(%edx)
  800471:	8b 00                	mov    (%eax),%eax
  800473:	99                   	cltd   
  800474:	eb 10                	jmp    800486 <getint+0x45>
	else
		return va_arg(*ap, int);
  800476:	8b 45 08             	mov    0x8(%ebp),%eax
  800479:	8b 00                	mov    (%eax),%eax
  80047b:	8d 48 04             	lea    0x4(%eax),%ecx
  80047e:	8b 55 08             	mov    0x8(%ebp),%edx
  800481:	89 0a                	mov    %ecx,(%edx)
  800483:	8b 00                	mov    (%eax),%eax
  800485:	99                   	cltd   
}
  800486:	5d                   	pop    %ebp
  800487:	c3                   	ret    

00800488 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	56                   	push   %esi
  80048c:	53                   	push   %ebx
  80048d:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800490:	eb 18                	jmp    8004aa <vprintfmt+0x22>
			if (ch == '\0')
  800492:	85 db                	test   %ebx,%ebx
  800494:	75 05                	jne    80049b <vprintfmt+0x13>
				return;
  800496:	e9 05 04 00 00       	jmp    8008a0 <vprintfmt+0x418>
			putch(ch, putdat);
  80049b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a2:	89 1c 24             	mov    %ebx,(%esp)
  8004a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a8:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ad:	8d 50 01             	lea    0x1(%eax),%edx
  8004b0:	89 55 10             	mov    %edx,0x10(%ebp)
  8004b3:	0f b6 00             	movzbl (%eax),%eax
  8004b6:	0f b6 d8             	movzbl %al,%ebx
  8004b9:	83 fb 25             	cmp    $0x25,%ebx
  8004bc:	75 d4                	jne    800492 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8004be:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8004c2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8004c9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004d0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8004d7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e1:	8d 50 01             	lea    0x1(%eax),%edx
  8004e4:	89 55 10             	mov    %edx,0x10(%ebp)
  8004e7:	0f b6 00             	movzbl (%eax),%eax
  8004ea:	0f b6 d8             	movzbl %al,%ebx
  8004ed:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8004f0:	83 f8 55             	cmp    $0x55,%eax
  8004f3:	0f 87 76 03 00 00    	ja     80086f <vprintfmt+0x3e7>
  8004f9:	8b 04 85 6c 1d 80 00 	mov    0x801d6c(,%eax,4),%eax
  800500:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800502:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800506:	eb d6                	jmp    8004de <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800508:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80050c:	eb d0                	jmp    8004de <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80050e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800515:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800518:	89 d0                	mov    %edx,%eax
  80051a:	c1 e0 02             	shl    $0x2,%eax
  80051d:	01 d0                	add    %edx,%eax
  80051f:	01 c0                	add    %eax,%eax
  800521:	01 d8                	add    %ebx,%eax
  800523:	83 e8 30             	sub    $0x30,%eax
  800526:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800529:	8b 45 10             	mov    0x10(%ebp),%eax
  80052c:	0f b6 00             	movzbl (%eax),%eax
  80052f:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800532:	83 fb 2f             	cmp    $0x2f,%ebx
  800535:	7e 0b                	jle    800542 <vprintfmt+0xba>
  800537:	83 fb 39             	cmp    $0x39,%ebx
  80053a:	7f 06                	jg     800542 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80053c:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800540:	eb d3                	jmp    800515 <vprintfmt+0x8d>
			goto process_precision;
  800542:	eb 33                	jmp    800577 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 50 04             	lea    0x4(%eax),%edx
  80054a:	89 55 14             	mov    %edx,0x14(%ebp)
  80054d:	8b 00                	mov    (%eax),%eax
  80054f:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800552:	eb 23                	jmp    800577 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800554:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800558:	79 0c                	jns    800566 <vprintfmt+0xde>
				width = 0;
  80055a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800561:	e9 78 ff ff ff       	jmp    8004de <vprintfmt+0x56>
  800566:	e9 73 ff ff ff       	jmp    8004de <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80056b:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800572:	e9 67 ff ff ff       	jmp    8004de <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800577:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80057b:	79 12                	jns    80058f <vprintfmt+0x107>
				width = precision, precision = -1;
  80057d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800583:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80058a:	e9 4f ff ff ff       	jmp    8004de <vprintfmt+0x56>
  80058f:	e9 4a ff ff ff       	jmp    8004de <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800594:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800598:	e9 41 ff ff ff       	jmp    8004de <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 50 04             	lea    0x4(%eax),%edx
  8005a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005af:	89 04 24             	mov    %eax,(%esp)
  8005b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b5:	ff d0                	call   *%eax
			break;
  8005b7:	e9 de 02 00 00       	jmp    80089a <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 04             	lea    0x4(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c5:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8005c7:	85 db                	test   %ebx,%ebx
  8005c9:	79 02                	jns    8005cd <vprintfmt+0x145>
				err = -err;
  8005cb:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005cd:	83 fb 09             	cmp    $0x9,%ebx
  8005d0:	7f 0b                	jg     8005dd <vprintfmt+0x155>
  8005d2:	8b 34 9d 20 1d 80 00 	mov    0x801d20(,%ebx,4),%esi
  8005d9:	85 f6                	test   %esi,%esi
  8005db:	75 23                	jne    800600 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8005dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005e1:	c7 44 24 08 59 1d 80 	movl   $0x801d59,0x8(%esp)
  8005e8:	00 
  8005e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f3:	89 04 24             	mov    %eax,(%esp)
  8005f6:	e8 ac 02 00 00       	call   8008a7 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8005fb:	e9 9a 02 00 00       	jmp    80089a <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800600:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800604:	c7 44 24 08 62 1d 80 	movl   $0x801d62,0x8(%esp)
  80060b:	00 
  80060c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800613:	8b 45 08             	mov    0x8(%ebp),%eax
  800616:	89 04 24             	mov    %eax,(%esp)
  800619:	e8 89 02 00 00       	call   8008a7 <printfmt>
			break;
  80061e:	e9 77 02 00 00       	jmp    80089a <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 04             	lea    0x4(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	8b 30                	mov    (%eax),%esi
  80062e:	85 f6                	test   %esi,%esi
  800630:	75 05                	jne    800637 <vprintfmt+0x1af>
				p = "(null)";
  800632:	be 65 1d 80 00       	mov    $0x801d65,%esi
			if (width > 0 && padc != '-')
  800637:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80063b:	7e 37                	jle    800674 <vprintfmt+0x1ec>
  80063d:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800641:	74 31                	je     800674 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800646:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064a:	89 34 24             	mov    %esi,(%esp)
  80064d:	e8 72 03 00 00       	call   8009c4 <strnlen>
  800652:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800655:	eb 17                	jmp    80066e <vprintfmt+0x1e6>
					putch(padc, putdat);
  800657:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80065b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80065e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800662:	89 04 24             	mov    %eax,(%esp)
  800665:	8b 45 08             	mov    0x8(%ebp),%eax
  800668:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80066a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80066e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800672:	7f e3                	jg     800657 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800674:	eb 38                	jmp    8006ae <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800676:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80067a:	74 1f                	je     80069b <vprintfmt+0x213>
  80067c:	83 fb 1f             	cmp    $0x1f,%ebx
  80067f:	7e 05                	jle    800686 <vprintfmt+0x1fe>
  800681:	83 fb 7e             	cmp    $0x7e,%ebx
  800684:	7e 15                	jle    80069b <vprintfmt+0x213>
					putch('?', putdat);
  800686:	8b 45 0c             	mov    0xc(%ebp),%eax
  800689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800694:	8b 45 08             	mov    0x8(%ebp),%eax
  800697:	ff d0                	call   *%eax
  800699:	eb 0f                	jmp    8006aa <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80069b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a2:	89 1c 24             	mov    %ebx,(%esp)
  8006a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a8:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006aa:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8006ae:	89 f0                	mov    %esi,%eax
  8006b0:	8d 70 01             	lea    0x1(%eax),%esi
  8006b3:	0f b6 00             	movzbl (%eax),%eax
  8006b6:	0f be d8             	movsbl %al,%ebx
  8006b9:	85 db                	test   %ebx,%ebx
  8006bb:	74 10                	je     8006cd <vprintfmt+0x245>
  8006bd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c1:	78 b3                	js     800676 <vprintfmt+0x1ee>
  8006c3:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8006c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006cb:	79 a9                	jns    800676 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006cd:	eb 17                	jmp    8006e6 <vprintfmt+0x25e>
				putch(' ', putdat);
  8006cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e0:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e2:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8006e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ea:	7f e3                	jg     8006cf <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8006ec:	e9 a9 01 00 00       	jmp    80089a <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fb:	89 04 24             	mov    %eax,(%esp)
  8006fe:	e8 3e fd ff ff       	call   800441 <getint>
  800703:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800706:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800709:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80070c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80070f:	85 d2                	test   %edx,%edx
  800711:	79 26                	jns    800739 <vprintfmt+0x2b1>
				putch('-', putdat);
  800713:	8b 45 0c             	mov    0xc(%ebp),%eax
  800716:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071a:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800721:	8b 45 08             	mov    0x8(%ebp),%eax
  800724:	ff d0                	call   *%eax
				num = -(long long) num;
  800726:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800729:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80072c:	f7 d8                	neg    %eax
  80072e:	83 d2 00             	adc    $0x0,%edx
  800731:	f7 da                	neg    %edx
  800733:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800736:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800739:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800740:	e9 e1 00 00 00       	jmp    800826 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800745:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800748:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074c:	8d 45 14             	lea    0x14(%ebp),%eax
  80074f:	89 04 24             	mov    %eax,(%esp)
  800752:	e8 9b fc ff ff       	call   8003f2 <getuint>
  800757:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80075a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  80075d:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800764:	e9 bd 00 00 00       	jmp    800826 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  800769:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  800770:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800773:	89 44 24 04          	mov    %eax,0x4(%esp)
  800777:	8d 45 14             	lea    0x14(%ebp),%eax
  80077a:	89 04 24             	mov    %eax,(%esp)
  80077d:	e8 70 fc ff ff       	call   8003f2 <getuint>
  800782:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800785:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  800788:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80078c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078f:	89 54 24 18          	mov    %edx,0x18(%esp)
  800793:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800796:	89 54 24 14          	mov    %edx,0x14(%esp)
  80079a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80079e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b6:	89 04 24             	mov    %eax,(%esp)
  8007b9:	e8 56 fb ff ff       	call   800314 <printnum>
			break;
  8007be:	e9 d7 00 00 00       	jmp    80089a <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  8007c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ca:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d4:	ff d0                	call   *%eax
			putch('x', putdat);
  8007d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007dd:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8d 50 04             	lea    0x4(%eax),%edx
  8007ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f2:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007fe:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800805:	eb 1f                	jmp    800826 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800807:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80080a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080e:	8d 45 14             	lea    0x14(%ebp),%eax
  800811:	89 04 24             	mov    %eax,(%esp)
  800814:	e8 d9 fb ff ff       	call   8003f2 <getuint>
  800819:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80081c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80081f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800826:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80082a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082d:	89 54 24 18          	mov    %edx,0x18(%esp)
  800831:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800834:	89 54 24 14          	mov    %edx,0x14(%esp)
  800838:	89 44 24 10          	mov    %eax,0x10(%esp)
  80083c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800842:	89 44 24 08          	mov    %eax,0x8(%esp)
  800846:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80084a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	89 04 24             	mov    %eax,(%esp)
  800857:	e8 b8 fa ff ff       	call   800314 <printnum>
			break;
  80085c:	eb 3c                	jmp    80089a <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80085e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800861:	89 44 24 04          	mov    %eax,0x4(%esp)
  800865:	89 1c 24             	mov    %ebx,(%esp)
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	ff d0                	call   *%eax
			break;
  80086d:	eb 2b                	jmp    80089a <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80086f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800872:	89 44 24 04          	mov    %eax,0x4(%esp)
  800876:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800882:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800886:	eb 04                	jmp    80088c <vprintfmt+0x404>
  800888:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80088c:	8b 45 10             	mov    0x10(%ebp),%eax
  80088f:	83 e8 01             	sub    $0x1,%eax
  800892:	0f b6 00             	movzbl (%eax),%eax
  800895:	3c 25                	cmp    $0x25,%al
  800897:	75 ef                	jne    800888 <vprintfmt+0x400>
				/* do nothing */;
			break;
  800899:	90                   	nop
		}
	}
  80089a:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80089b:	e9 0a fc ff ff       	jmp    8004aa <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8008a0:	83 c4 40             	add    $0x40,%esp
  8008a3:	5b                   	pop    %ebx
  8008a4:	5e                   	pop    %esi
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8008ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8008b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8008bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	89 04 24             	mov    %eax,(%esp)
  8008ce:	e8 b5 fb ff ff       	call   800488 <vprintfmt>
	va_end(ap);
}
  8008d3:	c9                   	leave  
  8008d4:	c3                   	ret    

008008d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8008d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008db:	8b 40 08             	mov    0x8(%eax),%eax
  8008de:	8d 50 01             	lea    0x1(%eax),%edx
  8008e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e4:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8008e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ea:	8b 10                	mov    (%eax),%edx
  8008ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ef:	8b 40 04             	mov    0x4(%eax),%eax
  8008f2:	39 c2                	cmp    %eax,%edx
  8008f4:	73 12                	jae    800908 <sprintputch+0x33>
		*b->buf++ = ch;
  8008f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f9:	8b 00                	mov    (%eax),%eax
  8008fb:	8d 48 01             	lea    0x1(%eax),%ecx
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800901:	89 0a                	mov    %ecx,(%edx)
  800903:	8b 55 08             	mov    0x8(%ebp),%edx
  800906:	88 10                	mov    %dl,(%eax)
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800916:	8b 45 0c             	mov    0xc(%ebp),%eax
  800919:	8d 50 ff             	lea    -0x1(%eax),%edx
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	01 d0                	add    %edx,%eax
  800921:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800924:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80092b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80092f:	74 06                	je     800937 <vsnprintf+0x2d>
  800931:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800935:	7f 07                	jg     80093e <vsnprintf+0x34>
		return -E_INVAL;
  800937:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80093c:	eb 2a                	jmp    800968 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800945:	8b 45 10             	mov    0x10(%ebp),%eax
  800948:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80094f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800953:	c7 04 24 d5 08 80 00 	movl   $0x8008d5,(%esp)
  80095a:	e8 29 fb ff ff       	call   800488 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80095f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800962:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800965:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800970:	8d 45 14             	lea    0x14(%ebp),%eax
  800973:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800976:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800979:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80097d:	8b 45 10             	mov    0x10(%ebp),%eax
  800980:	89 44 24 08          	mov    %eax,0x8(%esp)
  800984:	8b 45 0c             	mov    0xc(%ebp),%eax
  800987:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	89 04 24             	mov    %eax,(%esp)
  800991:	e8 74 ff ff ff       	call   80090a <vsnprintf>
  800996:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009ab:	eb 08                	jmp    8009b5 <strlen+0x17>
		n++;
  8009ad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	0f b6 00             	movzbl (%eax),%eax
  8009bb:	84 c0                	test   %al,%al
  8009bd:	75 ee                	jne    8009ad <strlen+0xf>
		n++;
	return n;
  8009bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ca:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009d1:	eb 0c                	jmp    8009df <strnlen+0x1b>
		n++;
  8009d3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009db:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  8009df:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009e3:	74 0a                	je     8009ef <strnlen+0x2b>
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	0f b6 00             	movzbl (%eax),%eax
  8009eb:	84 c0                	test   %al,%al
  8009ed:	75 e4                	jne    8009d3 <strnlen+0xf>
		n++;
	return n;
  8009ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009f2:	c9                   	leave  
  8009f3:	c3                   	ret    

008009f4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800a00:	90                   	nop
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	8d 50 01             	lea    0x1(%eax),%edx
  800a07:	89 55 08             	mov    %edx,0x8(%ebp)
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a10:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a13:	0f b6 12             	movzbl (%edx),%edx
  800a16:	88 10                	mov    %dl,(%eax)
  800a18:	0f b6 00             	movzbl (%eax),%eax
  800a1b:	84 c0                	test   %al,%al
  800a1d:	75 e2                	jne    800a01 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800a1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	89 04 24             	mov    %eax,(%esp)
  800a30:	e8 69 ff ff ff       	call   80099e <strlen>
  800a35:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800a38:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	01 c2                	add    %eax,%edx
  800a40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a43:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a47:	89 14 24             	mov    %edx,(%esp)
  800a4a:	e8 a5 ff ff ff       	call   8009f4 <strcpy>
	return dst;
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a52:	c9                   	leave  
  800a53:	c3                   	ret    

00800a54 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800a60:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800a67:	eb 23                	jmp    800a8c <strncpy+0x38>
		*dst++ = *src;
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	8d 50 01             	lea    0x1(%eax),%edx
  800a6f:	89 55 08             	mov    %edx,0x8(%ebp)
  800a72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a75:	0f b6 12             	movzbl (%edx),%edx
  800a78:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7d:	0f b6 00             	movzbl (%eax),%eax
  800a80:	84 c0                	test   %al,%al
  800a82:	74 04                	je     800a88 <strncpy+0x34>
			src++;
  800a84:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a88:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800a8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a8f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a92:	72 d5                	jb     800a69 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a94:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a97:	c9                   	leave  
  800a98:	c3                   	ret    

00800a99 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800aa5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aa9:	74 33                	je     800ade <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800aab:	eb 17                	jmp    800ac4 <strlcpy+0x2b>
			*dst++ = *src++;
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	8d 50 01             	lea    0x1(%eax),%edx
  800ab3:	89 55 08             	mov    %edx,0x8(%ebp)
  800ab6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab9:	8d 4a 01             	lea    0x1(%edx),%ecx
  800abc:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800abf:	0f b6 12             	movzbl (%edx),%edx
  800ac2:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ac4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ac8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800acc:	74 0a                	je     800ad8 <strlcpy+0x3f>
  800ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad1:	0f b6 00             	movzbl (%eax),%eax
  800ad4:	84 c0                	test   %al,%al
  800ad6:	75 d5                	jne    800aad <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ade:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ae4:	29 c2                	sub    %eax,%edx
  800ae6:	89 d0                	mov    %edx,%eax
}
  800ae8:	c9                   	leave  
  800ae9:	c3                   	ret    

00800aea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800aed:	eb 08                	jmp    800af7 <strcmp+0xd>
		p++, q++;
  800aef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800af3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	0f b6 00             	movzbl (%eax),%eax
  800afd:	84 c0                	test   %al,%al
  800aff:	74 10                	je     800b11 <strcmp+0x27>
  800b01:	8b 45 08             	mov    0x8(%ebp),%eax
  800b04:	0f b6 10             	movzbl (%eax),%edx
  800b07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0a:	0f b6 00             	movzbl (%eax),%eax
  800b0d:	38 c2                	cmp    %al,%dl
  800b0f:	74 de                	je     800aef <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b11:	8b 45 08             	mov    0x8(%ebp),%eax
  800b14:	0f b6 00             	movzbl (%eax),%eax
  800b17:	0f b6 d0             	movzbl %al,%edx
  800b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1d:	0f b6 00             	movzbl (%eax),%eax
  800b20:	0f b6 c0             	movzbl %al,%eax
  800b23:	29 c2                	sub    %eax,%edx
  800b25:	89 d0                	mov    %edx,%eax
}
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800b2c:	eb 0c                	jmp    800b3a <strncmp+0x11>
		n--, p++, q++;
  800b2e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b32:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b36:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b3e:	74 1a                	je     800b5a <strncmp+0x31>
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
  800b43:	0f b6 00             	movzbl (%eax),%eax
  800b46:	84 c0                	test   %al,%al
  800b48:	74 10                	je     800b5a <strncmp+0x31>
  800b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4d:	0f b6 10             	movzbl (%eax),%edx
  800b50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b53:	0f b6 00             	movzbl (%eax),%eax
  800b56:	38 c2                	cmp    %al,%dl
  800b58:	74 d4                	je     800b2e <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800b5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b5e:	75 07                	jne    800b67 <strncmp+0x3e>
		return 0;
  800b60:	b8 00 00 00 00       	mov    $0x0,%eax
  800b65:	eb 16                	jmp    800b7d <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b67:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6a:	0f b6 00             	movzbl (%eax),%eax
  800b6d:	0f b6 d0             	movzbl %al,%edx
  800b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b73:	0f b6 00             	movzbl (%eax),%eax
  800b76:	0f b6 c0             	movzbl %al,%eax
  800b79:	29 c2                	sub    %eax,%edx
  800b7b:	89 d0                	mov    %edx,%eax
}
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	83 ec 04             	sub    $0x4,%esp
  800b85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b88:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b8b:	eb 14                	jmp    800ba1 <strchr+0x22>
		if (*s == c)
  800b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b90:	0f b6 00             	movzbl (%eax),%eax
  800b93:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b96:	75 05                	jne    800b9d <strchr+0x1e>
			return (char *) s;
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	eb 13                	jmp    800bb0 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b9d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba4:	0f b6 00             	movzbl (%eax),%eax
  800ba7:	84 c0                	test   %al,%al
  800ba9:	75 e2                	jne    800b8d <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800bab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb0:	c9                   	leave  
  800bb1:	c3                   	ret    

00800bb2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	83 ec 04             	sub    $0x4,%esp
  800bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbb:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800bbe:	eb 11                	jmp    800bd1 <strfind+0x1f>
		if (*s == c)
  800bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc3:	0f b6 00             	movzbl (%eax),%eax
  800bc6:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800bc9:	75 02                	jne    800bcd <strfind+0x1b>
			break;
  800bcb:	eb 0e                	jmp    800bdb <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bcd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd4:	0f b6 00             	movzbl (%eax),%eax
  800bd7:	84 c0                	test   %al,%al
  800bd9:	75 e5                	jne    800bc0 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800bdb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bde:	c9                   	leave  
  800bdf:	c3                   	ret    

00800be0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
	char *p;

	if (n == 0)
  800be4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800be8:	75 05                	jne    800bef <memset+0xf>
		return v;
  800bea:	8b 45 08             	mov    0x8(%ebp),%eax
  800bed:	eb 5c                	jmp    800c4b <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800bef:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf2:	83 e0 03             	and    $0x3,%eax
  800bf5:	85 c0                	test   %eax,%eax
  800bf7:	75 41                	jne    800c3a <memset+0x5a>
  800bf9:	8b 45 10             	mov    0x10(%ebp),%eax
  800bfc:	83 e0 03             	and    $0x3,%eax
  800bff:	85 c0                	test   %eax,%eax
  800c01:	75 37                	jne    800c3a <memset+0x5a>
		c &= 0xFF;
  800c03:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0d:	c1 e0 18             	shl    $0x18,%eax
  800c10:	89 c2                	mov    %eax,%edx
  800c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c15:	c1 e0 10             	shl    $0x10,%eax
  800c18:	09 c2                	or     %eax,%edx
  800c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1d:	c1 e0 08             	shl    $0x8,%eax
  800c20:	09 d0                	or     %edx,%eax
  800c22:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c25:	8b 45 10             	mov    0x10(%ebp),%eax
  800c28:	c1 e8 02             	shr    $0x2,%eax
  800c2b:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c33:	89 d7                	mov    %edx,%edi
  800c35:	fc                   	cld    
  800c36:	f3 ab                	rep stos %eax,%es:(%edi)
  800c38:	eb 0e                	jmp    800c48 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c40:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c43:	89 d7                	mov    %edx,%edi
  800c45:	fc                   	cld    
  800c46:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800c48:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800c57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c60:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c66:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c69:	73 6d                	jae    800cd8 <memmove+0x8a>
  800c6b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c71:	01 d0                	add    %edx,%eax
  800c73:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c76:	76 60                	jbe    800cd8 <memmove+0x8a>
		s += n;
  800c78:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7b:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800c7e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c81:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c87:	83 e0 03             	and    $0x3,%eax
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	75 2f                	jne    800cbd <memmove+0x6f>
  800c8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c91:	83 e0 03             	and    $0x3,%eax
  800c94:	85 c0                	test   %eax,%eax
  800c96:	75 25                	jne    800cbd <memmove+0x6f>
  800c98:	8b 45 10             	mov    0x10(%ebp),%eax
  800c9b:	83 e0 03             	and    $0x3,%eax
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	75 1b                	jne    800cbd <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ca2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ca5:	83 e8 04             	sub    $0x4,%eax
  800ca8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cab:	83 ea 04             	sub    $0x4,%edx
  800cae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cb1:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cb4:	89 c7                	mov    %eax,%edi
  800cb6:	89 d6                	mov    %edx,%esi
  800cb8:	fd                   	std    
  800cb9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cbb:	eb 18                	jmp    800cd5 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cc0:	8d 50 ff             	lea    -0x1(%eax),%edx
  800cc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cc6:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cc9:	8b 45 10             	mov    0x10(%ebp),%eax
  800ccc:	89 d7                	mov    %edx,%edi
  800cce:	89 de                	mov    %ebx,%esi
  800cd0:	89 c1                	mov    %eax,%ecx
  800cd2:	fd                   	std    
  800cd3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cd5:	fc                   	cld    
  800cd6:	eb 45                	jmp    800d1d <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cdb:	83 e0 03             	and    $0x3,%eax
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	75 2b                	jne    800d0d <memmove+0xbf>
  800ce2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ce5:	83 e0 03             	and    $0x3,%eax
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	75 21                	jne    800d0d <memmove+0xbf>
  800cec:	8b 45 10             	mov    0x10(%ebp),%eax
  800cef:	83 e0 03             	and    $0x3,%eax
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	75 17                	jne    800d0d <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cf6:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf9:	c1 e8 02             	shr    $0x2,%eax
  800cfc:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d01:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d04:	89 c7                	mov    %eax,%edi
  800d06:	89 d6                	mov    %edx,%esi
  800d08:	fc                   	cld    
  800d09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0b:	eb 10                	jmp    800d1d <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d10:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d13:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d16:	89 c7                	mov    %eax,%edi
  800d18:	89 d6                	mov    %edx,%esi
  800d1a:	fc                   	cld    
  800d1b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800d1d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d20:	83 c4 10             	add    $0x10,%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d2e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d31:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	89 04 24             	mov    %eax,(%esp)
  800d42:	e8 07 ff ff ff       	call   800c4e <memmove>
}
  800d47:	c9                   	leave  
  800d48:	c3                   	ret    

00800d49 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800d55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d58:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800d5b:	eb 30                	jmp    800d8d <memcmp+0x44>
		if (*s1 != *s2)
  800d5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d60:	0f b6 10             	movzbl (%eax),%edx
  800d63:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d66:	0f b6 00             	movzbl (%eax),%eax
  800d69:	38 c2                	cmp    %al,%dl
  800d6b:	74 18                	je     800d85 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800d6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d70:	0f b6 00             	movzbl (%eax),%eax
  800d73:	0f b6 d0             	movzbl %al,%edx
  800d76:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d79:	0f b6 00             	movzbl (%eax),%eax
  800d7c:	0f b6 c0             	movzbl %al,%eax
  800d7f:	29 c2                	sub    %eax,%edx
  800d81:	89 d0                	mov    %edx,%eax
  800d83:	eb 1a                	jmp    800d9f <memcmp+0x56>
		s1++, s2++;
  800d85:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d89:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d90:	8d 50 ff             	lea    -0x1(%eax),%edx
  800d93:	89 55 10             	mov    %edx,0x10(%ebp)
  800d96:	85 c0                	test   %eax,%eax
  800d98:	75 c3                	jne    800d5d <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d9f:	c9                   	leave  
  800da0:	c3                   	ret    

00800da1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800da7:	8b 45 10             	mov    0x10(%ebp),%eax
  800daa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dad:	01 d0                	add    %edx,%eax
  800daf:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800db2:	eb 13                	jmp    800dc7 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800db4:	8b 45 08             	mov    0x8(%ebp),%eax
  800db7:	0f b6 10             	movzbl (%eax),%edx
  800dba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbd:	38 c2                	cmp    %al,%dl
  800dbf:	75 02                	jne    800dc3 <memfind+0x22>
			break;
  800dc1:	eb 0c                	jmp    800dcf <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dc3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dca:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800dcd:	72 e5                	jb     800db4 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800dcf:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800dd2:	c9                   	leave  
  800dd3:	c3                   	ret    

00800dd4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800dda:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800de1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800de8:	eb 04                	jmp    800dee <strtol+0x1a>
		s++;
  800dea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	0f b6 00             	movzbl (%eax),%eax
  800df4:	3c 20                	cmp    $0x20,%al
  800df6:	74 f2                	je     800dea <strtol+0x16>
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	0f b6 00             	movzbl (%eax),%eax
  800dfe:	3c 09                	cmp    $0x9,%al
  800e00:	74 e8                	je     800dea <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e02:	8b 45 08             	mov    0x8(%ebp),%eax
  800e05:	0f b6 00             	movzbl (%eax),%eax
  800e08:	3c 2b                	cmp    $0x2b,%al
  800e0a:	75 06                	jne    800e12 <strtol+0x3e>
		s++;
  800e0c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e10:	eb 15                	jmp    800e27 <strtol+0x53>
	else if (*s == '-')
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
  800e15:	0f b6 00             	movzbl (%eax),%eax
  800e18:	3c 2d                	cmp    $0x2d,%al
  800e1a:	75 0b                	jne    800e27 <strtol+0x53>
		s++, neg = 1;
  800e1c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e20:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e2b:	74 06                	je     800e33 <strtol+0x5f>
  800e2d:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800e31:	75 24                	jne    800e57 <strtol+0x83>
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	0f b6 00             	movzbl (%eax),%eax
  800e39:	3c 30                	cmp    $0x30,%al
  800e3b:	75 1a                	jne    800e57 <strtol+0x83>
  800e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e40:	83 c0 01             	add    $0x1,%eax
  800e43:	0f b6 00             	movzbl (%eax),%eax
  800e46:	3c 78                	cmp    $0x78,%al
  800e48:	75 0d                	jne    800e57 <strtol+0x83>
		s += 2, base = 16;
  800e4a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800e4e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800e55:	eb 2a                	jmp    800e81 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800e57:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e5b:	75 17                	jne    800e74 <strtol+0xa0>
  800e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e60:	0f b6 00             	movzbl (%eax),%eax
  800e63:	3c 30                	cmp    $0x30,%al
  800e65:	75 0d                	jne    800e74 <strtol+0xa0>
		s++, base = 8;
  800e67:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e6b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800e72:	eb 0d                	jmp    800e81 <strtol+0xad>
	else if (base == 0)
  800e74:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e78:	75 07                	jne    800e81 <strtol+0xad>
		base = 10;
  800e7a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e81:	8b 45 08             	mov    0x8(%ebp),%eax
  800e84:	0f b6 00             	movzbl (%eax),%eax
  800e87:	3c 2f                	cmp    $0x2f,%al
  800e89:	7e 1b                	jle    800ea6 <strtol+0xd2>
  800e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8e:	0f b6 00             	movzbl (%eax),%eax
  800e91:	3c 39                	cmp    $0x39,%al
  800e93:	7f 11                	jg     800ea6 <strtol+0xd2>
			dig = *s - '0';
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
  800e98:	0f b6 00             	movzbl (%eax),%eax
  800e9b:	0f be c0             	movsbl %al,%eax
  800e9e:	83 e8 30             	sub    $0x30,%eax
  800ea1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ea4:	eb 48                	jmp    800eee <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	0f b6 00             	movzbl (%eax),%eax
  800eac:	3c 60                	cmp    $0x60,%al
  800eae:	7e 1b                	jle    800ecb <strtol+0xf7>
  800eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb3:	0f b6 00             	movzbl (%eax),%eax
  800eb6:	3c 7a                	cmp    $0x7a,%al
  800eb8:	7f 11                	jg     800ecb <strtol+0xf7>
			dig = *s - 'a' + 10;
  800eba:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebd:	0f b6 00             	movzbl (%eax),%eax
  800ec0:	0f be c0             	movsbl %al,%eax
  800ec3:	83 e8 57             	sub    $0x57,%eax
  800ec6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ec9:	eb 23                	jmp    800eee <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ece:	0f b6 00             	movzbl (%eax),%eax
  800ed1:	3c 40                	cmp    $0x40,%al
  800ed3:	7e 3d                	jle    800f12 <strtol+0x13e>
  800ed5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed8:	0f b6 00             	movzbl (%eax),%eax
  800edb:	3c 5a                	cmp    $0x5a,%al
  800edd:	7f 33                	jg     800f12 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee2:	0f b6 00             	movzbl (%eax),%eax
  800ee5:	0f be c0             	movsbl %al,%eax
  800ee8:	83 e8 37             	sub    $0x37,%eax
  800eeb:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef1:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ef4:	7c 02                	jl     800ef8 <strtol+0x124>
			break;
  800ef6:	eb 1a                	jmp    800f12 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800ef8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800efc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800eff:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f03:	89 c2                	mov    %eax,%edx
  800f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f08:	01 d0                	add    %edx,%eax
  800f0a:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800f0d:	e9 6f ff ff ff       	jmp    800e81 <strtol+0xad>

	if (endptr)
  800f12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f16:	74 08                	je     800f20 <strtol+0x14c>
		*endptr = (char *) s;
  800f18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800f20:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800f24:	74 07                	je     800f2d <strtol+0x159>
  800f26:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f29:	f7 d8                	neg    %eax
  800f2b:	eb 03                	jmp    800f30 <strtol+0x15c>
  800f2d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800f30:	c9                   	leave  
  800f31:	c3                   	ret    

00800f32 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	57                   	push   %edi
  800f36:	56                   	push   %esi
  800f37:	53                   	push   %ebx
  800f38:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3e:	8b 55 10             	mov    0x10(%ebp),%edx
  800f41:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800f44:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800f47:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800f4a:	8b 75 20             	mov    0x20(%ebp),%esi
  800f4d:	cd 30                	int    $0x30
  800f4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f56:	74 30                	je     800f88 <syscall+0x56>
  800f58:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f5c:	7e 2a                	jle    800f88 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f61:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f65:	8b 45 08             	mov    0x8(%ebp),%eax
  800f68:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f6c:	c7 44 24 08 c4 1e 80 	movl   $0x801ec4,0x8(%esp)
  800f73:	00 
  800f74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7b:	00 
  800f7c:	c7 04 24 e1 1e 80 00 	movl   $0x801ee1,(%esp)
  800f83:	e8 4b f2 ff ff       	call   8001d3 <_panic>

	return ret;
  800f88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800f8b:	83 c4 3c             	add    $0x3c,%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f99:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fab:	00 
  800fac:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fb3:	00 
  800fb4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fbf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fc6:	00 
  800fc7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fce:	e8 5f ff ff ff       	call   800f32 <syscall>
}
  800fd3:	c9                   	leave  
  800fd4:	c3                   	ret    

00800fd5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800fdb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fe2:	00 
  800fe3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fea:	00 
  800feb:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ff2:	00 
  800ff3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ffa:	00 
  800ffb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801002:	00 
  801003:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80100a:	00 
  80100b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801012:	e8 1b ff ff ff       	call   800f32 <syscall>
}
  801017:	c9                   	leave  
  801018:	c3                   	ret    

00801019 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80101f:	8b 45 08             	mov    0x8(%ebp),%eax
  801022:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801029:	00 
  80102a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801031:	00 
  801032:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801039:	00 
  80103a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801041:	00 
  801042:	89 44 24 08          	mov    %eax,0x8(%esp)
  801046:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80104d:	00 
  80104e:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801055:	e8 d8 fe ff ff       	call   800f32 <syscall>
}
  80105a:	c9                   	leave  
  80105b:	c3                   	ret    

0080105c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801062:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801069:	00 
  80106a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801071:	00 
  801072:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801079:	00 
  80107a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801081:	00 
  801082:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801089:	00 
  80108a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801091:	00 
  801092:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801099:	e8 94 fe ff ff       	call   800f32 <syscall>
}
  80109e:	c9                   	leave  
  80109f:	c3                   	ret    

008010a0 <sys_yield>:

void
sys_yield(void)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8010a6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010ad:	00 
  8010ae:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010b5:	00 
  8010b6:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010bd:	00 
  8010be:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010c5:	00 
  8010c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010cd:	00 
  8010ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010d5:	00 
  8010d6:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8010dd:	e8 50 fe ff ff       	call   800f32 <syscall>
}
  8010e2:	c9                   	leave  
  8010e3:	c3                   	ret    

008010e4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8010ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010fa:	00 
  8010fb:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801102:	00 
  801103:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801107:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80110b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80110f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801116:	00 
  801117:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80111e:	e8 0f fe ff ff       	call   800f32 <syscall>
}
  801123:	c9                   	leave  
  801124:	c3                   	ret    

00801125 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	56                   	push   %esi
  801129:	53                   	push   %ebx
  80112a:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80112d:	8b 75 18             	mov    0x18(%ebp),%esi
  801130:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801133:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801136:	8b 55 0c             	mov    0xc(%ebp),%edx
  801139:	8b 45 08             	mov    0x8(%ebp),%eax
  80113c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801140:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  801144:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801148:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80114c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801150:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801157:	00 
  801158:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  80115f:	e8 ce fd ff ff       	call   800f32 <syscall>
}
  801164:	83 c4 20             	add    $0x20,%esp
  801167:	5b                   	pop    %ebx
  801168:	5e                   	pop    %esi
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    

0080116b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801171:	8b 55 0c             	mov    0xc(%ebp),%edx
  801174:	8b 45 08             	mov    0x8(%ebp),%eax
  801177:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80117e:	00 
  80117f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801186:	00 
  801187:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80118e:	00 
  80118f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801193:	89 44 24 08          	mov    %eax,0x8(%esp)
  801197:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80119e:	00 
  80119f:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  8011a6:	e8 87 fd ff ff       	call   800f32 <syscall>
}
  8011ab:	c9                   	leave  
  8011ac:	c3                   	ret    

008011ad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8011b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011c0:	00 
  8011c1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011c8:	00 
  8011c9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011d0:	00 
  8011d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011e0:	00 
  8011e1:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8011e8:	e8 45 fd ff ff       	call   800f32 <syscall>
}
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    

008011ef <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8011f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801202:	00 
  801203:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80120a:	00 
  80120b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801212:	00 
  801213:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801217:	89 44 24 08          	mov    %eax,0x8(%esp)
  80121b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801222:	00 
  801223:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80122a:	e8 03 fd ff ff       	call   800f32 <syscall>
}
  80122f:	c9                   	leave  
  801230:	c3                   	ret    

00801231 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801237:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80123a:	8b 55 10             	mov    0x10(%ebp),%edx
  80123d:	8b 45 08             	mov    0x8(%ebp),%eax
  801240:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801247:	00 
  801248:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80124c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801250:	8b 55 0c             	mov    0xc(%ebp),%edx
  801253:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801257:	89 44 24 08          	mov    %eax,0x8(%esp)
  80125b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801262:	00 
  801263:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  80126a:	e8 c3 fc ff ff       	call   800f32 <syscall>
}
  80126f:	c9                   	leave  
  801270:	c3                   	ret    

00801271 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801277:	8b 45 08             	mov    0x8(%ebp),%eax
  80127a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801281:	00 
  801282:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801289:	00 
  80128a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801291:	00 
  801292:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801299:	00 
  80129a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80129e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8012a5:	00 
  8012a6:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8012ad:	e8 80 fc ff ff       	call   800f32 <syscall>
}
  8012b2:	c9                   	leave  
  8012b3:	c3                   	ret    

008012b4 <pgfault>:
// map in our own private writable copy.
//

static void
pgfault(struct UTrapframe *utf)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  8012ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bd:	8b 00                	mov    (%eax),%eax
  8012bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  8012c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c5:	8b 40 04             	mov    0x4(%eax),%eax
  8012c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t t = PGNUM(addr);
  8012cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ce:	c1 e8 0c             	shr    $0xc,%eax
  8012d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	pte_t pte = uvpt[t];
  8012d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8012d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012de:	89 45 e8             	mov    %eax,-0x18(%ebp)
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  8012e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e4:	83 e0 02             	and    $0x2,%eax
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	74 0c                	je     8012f7 <pgfault+0x43>
  8012eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8012ee:	25 00 08 00 00       	and    $0x800,%eax
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	75 1c                	jne    801313 <pgfault+0x5f>
		panic("permission denied in copy on write pgfault handler\n");
  8012f7:	c7 44 24 08 f0 1e 80 	movl   $0x801ef0,0x8(%esp)
  8012fe:	00 
  8012ff:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801306:	00 
  801307:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  80130e:	e8 c0 ee ff ff       	call   8001d3 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	r = sys_page_alloc(0,PFTEMP,PTE_P|PTE_U|PTE_W);
  801313:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80131a:	00 
  80131b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801322:	00 
  801323:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80132a:	e8 b5 fd ff ff       	call   8010e4 <sys_page_alloc>
  80132f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if(r < 0)
  801332:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801336:	79 1c                	jns    801354 <pgfault+0xa0>
	{
		panic("page cant be allocated\n");
  801338:	c7 44 24 08 2f 1f 80 	movl   $0x801f2f,0x8(%esp)
  80133f:	00 
  801340:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801347:	00 
  801348:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  80134f:	e8 7f ee ff ff       	call   8001d3 <_panic>
	}
	memmove(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  801354:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801357:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80135a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80135d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801362:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801369:	00 
  80136a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136e:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801375:	e8 d4 f8 ff ff       	call   800c4e <memmove>
	int r1 = sys_page_map(0,PFTEMP,0,ROUNDDOWN(addr,PGSIZE),PTE_W|PTE_U|PTE_P);
  80137a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801380:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801383:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801388:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80138f:	00 
  801390:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801394:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80139b:	00 
  80139c:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013a3:	00 
  8013a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ab:	e8 75 fd ff ff       	call   801125 <sys_page_map>
  8013b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if(r1 < 0)
  8013b3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013b7:	79 1c                	jns    8013d5 <pgfault+0x121>
	{
		panic("page cant be mapped\n");
  8013b9:	c7 44 24 08 47 1f 80 	movl   $0x801f47,0x8(%esp)
  8013c0:	00 
  8013c1:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  8013c8:	00 
  8013c9:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  8013d0:	e8 fe ed ff ff       	call   8001d3 <_panic>
	}	

	// panic("pgfault not implemented");
}
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <duppage>:
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
static int
duppage(envid_t envid, unsigned pn)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	83 ec 48             	sub    $0x48,%esp
	int r;
	
	// LAB 4: Your code here.
	uint32_t t = uvpt[pn];
  8013dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	void *va_pn = (void *)(pn*PGSIZE);
  8013ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ed:	c1 e0 0c             	shl    $0xc,%eax
  8013f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if((t && PTE_W) || (t && PTE_COW))
  8013f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8013f7:	75 0a                	jne    801403 <duppage+0x2c>
  8013f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8013fd:	0f 84 ed 00 00 00    	je     8014f0 <duppage+0x119>
	{
		r = sys_page_map(0,va_pn,envid,va_pn,PTE_P|PTE_U|PTE_COW);
  801403:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80140a:	00 
  80140b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801412:	8b 45 08             	mov    0x8(%ebp),%eax
  801415:	89 44 24 08          	mov    %eax,0x8(%esp)
  801419:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801420:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801427:	e8 f9 fc ff ff       	call   801125 <sys_page_map>
  80142c:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if(r < 0)
  80142f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801433:	79 1c                	jns    801451 <duppage+0x7a>
		{
			panic("error in page map\n");
  801435:	c7 44 24 08 5c 1f 80 	movl   $0x801f5c,0x8(%esp)
  80143c:	00 
  80143d:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  801444:	00 
  801445:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  80144c:	e8 82 ed ff ff       	call   8001d3 <_panic>
		}
		int r1 = sys_page_map(envid,va_pn,0,va_pn,PTE_P|PTE_U|PTE_COW);
  801451:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801458:	00 
  801459:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801460:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801467:	00 
  801468:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146f:	8b 45 08             	mov    0x8(%ebp),%eax
  801472:	89 04 24             	mov    %eax,(%esp)
  801475:	e8 ab fc ff ff       	call   801125 <sys_page_map>
  80147a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if(r1 < 0)
  80147d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801481:	79 1c                	jns    80149f <duppage+0xc8>
		{
			panic("error in page map\n");
  801483:	c7 44 24 08 5c 1f 80 	movl   $0x801f5c,0x8(%esp)
  80148a:	00 
  80148b:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801492:	00 
  801493:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  80149a:	e8 34 ed ff ff       	call   8001d3 <_panic>
		}
		int r2 = sys_page_map(0,va_pn,0,va_pn,PTE_P|PTE_U|PTE_COW);
  80149f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8014a6:	00 
  8014a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014b5:	00 
  8014b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c4:	e8 5c fc ff ff       	call   801125 <sys_page_map>
  8014c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if(r2 < 0)
  8014cc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8014d0:	79 1c                	jns    8014ee <duppage+0x117>
		{
			panic("error in page map\n");
  8014d2:	c7 44 24 08 5c 1f 80 	movl   $0x801f5c,0x8(%esp)
  8014d9:	00 
  8014da:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  8014e1:	00 
  8014e2:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  8014e9:	e8 e5 ec ff ff       	call   8001d3 <_panic>
	
	// LAB 4: Your code here.
	uint32_t t = uvpt[pn];
	void *va_pn = (void *)(pn*PGSIZE);
	if((t && PTE_W) || (t && PTE_COW))
	{
  8014ee:	eb 4e                	jmp    80153e <duppage+0x167>
			panic("error in page map\n");
		}
	}
	else
	{
		int r3 = sys_page_map(0,va_pn,envid,va_pn,PTE_U|PTE_P);
  8014f0:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8014f7:	00 
  8014f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801502:	89 44 24 08          	mov    %eax,0x8(%esp)
  801506:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801509:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801514:	e8 0c fc ff ff       	call   801125 <sys_page_map>
  801519:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if(r3 < 0)
  80151c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801520:	79 1c                	jns    80153e <duppage+0x167>
		{
			panic("error in page map\n");
  801522:	c7 44 24 08 5c 1f 80 	movl   $0x801f5c,0x8(%esp)
  801529:	00 
  80152a:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  801531:	00 
  801532:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  801539:	e8 95 ec ff ff       	call   8001d3 <_panic>
		}
	}
	// panic("duppage not implemented");
	return 0;
  80153e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801543:	c9                   	leave  
  801544:	c3                   	ret    

00801545 <fork>:


envid_t
fork(void)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	83 ec 38             	sub    $0x38,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80154b:	c7 04 24 b4 12 80 00 	movl   $0x8012b4,(%esp)
  801552:	e8 a6 03 00 00       	call   8018fd <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801557:	b8 07 00 00 00       	mov    $0x7,%eax
  80155c:	cd 30                	int    $0x30
  80155e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  801561:	8b 45 e0             	mov    -0x20(%ebp),%eax
	envid_t envid = sys_exofork();
  801564:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (envid < 0)
  801567:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80156b:	79 1c                	jns    801589 <fork+0x44>
	{
		panic("sys_exofork not succeeded\n");
  80156d:	c7 44 24 08 6f 1f 80 	movl   $0x801f6f,0x8(%esp)
  801574:	00 
  801575:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  80157c:	00 
  80157d:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  801584:	e8 4a ec ff ff       	call   8001d3 <_panic>
	}
	if (envid == 0)
  801589:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80158d:	75 29                	jne    8015b8 <fork+0x73>
	{	
		thisenv = &envs[ENVX(sys_getenvid())];
  80158f:	e8 c8 fa ff ff       	call   80105c <sys_getenvid>
  801594:	25 ff 03 00 00       	and    $0x3ff,%eax
  801599:	c1 e0 02             	shl    $0x2,%eax
  80159c:	89 c2                	mov    %eax,%edx
  80159e:	c1 e2 05             	shl    $0x5,%edx
  8015a1:	29 c2                	sub    %eax,%edx
  8015a3:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8015a9:	a3 04 30 80 00       	mov    %eax,0x803004
		return 0;
  8015ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b3:	e9 2b 01 00 00       	jmp    8016e3 <fork+0x19e>
	}
	else
	{
		int p;
		for (p = 0; p < PGNUM(UTOP); p++) 
  8015b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8015bf:	e9 9a 00 00 00       	jmp    80165e <fork+0x119>
		{
			if(p == PGNUM(UTOP) - 1)
  8015c4:	81 7d f4 ff eb 0e 00 	cmpl   $0xeebff,-0xc(%ebp)
  8015cb:	75 42                	jne    80160f <fork+0xca>
			{
				int r1 = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE), PTE_P|PTE_W|PTE_U);
  8015cd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015d4:	00 
  8015d5:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015dc:	ee 
  8015dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e0:	89 04 24             	mov    %eax,(%esp)
  8015e3:	e8 fc fa ff ff       	call   8010e4 <sys_page_alloc>
  8015e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  				if(r1 < 0)
  8015eb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8015ef:	79 1c                	jns    80160d <fork+0xc8>
  				{
    				panic("sys_page_alloc failed\n");
  8015f1:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8015f8:	00 
  8015f9:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801600:	00 
  801601:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  801608:	e8 c6 eb ff ff       	call   8001d3 <_panic>
				}
				break;
  80160d:	eb 5d                	jmp    80166c <fork+0x127>
			}
			if((uvpd[PDX(p*PGSIZE)]&PTE_P))
  80160f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801612:	c1 e0 0c             	shl    $0xc,%eax
  801615:	c1 e8 16             	shr    $0x16,%eax
  801618:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80161f:	83 e0 01             	and    $0x1,%eax
  801622:	85 c0                	test   %eax,%eax
  801624:	74 34                	je     80165a <fork+0x115>
			{
				if((uvpt[p]&PTE_P) && (uvpt[p] & PTE_U))
  801626:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801629:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801630:	83 e0 01             	and    $0x1,%eax
  801633:	85 c0                	test   %eax,%eax
  801635:	74 23                	je     80165a <fork+0x115>
  801637:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801641:	83 e0 04             	and    $0x4,%eax
  801644:	85 c0                	test   %eax,%eax
  801646:	74 12                	je     80165a <fork+0x115>
				{
					duppage(envid, p);
  801648:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80164b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801652:	89 04 24             	mov    %eax,(%esp)
  801655:	e8 7d fd ff ff       	call   8013d7 <duppage>
		return 0;
	}
	else
	{
		int p;
		for (p = 0; p < PGNUM(UTOP); p++) 
  80165a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  80165e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801661:	3d ff eb 0e 00       	cmp    $0xeebff,%eax
  801666:	0f 86 58 ff ff ff    	jbe    8015c4 <fork+0x7f>
				}
			}	
		}
  		
		extern void _pgfault_upcall();
		int r = sys_env_set_pgfault_upcall(envid,thisenv->env_pgfault_upcall);
  80166c:	a1 04 30 80 00       	mov    0x803004,%eax
  801671:	8b 40 64             	mov    0x64(%eax),%eax
  801674:	89 44 24 04          	mov    %eax,0x4(%esp)
  801678:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167b:	89 04 24             	mov    %eax,(%esp)
  80167e:	e8 6c fb ff ff       	call   8011ef <sys_env_set_pgfault_upcall>
  801683:	89 45 e8             	mov    %eax,-0x18(%ebp)
    	if(r < 0)
  801686:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80168a:	79 1c                	jns    8016a8 <fork+0x163>
    	{
    		panic("sys_env_set_pgfault_upcall failed\n");
  80168c:	c7 44 24 08 a4 1f 80 	movl   $0x801fa4,0x8(%esp)
  801693:	00 
  801694:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  80169b:	00 
  80169c:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  8016a3:	e8 2b eb ff ff       	call   8001d3 <_panic>
    	}
  		int r2 = sys_env_set_status(envid, ENV_RUNNABLE);
  8016a8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8016af:	00 
  8016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b3:	89 04 24             	mov    %eax,(%esp)
  8016b6:	e8 f2 fa ff ff       	call   8011ad <sys_env_set_status>
  8016bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  		if(r2 < 0)
  8016be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8016c2:	79 1c                	jns    8016e0 <fork+0x19b>
  		{
    		panic("sys_env_set_status failes\n");
  8016c4:	c7 44 24 08 c7 1f 80 	movl   $0x801fc7,0x8(%esp)
  8016cb:	00 
  8016cc:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  8016d3:	00 
  8016d4:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  8016db:	e8 f3 ea ff ff       	call   8001d3 <_panic>
    	}
  		return envid;
  8016e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
	}


	// panic("fork not implemented");
}
  8016e3:	c9                   	leave  
  8016e4:	c3                   	ret    

008016e5 <sfork>:


// Challenge!
int
sfork(void)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8016eb:	c7 44 24 08 e2 1f 80 	movl   $0x801fe2,0x8(%esp)
  8016f2:	00 
  8016f3:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
  8016fa:	00 
  8016fb:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  801702:	e8 cc ea ff ff       	call   8001d3 <_panic>

00801707 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int r;
	if(pg != NULL)
  80170d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801711:	74 10                	je     801723 <ipc_recv+0x1c>
	{
		r = sys_ipc_recv(pg);
  801713:	8b 45 0c             	mov    0xc(%ebp),%eax
  801716:	89 04 24             	mov    %eax,(%esp)
  801719:	e8 53 fb ff ff       	call   801271 <sys_ipc_recv>
  80171e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801721:	eb 0f                	jmp    801732 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  801723:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80172a:	e8 42 fb ff ff       	call   801271 <sys_ipc_recv>
  80172f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}

	if(from_env_store != NULL && r == 0) 
  801732:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801736:	74 13                	je     80174b <ipc_recv+0x44>
  801738:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80173c:	75 0d                	jne    80174b <ipc_recv+0x44>
	{
		*from_env_store = thisenv->env_ipc_from;
  80173e:	a1 04 30 80 00       	mov    0x803004,%eax
  801743:	8b 50 74             	mov    0x74(%eax),%edx
  801746:	8b 45 08             	mov    0x8(%ebp),%eax
  801749:	89 10                	mov    %edx,(%eax)
	}
	if(from_env_store != NULL && r < 0)
  80174b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80174f:	74 0f                	je     801760 <ipc_recv+0x59>
  801751:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801755:	79 09                	jns    801760 <ipc_recv+0x59>
	{
		*from_env_store = 0;
  801757:	8b 45 08             	mov    0x8(%ebp),%eax
  80175a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}

	if(perm_store != NULL)
  801760:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801764:	74 28                	je     80178e <ipc_recv+0x87>
	{
		if(r==0 && (uint32_t)pg<UTOP)
  801766:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80176a:	75 19                	jne    801785 <ipc_recv+0x7e>
  80176c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176f:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
  801774:	77 0f                	ja     801785 <ipc_recv+0x7e>
		{
			*perm_store = thisenv->env_ipc_perm;
  801776:	a1 04 30 80 00       	mov    0x803004,%eax
  80177b:	8b 50 78             	mov    0x78(%eax),%edx
  80177e:	8b 45 10             	mov    0x10(%ebp),%eax
  801781:	89 10                	mov    %edx,(%eax)
  801783:	eb 09                	jmp    80178e <ipc_recv+0x87>
		}
		else
		{
			*perm_store = 0;
  801785:	8b 45 10             	mov    0x10(%ebp),%eax
  801788:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		}
	}
	if (r == 0)
  80178e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801792:	75 0a                	jne    80179e <ipc_recv+0x97>
	{
    	return thisenv->env_ipc_value;
  801794:	a1 04 30 80 00       	mov    0x803004,%eax
  801799:	8b 40 70             	mov    0x70(%eax),%eax
  80179c:	eb 03                	jmp    8017a1 <ipc_recv+0x9a>
    } 
  	else
  	{
    	return r;
  80179e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    }
	// panic("ipc_recv not implemented");
	// return 0;
}
  8017a1:	c9                   	leave  
  8017a2:	c3                   	ret    

008017a3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int r;
	if(pg == NULL)
  8017a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017ad:	75 4c                	jne    8017fb <ipc_send+0x58>
	{
		r = sys_ipc_try_send(to_env,val,(void *)UTOP, perm);
  8017af:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017b6:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8017bd:	ee 
  8017be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c8:	89 04 24             	mov    %eax,(%esp)
  8017cb:	e8 61 fa ff ff       	call   801231 <sys_ipc_try_send>
  8017d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	if (r != 0 && r != -E_IPC_NOT_RECV)
  8017d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8017d7:	74 6e                	je     801847 <ipc_send+0xa4>
  8017d9:	83 7d f4 f8          	cmpl   $0xfffffff8,-0xc(%ebp)
  8017dd:	74 68                	je     801847 <ipc_send+0xa4>
    	{
    		panic("in ipc_send\n");
  8017df:	c7 44 24 08 f8 1f 80 	movl   $0x801ff8,0x8(%esp)
  8017e6:	00 
  8017e7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  8017ee:	00 
  8017ef:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8017f6:	e8 d8 e9 ff ff       	call   8001d3 <_panic>
    	} 
	}
	else
	{
		r = sys_ipc_try_send(to_env,val,(void *)UTOP, perm);
  8017fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801802:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801809:	ee 
  80180a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	89 04 24             	mov    %eax,(%esp)
  801817:	e8 15 fa ff ff       	call   801231 <sys_ipc_try_send>
  80181c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	if (r != 0 && r != -E_IPC_NOT_RECV)
  80181f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801823:	74 22                	je     801847 <ipc_send+0xa4>
  801825:	83 7d f4 f8          	cmpl   $0xfffffff8,-0xc(%ebp)
  801829:	74 1c                	je     801847 <ipc_send+0xa4>
    	{
    		panic("in ipc_send\n");
  80182b:	c7 44 24 08 f8 1f 80 	movl   $0x801ff8,0x8(%esp)
  801832:	00 
  801833:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
  80183a:	00 
  80183b:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801842:	e8 8c e9 ff ff       	call   8001d3 <_panic>
    	}	
	}
	while(r != 0)
  801847:	eb 58                	jmp    8018a1 <ipc_send+0xfe>
    //cprintf("[%x]ipc_send\n", thisenv->env_id);
	{
    	r = sys_ipc_try_send(to_env, val, pg ? pg : (void*)UTOP, perm);
  801849:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80184d:	74 05                	je     801854 <ipc_send+0xb1>
  80184f:	8b 45 10             	mov    0x10(%ebp),%eax
  801852:	eb 05                	jmp    801859 <ipc_send+0xb6>
  801854:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801859:	8b 55 14             	mov    0x14(%ebp),%edx
  80185c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801860:	89 44 24 08          	mov    %eax,0x8(%esp)
  801864:	8b 45 0c             	mov    0xc(%ebp),%eax
  801867:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186b:	8b 45 08             	mov    0x8(%ebp),%eax
  80186e:	89 04 24             	mov    %eax,(%esp)
  801871:	e8 bb f9 ff ff       	call   801231 <sys_ipc_try_send>
  801876:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	if (r != 0 && r != -E_IPC_NOT_RECV) 
  801879:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80187d:	74 22                	je     8018a1 <ipc_send+0xfe>
  80187f:	83 7d f4 f8          	cmpl   $0xfffffff8,-0xc(%ebp)
  801883:	74 1c                	je     8018a1 <ipc_send+0xfe>
    	{
      		panic("in ipc_send\n");
  801885:	c7 44 24 08 f8 1f 80 	movl   $0x801ff8,0x8(%esp)
  80188c:	00 
  80188d:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  801894:	00 
  801895:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  80189c:	e8 32 e9 ff ff       	call   8001d3 <_panic>
    	if (r != 0 && r != -E_IPC_NOT_RECV)
    	{
    		panic("in ipc_send\n");
    	}	
	}
	while(r != 0)
  8018a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8018a5:	75 a2                	jne    801849 <ipc_send+0xa6>
    	{
      		panic("in ipc_send\n");
    	}
    } 
	// panic("ipc_send not implemented");
}
  8018a7:	c9                   	leave  
  8018a8:	c3                   	ret    

008018a9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  8018af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8018b6:	eb 35                	jmp    8018ed <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  8018b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018bb:	c1 e0 02             	shl    $0x2,%eax
  8018be:	89 c2                	mov    %eax,%edx
  8018c0:	c1 e2 05             	shl    $0x5,%edx
  8018c3:	29 c2                	sub    %eax,%edx
  8018c5:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  8018cb:	8b 00                	mov    (%eax),%eax
  8018cd:	3b 45 08             	cmp    0x8(%ebp),%eax
  8018d0:	75 17                	jne    8018e9 <ipc_find_env+0x40>
			return envs[i].env_id;
  8018d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018d5:	c1 e0 02             	shl    $0x2,%eax
  8018d8:	89 c2                	mov    %eax,%edx
  8018da:	c1 e2 05             	shl    $0x5,%edx
  8018dd:	29 c2                	sub    %eax,%edx
  8018df:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  8018e5:	8b 00                	mov    (%eax),%eax
  8018e7:	eb 12                	jmp    8018fb <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8018e9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8018ed:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  8018f4:	7e c2                	jle    8018b8 <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8018f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018fb:	c9                   	leave  
  8018fc:	c3                   	ret    

008018fd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  801903:	a1 08 30 80 00       	mov    0x803008,%eax
  801908:	85 c0                	test   %eax,%eax
  80190a:	75 55                	jne    801961 <set_pgfault_handler+0x64>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE),PTE_U|PTE_P|PTE_W);
  80190c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801913:	00 
  801914:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80191b:	ee 
  80191c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801923:	e8 bc f7 ff ff       	call   8010e4 <sys_page_alloc>
  801928:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(r < 0)
  80192b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80192f:	79 1c                	jns    80194d <set_pgfault_handler+0x50>
		{
			panic("sys_page_alloc_failed");
  801931:	c7 44 24 08 0f 20 80 	movl   $0x80200f,0x8(%esp)
  801938:	00 
  801939:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801940:	00 
  801941:	c7 04 24 25 20 80 00 	movl   $0x802025,(%esp)
  801948:	e8 86 e8 ff ff       	call   8001d3 <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80194d:	c7 44 24 04 6b 19 80 	movl   $0x80196b,0x4(%esp)
  801954:	00 
  801955:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80195c:	e8 8e f8 ff ff       	call   8011ef <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801961:	8b 45 08             	mov    0x8(%ebp),%eax
  801964:	a3 08 30 80 00       	mov    %eax,0x803008
}
  801969:	c9                   	leave  
  80196a:	c3                   	ret    

0080196b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80196b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80196c:	a1 08 30 80 00       	mov    0x803008,%eax
	call *%eax
  801971:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801973:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  801976:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  80197a:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80197d:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 0x28(%esp), %ecx
  801981:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  801985:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//add $8, %esp
	popl %edx 
  801987:	5a                   	pop    %edx
	popl %edx
  801988:	5a                   	pop    %edx
	popal
  801989:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  80198a:	83 c4 04             	add    $0x4,%esp
	popf
  80198d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80198e:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80198f:	c3                   	ret    

00801990 <__udivdi3>:
  801990:	55                   	push   %ebp
  801991:	57                   	push   %edi
  801992:	56                   	push   %esi
  801993:	83 ec 0c             	sub    $0xc,%esp
  801996:	8b 44 24 28          	mov    0x28(%esp),%eax
  80199a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80199e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8019a2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019ac:	89 ea                	mov    %ebp,%edx
  8019ae:	89 0c 24             	mov    %ecx,(%esp)
  8019b1:	75 2d                	jne    8019e0 <__udivdi3+0x50>
  8019b3:	39 e9                	cmp    %ebp,%ecx
  8019b5:	77 61                	ja     801a18 <__udivdi3+0x88>
  8019b7:	85 c9                	test   %ecx,%ecx
  8019b9:	89 ce                	mov    %ecx,%esi
  8019bb:	75 0b                	jne    8019c8 <__udivdi3+0x38>
  8019bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c2:	31 d2                	xor    %edx,%edx
  8019c4:	f7 f1                	div    %ecx
  8019c6:	89 c6                	mov    %eax,%esi
  8019c8:	31 d2                	xor    %edx,%edx
  8019ca:	89 e8                	mov    %ebp,%eax
  8019cc:	f7 f6                	div    %esi
  8019ce:	89 c5                	mov    %eax,%ebp
  8019d0:	89 f8                	mov    %edi,%eax
  8019d2:	f7 f6                	div    %esi
  8019d4:	89 ea                	mov    %ebp,%edx
  8019d6:	83 c4 0c             	add    $0xc,%esp
  8019d9:	5e                   	pop    %esi
  8019da:	5f                   	pop    %edi
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    
  8019dd:	8d 76 00             	lea    0x0(%esi),%esi
  8019e0:	39 e8                	cmp    %ebp,%eax
  8019e2:	77 24                	ja     801a08 <__udivdi3+0x78>
  8019e4:	0f bd e8             	bsr    %eax,%ebp
  8019e7:	83 f5 1f             	xor    $0x1f,%ebp
  8019ea:	75 3c                	jne    801a28 <__udivdi3+0x98>
  8019ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8019f0:	39 34 24             	cmp    %esi,(%esp)
  8019f3:	0f 86 9f 00 00 00    	jbe    801a98 <__udivdi3+0x108>
  8019f9:	39 d0                	cmp    %edx,%eax
  8019fb:	0f 82 97 00 00 00    	jb     801a98 <__udivdi3+0x108>
  801a01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801a08:	31 d2                	xor    %edx,%edx
  801a0a:	31 c0                	xor    %eax,%eax
  801a0c:	83 c4 0c             	add    $0xc,%esp
  801a0f:	5e                   	pop    %esi
  801a10:	5f                   	pop    %edi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    
  801a13:	90                   	nop
  801a14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a18:	89 f8                	mov    %edi,%eax
  801a1a:	f7 f1                	div    %ecx
  801a1c:	31 d2                	xor    %edx,%edx
  801a1e:	83 c4 0c             	add    $0xc,%esp
  801a21:	5e                   	pop    %esi
  801a22:	5f                   	pop    %edi
  801a23:	5d                   	pop    %ebp
  801a24:	c3                   	ret    
  801a25:	8d 76 00             	lea    0x0(%esi),%esi
  801a28:	89 e9                	mov    %ebp,%ecx
  801a2a:	8b 3c 24             	mov    (%esp),%edi
  801a2d:	d3 e0                	shl    %cl,%eax
  801a2f:	89 c6                	mov    %eax,%esi
  801a31:	b8 20 00 00 00       	mov    $0x20,%eax
  801a36:	29 e8                	sub    %ebp,%eax
  801a38:	89 c1                	mov    %eax,%ecx
  801a3a:	d3 ef                	shr    %cl,%edi
  801a3c:	89 e9                	mov    %ebp,%ecx
  801a3e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801a42:	8b 3c 24             	mov    (%esp),%edi
  801a45:	09 74 24 08          	or     %esi,0x8(%esp)
  801a49:	89 d6                	mov    %edx,%esi
  801a4b:	d3 e7                	shl    %cl,%edi
  801a4d:	89 c1                	mov    %eax,%ecx
  801a4f:	89 3c 24             	mov    %edi,(%esp)
  801a52:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a56:	d3 ee                	shr    %cl,%esi
  801a58:	89 e9                	mov    %ebp,%ecx
  801a5a:	d3 e2                	shl    %cl,%edx
  801a5c:	89 c1                	mov    %eax,%ecx
  801a5e:	d3 ef                	shr    %cl,%edi
  801a60:	09 d7                	or     %edx,%edi
  801a62:	89 f2                	mov    %esi,%edx
  801a64:	89 f8                	mov    %edi,%eax
  801a66:	f7 74 24 08          	divl   0x8(%esp)
  801a6a:	89 d6                	mov    %edx,%esi
  801a6c:	89 c7                	mov    %eax,%edi
  801a6e:	f7 24 24             	mull   (%esp)
  801a71:	39 d6                	cmp    %edx,%esi
  801a73:	89 14 24             	mov    %edx,(%esp)
  801a76:	72 30                	jb     801aa8 <__udivdi3+0x118>
  801a78:	8b 54 24 04          	mov    0x4(%esp),%edx
  801a7c:	89 e9                	mov    %ebp,%ecx
  801a7e:	d3 e2                	shl    %cl,%edx
  801a80:	39 c2                	cmp    %eax,%edx
  801a82:	73 05                	jae    801a89 <__udivdi3+0xf9>
  801a84:	3b 34 24             	cmp    (%esp),%esi
  801a87:	74 1f                	je     801aa8 <__udivdi3+0x118>
  801a89:	89 f8                	mov    %edi,%eax
  801a8b:	31 d2                	xor    %edx,%edx
  801a8d:	e9 7a ff ff ff       	jmp    801a0c <__udivdi3+0x7c>
  801a92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801a98:	31 d2                	xor    %edx,%edx
  801a9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a9f:	e9 68 ff ff ff       	jmp    801a0c <__udivdi3+0x7c>
  801aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801aa8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801aab:	31 d2                	xor    %edx,%edx
  801aad:	83 c4 0c             	add    $0xc,%esp
  801ab0:	5e                   	pop    %esi
  801ab1:	5f                   	pop    %edi
  801ab2:	5d                   	pop    %ebp
  801ab3:	c3                   	ret    
  801ab4:	66 90                	xchg   %ax,%ax
  801ab6:	66 90                	xchg   %ax,%ax
  801ab8:	66 90                	xchg   %ax,%ax
  801aba:	66 90                	xchg   %ax,%ax
  801abc:	66 90                	xchg   %ax,%ax
  801abe:	66 90                	xchg   %ax,%ax

00801ac0 <__umoddi3>:
  801ac0:	55                   	push   %ebp
  801ac1:	57                   	push   %edi
  801ac2:	56                   	push   %esi
  801ac3:	83 ec 14             	sub    $0x14,%esp
  801ac6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801aca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801ace:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801ad2:	89 c7                	mov    %eax,%edi
  801ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801adc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801ae0:	89 34 24             	mov    %esi,(%esp)
  801ae3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	89 c2                	mov    %eax,%edx
  801aeb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801aef:	75 17                	jne    801b08 <__umoddi3+0x48>
  801af1:	39 fe                	cmp    %edi,%esi
  801af3:	76 4b                	jbe    801b40 <__umoddi3+0x80>
  801af5:	89 c8                	mov    %ecx,%eax
  801af7:	89 fa                	mov    %edi,%edx
  801af9:	f7 f6                	div    %esi
  801afb:	89 d0                	mov    %edx,%eax
  801afd:	31 d2                	xor    %edx,%edx
  801aff:	83 c4 14             	add    $0x14,%esp
  801b02:	5e                   	pop    %esi
  801b03:	5f                   	pop    %edi
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    
  801b06:	66 90                	xchg   %ax,%ax
  801b08:	39 f8                	cmp    %edi,%eax
  801b0a:	77 54                	ja     801b60 <__umoddi3+0xa0>
  801b0c:	0f bd e8             	bsr    %eax,%ebp
  801b0f:	83 f5 1f             	xor    $0x1f,%ebp
  801b12:	75 5c                	jne    801b70 <__umoddi3+0xb0>
  801b14:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b18:	39 3c 24             	cmp    %edi,(%esp)
  801b1b:	0f 87 e7 00 00 00    	ja     801c08 <__umoddi3+0x148>
  801b21:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b25:	29 f1                	sub    %esi,%ecx
  801b27:	19 c7                	sbb    %eax,%edi
  801b29:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b2d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b31:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b35:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801b39:	83 c4 14             	add    $0x14,%esp
  801b3c:	5e                   	pop    %esi
  801b3d:	5f                   	pop    %edi
  801b3e:	5d                   	pop    %ebp
  801b3f:	c3                   	ret    
  801b40:	85 f6                	test   %esi,%esi
  801b42:	89 f5                	mov    %esi,%ebp
  801b44:	75 0b                	jne    801b51 <__umoddi3+0x91>
  801b46:	b8 01 00 00 00       	mov    $0x1,%eax
  801b4b:	31 d2                	xor    %edx,%edx
  801b4d:	f7 f6                	div    %esi
  801b4f:	89 c5                	mov    %eax,%ebp
  801b51:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b55:	31 d2                	xor    %edx,%edx
  801b57:	f7 f5                	div    %ebp
  801b59:	89 c8                	mov    %ecx,%eax
  801b5b:	f7 f5                	div    %ebp
  801b5d:	eb 9c                	jmp    801afb <__umoddi3+0x3b>
  801b5f:	90                   	nop
  801b60:	89 c8                	mov    %ecx,%eax
  801b62:	89 fa                	mov    %edi,%edx
  801b64:	83 c4 14             	add    $0x14,%esp
  801b67:	5e                   	pop    %esi
  801b68:	5f                   	pop    %edi
  801b69:	5d                   	pop    %ebp
  801b6a:	c3                   	ret    
  801b6b:	90                   	nop
  801b6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b70:	8b 04 24             	mov    (%esp),%eax
  801b73:	be 20 00 00 00       	mov    $0x20,%esi
  801b78:	89 e9                	mov    %ebp,%ecx
  801b7a:	29 ee                	sub    %ebp,%esi
  801b7c:	d3 e2                	shl    %cl,%edx
  801b7e:	89 f1                	mov    %esi,%ecx
  801b80:	d3 e8                	shr    %cl,%eax
  801b82:	89 e9                	mov    %ebp,%ecx
  801b84:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b88:	8b 04 24             	mov    (%esp),%eax
  801b8b:	09 54 24 04          	or     %edx,0x4(%esp)
  801b8f:	89 fa                	mov    %edi,%edx
  801b91:	d3 e0                	shl    %cl,%eax
  801b93:	89 f1                	mov    %esi,%ecx
  801b95:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b99:	8b 44 24 10          	mov    0x10(%esp),%eax
  801b9d:	d3 ea                	shr    %cl,%edx
  801b9f:	89 e9                	mov    %ebp,%ecx
  801ba1:	d3 e7                	shl    %cl,%edi
  801ba3:	89 f1                	mov    %esi,%ecx
  801ba5:	d3 e8                	shr    %cl,%eax
  801ba7:	89 e9                	mov    %ebp,%ecx
  801ba9:	09 f8                	or     %edi,%eax
  801bab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801baf:	f7 74 24 04          	divl   0x4(%esp)
  801bb3:	d3 e7                	shl    %cl,%edi
  801bb5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bb9:	89 d7                	mov    %edx,%edi
  801bbb:	f7 64 24 08          	mull   0x8(%esp)
  801bbf:	39 d7                	cmp    %edx,%edi
  801bc1:	89 c1                	mov    %eax,%ecx
  801bc3:	89 14 24             	mov    %edx,(%esp)
  801bc6:	72 2c                	jb     801bf4 <__umoddi3+0x134>
  801bc8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801bcc:	72 22                	jb     801bf0 <__umoddi3+0x130>
  801bce:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801bd2:	29 c8                	sub    %ecx,%eax
  801bd4:	19 d7                	sbb    %edx,%edi
  801bd6:	89 e9                	mov    %ebp,%ecx
  801bd8:	89 fa                	mov    %edi,%edx
  801bda:	d3 e8                	shr    %cl,%eax
  801bdc:	89 f1                	mov    %esi,%ecx
  801bde:	d3 e2                	shl    %cl,%edx
  801be0:	89 e9                	mov    %ebp,%ecx
  801be2:	d3 ef                	shr    %cl,%edi
  801be4:	09 d0                	or     %edx,%eax
  801be6:	89 fa                	mov    %edi,%edx
  801be8:	83 c4 14             	add    $0x14,%esp
  801beb:	5e                   	pop    %esi
  801bec:	5f                   	pop    %edi
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    
  801bef:	90                   	nop
  801bf0:	39 d7                	cmp    %edx,%edi
  801bf2:	75 da                	jne    801bce <__umoddi3+0x10e>
  801bf4:	8b 14 24             	mov    (%esp),%edx
  801bf7:	89 c1                	mov    %eax,%ecx
  801bf9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801bfd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801c01:	eb cb                	jmp    801bce <__umoddi3+0x10e>
  801c03:	90                   	nop
  801c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c08:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801c0c:	0f 82 0f ff ff ff    	jb     801b21 <__umoddi3+0x61>
  801c12:	e9 1a ff ff ff       	jmp    801b31 <__umoddi3+0x71>
