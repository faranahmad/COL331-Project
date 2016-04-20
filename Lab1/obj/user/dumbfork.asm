
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 62 02 00 00       	call   800293 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  800039:	e8 56 01 00 00       	call   800194 <dumbfork>
  80003e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800041:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800048:	eb 32                	jmp    80007c <umain+0x49>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80004a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80004e:	74 07                	je     800057 <umain+0x24>
  800050:	b8 80 16 80 00       	mov    $0x801680,%eax
  800055:	eb 05                	jmp    80005c <umain+0x29>
  800057:	b8 87 16 80 00       	mov    $0x801687,%eax
  80005c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800060:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800063:	89 44 24 04          	mov    %eax,0x4(%esp)
  800067:	c7 04 24 8d 16 80 00 	movl   $0x80168d,(%esp)
  80006e:	e8 9d 03 00 00       	call   800410 <cprintf>
		sys_yield();
  800073:	e8 4a 11 00 00       	call   8011c2 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800078:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  80007c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800080:	74 07                	je     800089 <umain+0x56>
  800082:	b8 0a 00 00 00       	mov    $0xa,%eax
  800087:	eb 05                	jmp    80008e <umain+0x5b>
  800089:	b8 14 00 00 00       	mov    $0x14,%eax
  80008e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  800091:	7f b7                	jg     80004a <umain+0x17>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800093:	c9                   	leave  
  800094:	c3                   	ret    

00800095 <duppage>:

void
duppage(envid_t dstenv, void *addr)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	83 ec 38             	sub    $0x38,%esp
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80009b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8000a2:	00 
  8000a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ad:	89 04 24             	mov    %eax,(%esp)
  8000b0:	e8 51 11 00 00       	call   801206 <sys_page_alloc>
  8000b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8000b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8000bc:	79 23                	jns    8000e1 <duppage+0x4c>
		panic("sys_page_alloc: %e", r);
  8000be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c5:	c7 44 24 08 9f 16 80 	movl   $0x80169f,0x8(%esp)
  8000cc:	00 
  8000cd:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000d4:	00 
  8000d5:	c7 04 24 b2 16 80 00 	movl   $0x8016b2,(%esp)
  8000dc:	e8 14 02 00 00       	call   8002f5 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8000e1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8000e8:	00 
  8000e9:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  8000f0:	00 
  8000f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000f8:	00 
  8000f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800100:	8b 45 08             	mov    0x8(%ebp),%eax
  800103:	89 04 24             	mov    %eax,(%esp)
  800106:	e8 3c 11 00 00       	call   801247 <sys_page_map>
  80010b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80010e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800112:	79 23                	jns    800137 <duppage+0xa2>
		panic("sys_page_map: %e", r);
  800114:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800117:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011b:	c7 44 24 08 c2 16 80 	movl   $0x8016c2,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 b2 16 80 00 	movl   $0x8016b2,(%esp)
  800132:	e8 be 01 00 00       	call   8002f5 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  800137:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80013e:	00 
  80013f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800142:	89 44 24 04          	mov    %eax,0x4(%esp)
  800146:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  80014d:	e8 1e 0c 00 00       	call   800d70 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800152:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800159:	00 
  80015a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800161:	e8 27 11 00 00       	call   80128d <sys_page_unmap>
  800166:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800169:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80016d:	79 23                	jns    800192 <duppage+0xfd>
		panic("sys_page_unmap: %e", r);
  80016f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800172:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800176:	c7 44 24 08 d3 16 80 	movl   $0x8016d3,0x8(%esp)
  80017d:	00 
  80017e:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800185:	00 
  800186:	c7 04 24 b2 16 80 00 	movl   $0x8016b2,(%esp)
  80018d:	e8 63 01 00 00       	call   8002f5 <_panic>
}
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <dumbfork>:

envid_t
dumbfork(void)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 38             	sub    $0x38,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80019a:	b8 07 00 00 00       	mov    $0x7,%eax
  80019f:	cd 30                	int    $0x30
  8001a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  8001a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
	// Allocate a new child environment.
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
  8001a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0)
  8001aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8001ae:	79 23                	jns    8001d3 <dumbfork+0x3f>
		panic("sys_exofork: %e", envid);
  8001b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b7:	c7 44 24 08 e6 16 80 	movl   $0x8016e6,0x8(%esp)
  8001be:	00 
  8001bf:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  8001c6:	00 
  8001c7:	c7 04 24 b2 16 80 00 	movl   $0x8016b2,(%esp)
  8001ce:	e8 22 01 00 00       	call   8002f5 <_panic>
	if (envid == 0) {
  8001d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8001d7:	75 29                	jne    800202 <dumbfork+0x6e>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8001d9:	e8 a0 0f 00 00       	call   80117e <sys_getenvid>
  8001de:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e3:	c1 e0 02             	shl    $0x2,%eax
  8001e6:	89 c2                	mov    %eax,%edx
  8001e8:	c1 e2 05             	shl    $0x5,%edx
  8001eb:	29 c2                	sub    %eax,%edx
  8001ed:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8001f3:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  8001f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8001fd:	e9 8f 00 00 00       	jmp    800291 <dumbfork+0xfd>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800202:	c7 45 e4 00 00 80 00 	movl   $0x800000,-0x1c(%ebp)
  800209:	eb 1d                	jmp    800228 <dumbfork+0x94>
		duppage(envid, addr);
  80020b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800212:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800215:	89 04 24             	mov    %eax,(%esp)
  800218:	e8 78 fe ff ff       	call   800095 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80021d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800220:	05 00 10 00 00       	add    $0x1000,%eax
  800225:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800228:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022b:	3d 08 20 80 00       	cmp    $0x802008,%eax
  800230:	72 d9                	jb     80020b <dumbfork+0x77>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800232:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800235:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800238:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80023b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800240:	89 44 24 04          	mov    %eax,0x4(%esp)
  800244:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800247:	89 04 24             	mov    %eax,(%esp)
  80024a:	e8 46 fe ff ff       	call   800095 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80024f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  800256:	00 
  800257:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80025a:	89 04 24             	mov    %eax,(%esp)
  80025d:	e8 6d 10 00 00       	call   8012cf <sys_env_set_status>
  800262:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800265:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800269:	79 23                	jns    80028e <dumbfork+0xfa>
		panic("sys_env_set_status: %e", r);
  80026b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80026e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800272:	c7 44 24 08 f6 16 80 	movl   $0x8016f6,0x8(%esp)
  800279:	00 
  80027a:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  800281:	00 
  800282:	c7 04 24 b2 16 80 00 	movl   $0x8016b2,(%esp)
  800289:	e8 67 00 00 00       	call   8002f5 <_panic>

	return envid;
  80028e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800291:	c9                   	leave  
  800292:	c3                   	ret    

00800293 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800299:	e8 e0 0e 00 00       	call   80117e <sys_getenvid>
  80029e:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002a3:	c1 e0 02             	shl    $0x2,%eax
  8002a6:	89 c2                	mov    %eax,%edx
  8002a8:	c1 e2 05             	shl    $0x5,%edx
  8002ab:	29 c2                	sub    %eax,%edx
  8002ad:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8002b3:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002b8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8002bc:	7e 0a                	jle    8002c8 <libmain+0x35>
		binaryname = argv[0];
  8002be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c1:	8b 00                	mov    (%eax),%eax
  8002c3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8002c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	e8 59 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002da:	e8 02 00 00 00       	call   8002e1 <exit>
}
  8002df:	c9                   	leave  
  8002e0:	c3                   	ret    

008002e1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002ee:	e8 48 0e 00 00       	call   80113b <sys_env_destroy>
}
  8002f3:	c9                   	leave  
  8002f4:	c3                   	ret    

008002f5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	53                   	push   %ebx
  8002f9:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8002ff:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800302:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800308:	e8 71 0e 00 00       	call   80117e <sys_getenvid>
  80030d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800310:	89 54 24 10          	mov    %edx,0x10(%esp)
  800314:	8b 55 08             	mov    0x8(%ebp),%edx
  800317:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80031b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80031f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800323:	c7 04 24 18 17 80 00 	movl   $0x801718,(%esp)
  80032a:	e8 e1 00 00 00       	call   800410 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80032f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800332:	89 44 24 04          	mov    %eax,0x4(%esp)
  800336:	8b 45 10             	mov    0x10(%ebp),%eax
  800339:	89 04 24             	mov    %eax,(%esp)
  80033c:	e8 6b 00 00 00       	call   8003ac <vcprintf>
	cprintf("\n");
  800341:	c7 04 24 3b 17 80 00 	movl   $0x80173b,(%esp)
  800348:	e8 c3 00 00 00       	call   800410 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80034d:	cc                   	int3   
  80034e:	eb fd                	jmp    80034d <_panic+0x58>

00800350 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800356:	8b 45 0c             	mov    0xc(%ebp),%eax
  800359:	8b 00                	mov    (%eax),%eax
  80035b:	8d 48 01             	lea    0x1(%eax),%ecx
  80035e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800361:	89 0a                	mov    %ecx,(%edx)
  800363:	8b 55 08             	mov    0x8(%ebp),%edx
  800366:	89 d1                	mov    %edx,%ecx
  800368:	8b 55 0c             	mov    0xc(%ebp),%edx
  80036b:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  80036f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800372:	8b 00                	mov    (%eax),%eax
  800374:	3d ff 00 00 00       	cmp    $0xff,%eax
  800379:	75 20                	jne    80039b <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80037b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80037e:	8b 00                	mov    (%eax),%eax
  800380:	8b 55 0c             	mov    0xc(%ebp),%edx
  800383:	83 c2 08             	add    $0x8,%edx
  800386:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038a:	89 14 24             	mov    %edx,(%esp)
  80038d:	e8 23 0d 00 00       	call   8010b5 <sys_cputs>
		b->idx = 0;
  800392:	8b 45 0c             	mov    0xc(%ebp),%eax
  800395:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80039b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80039e:	8b 40 04             	mov    0x4(%eax),%eax
  8003a1:	8d 50 01             	lea    0x1(%eax),%edx
  8003a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a7:	89 50 04             	mov    %edx,0x4(%eax)
}
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bc:	00 00 00 
	b.cnt = 0;
  8003bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e1:	c7 04 24 50 03 80 00 	movl   $0x800350,(%esp)
  8003e8:	e8 bd 01 00 00       	call   8005aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ed:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003fd:	83 c0 08             	add    $0x8,%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	e8 ad 0c 00 00       	call   8010b5 <sys_cputs>

	return b.cnt;
  800408:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80040e:	c9                   	leave  
  80040f:	c3                   	ret    

00800410 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800416:	8d 45 0c             	lea    0xc(%ebp),%eax
  800419:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80041c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80041f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800423:	8b 45 08             	mov    0x8(%ebp),%eax
  800426:	89 04 24             	mov    %eax,(%esp)
  800429:	e8 7e ff ff ff       	call   8003ac <vcprintf>
  80042e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800431:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800434:	c9                   	leave  
  800435:	c3                   	ret    

00800436 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	53                   	push   %ebx
  80043a:	83 ec 34             	sub    $0x34,%esp
  80043d:	8b 45 10             	mov    0x10(%ebp),%eax
  800440:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800449:	8b 45 18             	mov    0x18(%ebp),%eax
  80044c:	ba 00 00 00 00       	mov    $0x0,%edx
  800451:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800454:	77 72                	ja     8004c8 <printnum+0x92>
  800456:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800459:	72 05                	jb     800460 <printnum+0x2a>
  80045b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80045e:	77 68                	ja     8004c8 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800460:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800463:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800466:	8b 45 18             	mov    0x18(%ebp),%eax
  800469:	ba 00 00 00 00       	mov    $0x0,%edx
  80046e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800472:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800476:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800479:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80047c:	89 04 24             	mov    %eax,(%esp)
  80047f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800483:	e8 58 0f 00 00       	call   8013e0 <__udivdi3>
  800488:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80048b:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  80048f:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800493:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800496:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80049a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80049e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ac:	89 04 24             	mov    %eax,(%esp)
  8004af:	e8 82 ff ff ff       	call   800436 <printnum>
  8004b4:	eb 1c                	jmp    8004d2 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004bd:	8b 45 20             	mov    0x20(%ebp),%eax
  8004c0:	89 04 24             	mov    %eax,(%esp)
  8004c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c6:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004c8:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8004cc:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8004d0:	7f e4                	jg     8004b6 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004d2:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8004e0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004e4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004e8:	89 04 24             	mov    %eax,(%esp)
  8004eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004ef:	e8 1c 10 00 00       	call   801510 <__umoddi3>
  8004f4:	05 08 18 80 00       	add    $0x801808,%eax
  8004f9:	0f b6 00             	movzbl (%eax),%eax
  8004fc:	0f be c0             	movsbl %al,%eax
  8004ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800502:	89 54 24 04          	mov    %edx,0x4(%esp)
  800506:	89 04 24             	mov    %eax,(%esp)
  800509:	8b 45 08             	mov    0x8(%ebp),%eax
  80050c:	ff d0                	call   *%eax
}
  80050e:	83 c4 34             	add    $0x34,%esp
  800511:	5b                   	pop    %ebx
  800512:	5d                   	pop    %ebp
  800513:	c3                   	ret    

00800514 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800514:	55                   	push   %ebp
  800515:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800517:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80051b:	7e 14                	jle    800531 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80051d:	8b 45 08             	mov    0x8(%ebp),%eax
  800520:	8b 00                	mov    (%eax),%eax
  800522:	8d 48 08             	lea    0x8(%eax),%ecx
  800525:	8b 55 08             	mov    0x8(%ebp),%edx
  800528:	89 0a                	mov    %ecx,(%edx)
  80052a:	8b 50 04             	mov    0x4(%eax),%edx
  80052d:	8b 00                	mov    (%eax),%eax
  80052f:	eb 30                	jmp    800561 <getuint+0x4d>
	else if (lflag)
  800531:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800535:	74 16                	je     80054d <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800537:	8b 45 08             	mov    0x8(%ebp),%eax
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	8d 48 04             	lea    0x4(%eax),%ecx
  80053f:	8b 55 08             	mov    0x8(%ebp),%edx
  800542:	89 0a                	mov    %ecx,(%edx)
  800544:	8b 00                	mov    (%eax),%eax
  800546:	ba 00 00 00 00       	mov    $0x0,%edx
  80054b:	eb 14                	jmp    800561 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80054d:	8b 45 08             	mov    0x8(%ebp),%eax
  800550:	8b 00                	mov    (%eax),%eax
  800552:	8d 48 04             	lea    0x4(%eax),%ecx
  800555:	8b 55 08             	mov    0x8(%ebp),%edx
  800558:	89 0a                	mov    %ecx,(%edx)
  80055a:	8b 00                	mov    (%eax),%eax
  80055c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800561:	5d                   	pop    %ebp
  800562:	c3                   	ret    

00800563 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800563:	55                   	push   %ebp
  800564:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800566:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80056a:	7e 14                	jle    800580 <getint+0x1d>
		return va_arg(*ap, long long);
  80056c:	8b 45 08             	mov    0x8(%ebp),%eax
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	8d 48 08             	lea    0x8(%eax),%ecx
  800574:	8b 55 08             	mov    0x8(%ebp),%edx
  800577:	89 0a                	mov    %ecx,(%edx)
  800579:	8b 50 04             	mov    0x4(%eax),%edx
  80057c:	8b 00                	mov    (%eax),%eax
  80057e:	eb 28                	jmp    8005a8 <getint+0x45>
	else if (lflag)
  800580:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800584:	74 12                	je     800598 <getint+0x35>
		return va_arg(*ap, long);
  800586:	8b 45 08             	mov    0x8(%ebp),%eax
  800589:	8b 00                	mov    (%eax),%eax
  80058b:	8d 48 04             	lea    0x4(%eax),%ecx
  80058e:	8b 55 08             	mov    0x8(%ebp),%edx
  800591:	89 0a                	mov    %ecx,(%edx)
  800593:	8b 00                	mov    (%eax),%eax
  800595:	99                   	cltd   
  800596:	eb 10                	jmp    8005a8 <getint+0x45>
	else
		return va_arg(*ap, int);
  800598:	8b 45 08             	mov    0x8(%ebp),%eax
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	8d 48 04             	lea    0x4(%eax),%ecx
  8005a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a3:	89 0a                	mov    %ecx,(%edx)
  8005a5:	8b 00                	mov    (%eax),%eax
  8005a7:	99                   	cltd   
}
  8005a8:	5d                   	pop    %ebp
  8005a9:	c3                   	ret    

008005aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005aa:	55                   	push   %ebp
  8005ab:	89 e5                	mov    %esp,%ebp
  8005ad:	56                   	push   %esi
  8005ae:	53                   	push   %ebx
  8005af:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005b2:	eb 18                	jmp    8005cc <vprintfmt+0x22>
			if (ch == '\0')
  8005b4:	85 db                	test   %ebx,%ebx
  8005b6:	75 05                	jne    8005bd <vprintfmt+0x13>
				return;
  8005b8:	e9 05 04 00 00       	jmp    8009c2 <vprintfmt+0x418>
			putch(ch, putdat);
  8005bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c4:	89 1c 24             	mov    %ebx,(%esp)
  8005c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ca:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8005cf:	8d 50 01             	lea    0x1(%eax),%edx
  8005d2:	89 55 10             	mov    %edx,0x10(%ebp)
  8005d5:	0f b6 00             	movzbl (%eax),%eax
  8005d8:	0f b6 d8             	movzbl %al,%ebx
  8005db:	83 fb 25             	cmp    $0x25,%ebx
  8005de:	75 d4                	jne    8005b4 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8005e0:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8005e4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8005eb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005f2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8005f9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800600:	8b 45 10             	mov    0x10(%ebp),%eax
  800603:	8d 50 01             	lea    0x1(%eax),%edx
  800606:	89 55 10             	mov    %edx,0x10(%ebp)
  800609:	0f b6 00             	movzbl (%eax),%eax
  80060c:	0f b6 d8             	movzbl %al,%ebx
  80060f:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800612:	83 f8 55             	cmp    $0x55,%eax
  800615:	0f 87 76 03 00 00    	ja     800991 <vprintfmt+0x3e7>
  80061b:	8b 04 85 2c 18 80 00 	mov    0x80182c(,%eax,4),%eax
  800622:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800624:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800628:	eb d6                	jmp    800600 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80062a:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80062e:	eb d0                	jmp    800600 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800630:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800637:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80063a:	89 d0                	mov    %edx,%eax
  80063c:	c1 e0 02             	shl    $0x2,%eax
  80063f:	01 d0                	add    %edx,%eax
  800641:	01 c0                	add    %eax,%eax
  800643:	01 d8                	add    %ebx,%eax
  800645:	83 e8 30             	sub    $0x30,%eax
  800648:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80064b:	8b 45 10             	mov    0x10(%ebp),%eax
  80064e:	0f b6 00             	movzbl (%eax),%eax
  800651:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800654:	83 fb 2f             	cmp    $0x2f,%ebx
  800657:	7e 0b                	jle    800664 <vprintfmt+0xba>
  800659:	83 fb 39             	cmp    $0x39,%ebx
  80065c:	7f 06                	jg     800664 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80065e:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800662:	eb d3                	jmp    800637 <vprintfmt+0x8d>
			goto process_precision;
  800664:	eb 33                	jmp    800699 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800674:	eb 23                	jmp    800699 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800676:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80067a:	79 0c                	jns    800688 <vprintfmt+0xde>
				width = 0;
  80067c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800683:	e9 78 ff ff ff       	jmp    800600 <vprintfmt+0x56>
  800688:	e9 73 ff ff ff       	jmp    800600 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80068d:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800694:	e9 67 ff ff ff       	jmp    800600 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800699:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80069d:	79 12                	jns    8006b1 <vprintfmt+0x107>
				width = precision, precision = -1;
  80069f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8006ac:	e9 4f ff ff ff       	jmp    800600 <vprintfmt+0x56>
  8006b1:	e9 4a ff ff ff       	jmp    800600 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006b6:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8006ba:	e9 41 ff ff ff       	jmp    800600 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8d 50 04             	lea    0x4(%eax),%edx
  8006c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c8:	8b 00                	mov    (%eax),%eax
  8006ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006d1:	89 04 24             	mov    %eax,(%esp)
  8006d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d7:	ff d0                	call   *%eax
			break;
  8006d9:	e9 de 02 00 00       	jmp    8009bc <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 50 04             	lea    0x4(%eax),%edx
  8006e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e7:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8006e9:	85 db                	test   %ebx,%ebx
  8006eb:	79 02                	jns    8006ef <vprintfmt+0x145>
				err = -err;
  8006ed:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006ef:	83 fb 09             	cmp    $0x9,%ebx
  8006f2:	7f 0b                	jg     8006ff <vprintfmt+0x155>
  8006f4:	8b 34 9d e0 17 80 00 	mov    0x8017e0(,%ebx,4),%esi
  8006fb:	85 f6                	test   %esi,%esi
  8006fd:	75 23                	jne    800722 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8006ff:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800703:	c7 44 24 08 19 18 80 	movl   $0x801819,0x8(%esp)
  80070a:	00 
  80070b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80070e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800712:	8b 45 08             	mov    0x8(%ebp),%eax
  800715:	89 04 24             	mov    %eax,(%esp)
  800718:	e8 ac 02 00 00       	call   8009c9 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80071d:	e9 9a 02 00 00       	jmp    8009bc <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800722:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800726:	c7 44 24 08 22 18 80 	movl   $0x801822,0x8(%esp)
  80072d:	00 
  80072e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800731:	89 44 24 04          	mov    %eax,0x4(%esp)
  800735:	8b 45 08             	mov    0x8(%ebp),%eax
  800738:	89 04 24             	mov    %eax,(%esp)
  80073b:	e8 89 02 00 00       	call   8009c9 <printfmt>
			break;
  800740:	e9 77 02 00 00       	jmp    8009bc <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800745:	8b 45 14             	mov    0x14(%ebp),%eax
  800748:	8d 50 04             	lea    0x4(%eax),%edx
  80074b:	89 55 14             	mov    %edx,0x14(%ebp)
  80074e:	8b 30                	mov    (%eax),%esi
  800750:	85 f6                	test   %esi,%esi
  800752:	75 05                	jne    800759 <vprintfmt+0x1af>
				p = "(null)";
  800754:	be 25 18 80 00       	mov    $0x801825,%esi
			if (width > 0 && padc != '-')
  800759:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80075d:	7e 37                	jle    800796 <vprintfmt+0x1ec>
  80075f:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800763:	74 31                	je     800796 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800765:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800768:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076c:	89 34 24             	mov    %esi,(%esp)
  80076f:	e8 72 03 00 00       	call   800ae6 <strnlen>
  800774:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800777:	eb 17                	jmp    800790 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800779:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80077d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800780:	89 54 24 04          	mov    %edx,0x4(%esp)
  800784:	89 04 24             	mov    %eax,(%esp)
  800787:	8b 45 08             	mov    0x8(%ebp),%eax
  80078a:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80078c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800790:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800794:	7f e3                	jg     800779 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800796:	eb 38                	jmp    8007d0 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800798:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80079c:	74 1f                	je     8007bd <vprintfmt+0x213>
  80079e:	83 fb 1f             	cmp    $0x1f,%ebx
  8007a1:	7e 05                	jle    8007a8 <vprintfmt+0x1fe>
  8007a3:	83 fb 7e             	cmp    $0x7e,%ebx
  8007a6:	7e 15                	jle    8007bd <vprintfmt+0x213>
					putch('?', putdat);
  8007a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007af:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	ff d0                	call   *%eax
  8007bb:	eb 0f                	jmp    8007cc <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c4:	89 1c 24             	mov    %ebx,(%esp)
  8007c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ca:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007cc:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8007d0:	89 f0                	mov    %esi,%eax
  8007d2:	8d 70 01             	lea    0x1(%eax),%esi
  8007d5:	0f b6 00             	movzbl (%eax),%eax
  8007d8:	0f be d8             	movsbl %al,%ebx
  8007db:	85 db                	test   %ebx,%ebx
  8007dd:	74 10                	je     8007ef <vprintfmt+0x245>
  8007df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007e3:	78 b3                	js     800798 <vprintfmt+0x1ee>
  8007e5:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8007e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007ed:	79 a9                	jns    800798 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007ef:	eb 17                	jmp    800808 <vprintfmt+0x25e>
				putch(' ', putdat);
  8007f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800804:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800808:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80080c:	7f e3                	jg     8007f1 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80080e:	e9 a9 01 00 00       	jmp    8009bc <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800813:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800816:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081a:	8d 45 14             	lea    0x14(%ebp),%eax
  80081d:	89 04 24             	mov    %eax,(%esp)
  800820:	e8 3e fd ff ff       	call   800563 <getint>
  800825:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800828:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80082b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800831:	85 d2                	test   %edx,%edx
  800833:	79 26                	jns    80085b <vprintfmt+0x2b1>
				putch('-', putdat);
  800835:	8b 45 0c             	mov    0xc(%ebp),%eax
  800838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	ff d0                	call   *%eax
				num = -(long long) num;
  800848:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80084e:	f7 d8                	neg    %eax
  800850:	83 d2 00             	adc    $0x0,%edx
  800853:	f7 da                	neg    %edx
  800855:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800858:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80085b:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800862:	e9 e1 00 00 00       	jmp    800948 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800867:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80086a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086e:	8d 45 14             	lea    0x14(%ebp),%eax
  800871:	89 04 24             	mov    %eax,(%esp)
  800874:	e8 9b fc ff ff       	call   800514 <getuint>
  800879:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80087c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  80087f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800886:	e9 bd 00 00 00       	jmp    800948 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  80088b:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  800892:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800895:	89 44 24 04          	mov    %eax,0x4(%esp)
  800899:	8d 45 14             	lea    0x14(%ebp),%eax
  80089c:	89 04 24             	mov    %eax,(%esp)
  80089f:	e8 70 fc ff ff       	call   800514 <getuint>
  8008a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008a7:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  8008aa:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8008ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b1:	89 54 24 18          	mov    %edx,0x18(%esp)
  8008b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008b8:	89 54 24 14          	mov    %edx,0x14(%esp)
  8008bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	89 04 24             	mov    %eax,(%esp)
  8008db:	e8 56 fb ff ff       	call   800436 <printnum>
			break;
  8008e0:	e9 d7 00 00 00       	jmp    8009bc <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  8008e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ec:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	ff d0                	call   *%eax
			putch('x', putdat);
  8008f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ff:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80090b:	8b 45 14             	mov    0x14(%ebp),%eax
  80090e:	8d 50 04             	lea    0x4(%eax),%edx
  800911:	89 55 14             	mov    %edx,0x14(%ebp)
  800914:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800916:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800919:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800920:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800927:	eb 1f                	jmp    800948 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800929:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80092c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800930:	8d 45 14             	lea    0x14(%ebp),%eax
  800933:	89 04 24             	mov    %eax,(%esp)
  800936:	e8 d9 fb ff ff       	call   800514 <getuint>
  80093b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80093e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800941:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800948:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80094c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80094f:	89 54 24 18          	mov    %edx,0x18(%esp)
  800953:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800956:	89 54 24 14          	mov    %edx,0x14(%esp)
  80095a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80095e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800961:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800964:	89 44 24 08          	mov    %eax,0x8(%esp)
  800968:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80096c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	89 04 24             	mov    %eax,(%esp)
  800979:	e8 b8 fa ff ff       	call   800436 <printnum>
			break;
  80097e:	eb 3c                	jmp    8009bc <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800980:	8b 45 0c             	mov    0xc(%ebp),%eax
  800983:	89 44 24 04          	mov    %eax,0x4(%esp)
  800987:	89 1c 24             	mov    %ebx,(%esp)
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	ff d0                	call   *%eax
			break;
  80098f:	eb 2b                	jmp    8009bc <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800991:	8b 45 0c             	mov    0xc(%ebp),%eax
  800994:	89 44 24 04          	mov    %eax,0x4(%esp)
  800998:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009a8:	eb 04                	jmp    8009ae <vprintfmt+0x404>
  8009aa:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b1:	83 e8 01             	sub    $0x1,%eax
  8009b4:	0f b6 00             	movzbl (%eax),%eax
  8009b7:	3c 25                	cmp    $0x25,%al
  8009b9:	75 ef                	jne    8009aa <vprintfmt+0x400>
				/* do nothing */;
			break;
  8009bb:	90                   	nop
		}
	}
  8009bc:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009bd:	e9 0a fc ff ff       	jmp    8005cc <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8009c2:	83 c4 40             	add    $0x40,%esp
  8009c5:	5b                   	pop    %ebx
  8009c6:	5e                   	pop    %esi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8009cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8009d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	89 04 24             	mov    %eax,(%esp)
  8009f0:	e8 b5 fb ff ff       	call   8005aa <vprintfmt>
	va_end(ap);
}
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8009fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fd:	8b 40 08             	mov    0x8(%eax),%eax
  800a00:	8d 50 01             	lea    0x1(%eax),%edx
  800a03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a06:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0c:	8b 10                	mov    (%eax),%edx
  800a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a11:	8b 40 04             	mov    0x4(%eax),%eax
  800a14:	39 c2                	cmp    %eax,%edx
  800a16:	73 12                	jae    800a2a <sprintputch+0x33>
		*b->buf++ = ch;
  800a18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1b:	8b 00                	mov    (%eax),%eax
  800a1d:	8d 48 01             	lea    0x1(%eax),%ecx
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a23:	89 0a                	mov    %ecx,(%edx)
  800a25:	8b 55 08             	mov    0x8(%ebp),%edx
  800a28:	88 10                	mov    %dl,(%eax)
}
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3b:	8d 50 ff             	lea    -0x1(%eax),%edx
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	01 d0                	add    %edx,%eax
  800a43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a4d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800a51:	74 06                	je     800a59 <vsnprintf+0x2d>
  800a53:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a57:	7f 07                	jg     800a60 <vsnprintf+0x34>
		return -E_INVAL;
  800a59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a5e:	eb 2a                	jmp    800a8a <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a60:	8b 45 14             	mov    0x14(%ebp),%eax
  800a63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a67:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a75:	c7 04 24 f7 09 80 00 	movl   $0x8009f7,(%esp)
  800a7c:	e8 29 fb ff ff       	call   8005aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a81:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a84:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a8a:	c9                   	leave  
  800a8b:	c3                   	ret    

00800a8c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a92:	8d 45 14             	lea    0x14(%ebp),%eax
  800a95:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a9f:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	89 04 24             	mov    %eax,(%esp)
  800ab3:	e8 74 ff ff ff       	call   800a2c <vsnprintf>
  800ab8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800abe:	c9                   	leave  
  800abf:	c3                   	ret    

00800ac0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800acd:	eb 08                	jmp    800ad7 <strlen+0x17>
		n++;
  800acf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ada:	0f b6 00             	movzbl (%eax),%eax
  800add:	84 c0                	test   %al,%al
  800adf:	75 ee                	jne    800acf <strlen+0xf>
		n++;
	return n;
  800ae1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800ae4:	c9                   	leave  
  800ae5:	c3                   	ret    

00800ae6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800af3:	eb 0c                	jmp    800b01 <strnlen+0x1b>
		n++;
  800af5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800afd:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800b01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b05:	74 0a                	je     800b11 <strnlen+0x2b>
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	0f b6 00             	movzbl (%eax),%eax
  800b0d:	84 c0                	test   %al,%al
  800b0f:	75 e4                	jne    800af5 <strnlen+0xf>
		n++;
	return n;
  800b11:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800b14:	c9                   	leave  
  800b15:	c3                   	ret    

00800b16 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800b22:	90                   	nop
  800b23:	8b 45 08             	mov    0x8(%ebp),%eax
  800b26:	8d 50 01             	lea    0x1(%eax),%edx
  800b29:	89 55 08             	mov    %edx,0x8(%ebp)
  800b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800b32:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800b35:	0f b6 12             	movzbl (%edx),%edx
  800b38:	88 10                	mov    %dl,(%eax)
  800b3a:	0f b6 00             	movzbl (%eax),%eax
  800b3d:	84 c0                	test   %al,%al
  800b3f:	75 e2                	jne    800b23 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800b41:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800b44:	c9                   	leave  
  800b45:	c3                   	ret    

00800b46 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4f:	89 04 24             	mov    %eax,(%esp)
  800b52:	e8 69 ff ff ff       	call   800ac0 <strlen>
  800b57:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800b5a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b60:	01 c2                	add    %eax,%edx
  800b62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b69:	89 14 24             	mov    %edx,(%esp)
  800b6c:	e8 a5 ff ff ff       	call   800b16 <strcpy>
	return dst;
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b74:	c9                   	leave  
  800b75:	c3                   	ret    

00800b76 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800b82:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800b89:	eb 23                	jmp    800bae <strncpy+0x38>
		*dst++ = *src;
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	8d 50 01             	lea    0x1(%eax),%edx
  800b91:	89 55 08             	mov    %edx,0x8(%ebp)
  800b94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b97:	0f b6 12             	movzbl (%edx),%edx
  800b9a:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800b9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9f:	0f b6 00             	movzbl (%eax),%eax
  800ba2:	84 c0                	test   %al,%al
  800ba4:	74 04                	je     800baa <strncpy+0x34>
			src++;
  800ba6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800baa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800bae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bb1:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bb4:	72 d5                	jb     800b8b <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800bb6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800bb9:	c9                   	leave  
  800bba:	c3                   	ret    

00800bbb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800bc7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bcb:	74 33                	je     800c00 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800bcd:	eb 17                	jmp    800be6 <strlcpy+0x2b>
			*dst++ = *src++;
  800bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd2:	8d 50 01             	lea    0x1(%eax),%edx
  800bd5:	89 55 08             	mov    %edx,0x8(%ebp)
  800bd8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bdb:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bde:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800be1:	0f b6 12             	movzbl (%edx),%edx
  800be4:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800be6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800bea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bee:	74 0a                	je     800bfa <strlcpy+0x3f>
  800bf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf3:	0f b6 00             	movzbl (%eax),%eax
  800bf6:	84 c0                	test   %al,%al
  800bf8:	75 d5                	jne    800bcf <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c00:	8b 55 08             	mov    0x8(%ebp),%edx
  800c03:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c06:	29 c2                	sub    %eax,%edx
  800c08:	89 d0                	mov    %edx,%eax
}
  800c0a:	c9                   	leave  
  800c0b:	c3                   	ret    

00800c0c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800c0f:	eb 08                	jmp    800c19 <strcmp+0xd>
		p++, q++;
  800c11:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c15:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	0f b6 00             	movzbl (%eax),%eax
  800c1f:	84 c0                	test   %al,%al
  800c21:	74 10                	je     800c33 <strcmp+0x27>
  800c23:	8b 45 08             	mov    0x8(%ebp),%eax
  800c26:	0f b6 10             	movzbl (%eax),%edx
  800c29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2c:	0f b6 00             	movzbl (%eax),%eax
  800c2f:	38 c2                	cmp    %al,%dl
  800c31:	74 de                	je     800c11 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c33:	8b 45 08             	mov    0x8(%ebp),%eax
  800c36:	0f b6 00             	movzbl (%eax),%eax
  800c39:	0f b6 d0             	movzbl %al,%edx
  800c3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3f:	0f b6 00             	movzbl (%eax),%eax
  800c42:	0f b6 c0             	movzbl %al,%eax
  800c45:	29 c2                	sub    %eax,%edx
  800c47:	89 d0                	mov    %edx,%eax
}
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800c4e:	eb 0c                	jmp    800c5c <strncmp+0x11>
		n--, p++, q++;
  800c50:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800c54:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c58:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c5c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c60:	74 1a                	je     800c7c <strncmp+0x31>
  800c62:	8b 45 08             	mov    0x8(%ebp),%eax
  800c65:	0f b6 00             	movzbl (%eax),%eax
  800c68:	84 c0                	test   %al,%al
  800c6a:	74 10                	je     800c7c <strncmp+0x31>
  800c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6f:	0f b6 10             	movzbl (%eax),%edx
  800c72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c75:	0f b6 00             	movzbl (%eax),%eax
  800c78:	38 c2                	cmp    %al,%dl
  800c7a:	74 d4                	je     800c50 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800c7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c80:	75 07                	jne    800c89 <strncmp+0x3e>
		return 0;
  800c82:	b8 00 00 00 00       	mov    $0x0,%eax
  800c87:	eb 16                	jmp    800c9f <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c89:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8c:	0f b6 00             	movzbl (%eax),%eax
  800c8f:	0f b6 d0             	movzbl %al,%edx
  800c92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c95:	0f b6 00             	movzbl (%eax),%eax
  800c98:	0f b6 c0             	movzbl %al,%eax
  800c9b:	29 c2                	sub    %eax,%edx
  800c9d:	89 d0                	mov    %edx,%eax
}
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	83 ec 04             	sub    $0x4,%esp
  800ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800caa:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800cad:	eb 14                	jmp    800cc3 <strchr+0x22>
		if (*s == c)
  800caf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb2:	0f b6 00             	movzbl (%eax),%eax
  800cb5:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800cb8:	75 05                	jne    800cbf <strchr+0x1e>
			return (char *) s;
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbd:	eb 13                	jmp    800cd2 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cbf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc6:	0f b6 00             	movzbl (%eax),%eax
  800cc9:	84 c0                	test   %al,%al
  800ccb:	75 e2                	jne    800caf <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800ccd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd2:	c9                   	leave  
  800cd3:	c3                   	ret    

00800cd4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	83 ec 04             	sub    $0x4,%esp
  800cda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdd:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ce0:	eb 11                	jmp    800cf3 <strfind+0x1f>
		if (*s == c)
  800ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce5:	0f b6 00             	movzbl (%eax),%eax
  800ce8:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ceb:	75 02                	jne    800cef <strfind+0x1b>
			break;
  800ced:	eb 0e                	jmp    800cfd <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf6:	0f b6 00             	movzbl (%eax),%eax
  800cf9:	84 c0                	test   %al,%al
  800cfb:	75 e5                	jne    800ce2 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800cfd:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d00:	c9                   	leave  
  800d01:	c3                   	ret    

00800d02 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
	char *p;

	if (n == 0)
  800d06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d0a:	75 05                	jne    800d11 <memset+0xf>
		return v;
  800d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0f:	eb 5c                	jmp    800d6d <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800d11:	8b 45 08             	mov    0x8(%ebp),%eax
  800d14:	83 e0 03             	and    $0x3,%eax
  800d17:	85 c0                	test   %eax,%eax
  800d19:	75 41                	jne    800d5c <memset+0x5a>
  800d1b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1e:	83 e0 03             	and    $0x3,%eax
  800d21:	85 c0                	test   %eax,%eax
  800d23:	75 37                	jne    800d5c <memset+0x5a>
		c &= 0xFF;
  800d25:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2f:	c1 e0 18             	shl    $0x18,%eax
  800d32:	89 c2                	mov    %eax,%edx
  800d34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d37:	c1 e0 10             	shl    $0x10,%eax
  800d3a:	09 c2                	or     %eax,%edx
  800d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3f:	c1 e0 08             	shl    $0x8,%eax
  800d42:	09 d0                	or     %edx,%eax
  800d44:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d47:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4a:	c1 e8 02             	shr    $0x2,%eax
  800d4d:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d55:	89 d7                	mov    %edx,%edi
  800d57:	fc                   	cld    
  800d58:	f3 ab                	rep stos %eax,%es:(%edi)
  800d5a:	eb 0e                	jmp    800d6a <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d62:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d65:	89 d7                	mov    %edx,%edi
  800d67:	fc                   	cld    
  800d68:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800d6a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
  800d76:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800d79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800d85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d88:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800d8b:	73 6d                	jae    800dfa <memmove+0x8a>
  800d8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d90:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d93:	01 d0                	add    %edx,%eax
  800d95:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800d98:	76 60                	jbe    800dfa <memmove+0x8a>
		s += n;
  800d9a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d9d:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800da0:	8b 45 10             	mov    0x10(%ebp),%eax
  800da3:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800da6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800da9:	83 e0 03             	and    $0x3,%eax
  800dac:	85 c0                	test   %eax,%eax
  800dae:	75 2f                	jne    800ddf <memmove+0x6f>
  800db0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800db3:	83 e0 03             	and    $0x3,%eax
  800db6:	85 c0                	test   %eax,%eax
  800db8:	75 25                	jne    800ddf <memmove+0x6f>
  800dba:	8b 45 10             	mov    0x10(%ebp),%eax
  800dbd:	83 e0 03             	and    $0x3,%eax
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	75 1b                	jne    800ddf <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dc7:	83 e8 04             	sub    $0x4,%eax
  800dca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dcd:	83 ea 04             	sub    $0x4,%edx
  800dd0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800dd3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800dd6:	89 c7                	mov    %eax,%edi
  800dd8:	89 d6                	mov    %edx,%esi
  800dda:	fd                   	std    
  800ddb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ddd:	eb 18                	jmp    800df7 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ddf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800de2:	8d 50 ff             	lea    -0x1(%eax),%edx
  800de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de8:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800deb:	8b 45 10             	mov    0x10(%ebp),%eax
  800dee:	89 d7                	mov    %edx,%edi
  800df0:	89 de                	mov    %ebx,%esi
  800df2:	89 c1                	mov    %eax,%ecx
  800df4:	fd                   	std    
  800df5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800df7:	fc                   	cld    
  800df8:	eb 45                	jmp    800e3f <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dfd:	83 e0 03             	and    $0x3,%eax
  800e00:	85 c0                	test   %eax,%eax
  800e02:	75 2b                	jne    800e2f <memmove+0xbf>
  800e04:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e07:	83 e0 03             	and    $0x3,%eax
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	75 21                	jne    800e2f <memmove+0xbf>
  800e0e:	8b 45 10             	mov    0x10(%ebp),%eax
  800e11:	83 e0 03             	and    $0x3,%eax
  800e14:	85 c0                	test   %eax,%eax
  800e16:	75 17                	jne    800e2f <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e18:	8b 45 10             	mov    0x10(%ebp),%eax
  800e1b:	c1 e8 02             	shr    $0x2,%eax
  800e1e:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e23:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e26:	89 c7                	mov    %eax,%edi
  800e28:	89 d6                	mov    %edx,%esi
  800e2a:	fc                   	cld    
  800e2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e2d:	eb 10                	jmp    800e3f <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e32:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e35:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e38:	89 c7                	mov    %eax,%edi
  800e3a:	89 d6                	mov    %edx,%esi
  800e3c:	fc                   	cld    
  800e3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800e3f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e42:	83 c4 10             	add    $0x10,%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e50:	8b 45 10             	mov    0x10(%ebp),%eax
  800e53:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e61:	89 04 24             	mov    %eax,(%esp)
  800e64:	e8 07 ff ff ff       	call   800d70 <memmove>
}
  800e69:	c9                   	leave  
  800e6a:	c3                   	ret    

00800e6b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800e71:	8b 45 08             	mov    0x8(%ebp),%eax
  800e74:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800e77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800e7d:	eb 30                	jmp    800eaf <memcmp+0x44>
		if (*s1 != *s2)
  800e7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e82:	0f b6 10             	movzbl (%eax),%edx
  800e85:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e88:	0f b6 00             	movzbl (%eax),%eax
  800e8b:	38 c2                	cmp    %al,%dl
  800e8d:	74 18                	je     800ea7 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800e8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e92:	0f b6 00             	movzbl (%eax),%eax
  800e95:	0f b6 d0             	movzbl %al,%edx
  800e98:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e9b:	0f b6 00             	movzbl (%eax),%eax
  800e9e:	0f b6 c0             	movzbl %al,%eax
  800ea1:	29 c2                	sub    %eax,%edx
  800ea3:	89 d0                	mov    %edx,%eax
  800ea5:	eb 1a                	jmp    800ec1 <memcmp+0x56>
		s1++, s2++;
  800ea7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800eab:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eaf:	8b 45 10             	mov    0x10(%ebp),%eax
  800eb2:	8d 50 ff             	lea    -0x1(%eax),%edx
  800eb5:	89 55 10             	mov    %edx,0x10(%ebp)
  800eb8:	85 c0                	test   %eax,%eax
  800eba:	75 c3                	jne    800e7f <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ebc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ec1:	c9                   	leave  
  800ec2:	c3                   	ret    

00800ec3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800ec9:	8b 45 10             	mov    0x10(%ebp),%eax
  800ecc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecf:	01 d0                	add    %edx,%eax
  800ed1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800ed4:	eb 13                	jmp    800ee9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed9:	0f b6 10             	movzbl (%eax),%edx
  800edc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edf:	38 c2                	cmp    %al,%dl
  800ee1:	75 02                	jne    800ee5 <memfind+0x22>
			break;
  800ee3:	eb 0c                	jmp    800ef1 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ee5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ee9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eec:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800eef:	72 e5                	jb     800ed6 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800ef1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    

00800ef6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800efc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800f03:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f0a:	eb 04                	jmp    800f10 <strtol+0x1a>
		s++;
  800f0c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f10:	8b 45 08             	mov    0x8(%ebp),%eax
  800f13:	0f b6 00             	movzbl (%eax),%eax
  800f16:	3c 20                	cmp    $0x20,%al
  800f18:	74 f2                	je     800f0c <strtol+0x16>
  800f1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1d:	0f b6 00             	movzbl (%eax),%eax
  800f20:	3c 09                	cmp    $0x9,%al
  800f22:	74 e8                	je     800f0c <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f24:	8b 45 08             	mov    0x8(%ebp),%eax
  800f27:	0f b6 00             	movzbl (%eax),%eax
  800f2a:	3c 2b                	cmp    $0x2b,%al
  800f2c:	75 06                	jne    800f34 <strtol+0x3e>
		s++;
  800f2e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800f32:	eb 15                	jmp    800f49 <strtol+0x53>
	else if (*s == '-')
  800f34:	8b 45 08             	mov    0x8(%ebp),%eax
  800f37:	0f b6 00             	movzbl (%eax),%eax
  800f3a:	3c 2d                	cmp    $0x2d,%al
  800f3c:	75 0b                	jne    800f49 <strtol+0x53>
		s++, neg = 1;
  800f3e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800f42:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f4d:	74 06                	je     800f55 <strtol+0x5f>
  800f4f:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800f53:	75 24                	jne    800f79 <strtol+0x83>
  800f55:	8b 45 08             	mov    0x8(%ebp),%eax
  800f58:	0f b6 00             	movzbl (%eax),%eax
  800f5b:	3c 30                	cmp    $0x30,%al
  800f5d:	75 1a                	jne    800f79 <strtol+0x83>
  800f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f62:	83 c0 01             	add    $0x1,%eax
  800f65:	0f b6 00             	movzbl (%eax),%eax
  800f68:	3c 78                	cmp    $0x78,%al
  800f6a:	75 0d                	jne    800f79 <strtol+0x83>
		s += 2, base = 16;
  800f6c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800f70:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800f77:	eb 2a                	jmp    800fa3 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800f79:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f7d:	75 17                	jne    800f96 <strtol+0xa0>
  800f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f82:	0f b6 00             	movzbl (%eax),%eax
  800f85:	3c 30                	cmp    $0x30,%al
  800f87:	75 0d                	jne    800f96 <strtol+0xa0>
		s++, base = 8;
  800f89:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800f8d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800f94:	eb 0d                	jmp    800fa3 <strtol+0xad>
	else if (base == 0)
  800f96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f9a:	75 07                	jne    800fa3 <strtol+0xad>
		base = 10;
  800f9c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa6:	0f b6 00             	movzbl (%eax),%eax
  800fa9:	3c 2f                	cmp    $0x2f,%al
  800fab:	7e 1b                	jle    800fc8 <strtol+0xd2>
  800fad:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb0:	0f b6 00             	movzbl (%eax),%eax
  800fb3:	3c 39                	cmp    $0x39,%al
  800fb5:	7f 11                	jg     800fc8 <strtol+0xd2>
			dig = *s - '0';
  800fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fba:	0f b6 00             	movzbl (%eax),%eax
  800fbd:	0f be c0             	movsbl %al,%eax
  800fc0:	83 e8 30             	sub    $0x30,%eax
  800fc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800fc6:	eb 48                	jmp    801010 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800fc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcb:	0f b6 00             	movzbl (%eax),%eax
  800fce:	3c 60                	cmp    $0x60,%al
  800fd0:	7e 1b                	jle    800fed <strtol+0xf7>
  800fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd5:	0f b6 00             	movzbl (%eax),%eax
  800fd8:	3c 7a                	cmp    $0x7a,%al
  800fda:	7f 11                	jg     800fed <strtol+0xf7>
			dig = *s - 'a' + 10;
  800fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdf:	0f b6 00             	movzbl (%eax),%eax
  800fe2:	0f be c0             	movsbl %al,%eax
  800fe5:	83 e8 57             	sub    $0x57,%eax
  800fe8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800feb:	eb 23                	jmp    801010 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800fed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff0:	0f b6 00             	movzbl (%eax),%eax
  800ff3:	3c 40                	cmp    $0x40,%al
  800ff5:	7e 3d                	jle    801034 <strtol+0x13e>
  800ff7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffa:	0f b6 00             	movzbl (%eax),%eax
  800ffd:	3c 5a                	cmp    $0x5a,%al
  800fff:	7f 33                	jg     801034 <strtol+0x13e>
			dig = *s - 'A' + 10;
  801001:	8b 45 08             	mov    0x8(%ebp),%eax
  801004:	0f b6 00             	movzbl (%eax),%eax
  801007:	0f be c0             	movsbl %al,%eax
  80100a:	83 e8 37             	sub    $0x37,%eax
  80100d:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801013:	3b 45 10             	cmp    0x10(%ebp),%eax
  801016:	7c 02                	jl     80101a <strtol+0x124>
			break;
  801018:	eb 1a                	jmp    801034 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80101a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80101e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801021:	0f af 45 10          	imul   0x10(%ebp),%eax
  801025:	89 c2                	mov    %eax,%edx
  801027:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102a:	01 d0                	add    %edx,%eax
  80102c:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  80102f:	e9 6f ff ff ff       	jmp    800fa3 <strtol+0xad>

	if (endptr)
  801034:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801038:	74 08                	je     801042 <strtol+0x14c>
		*endptr = (char *) s;
  80103a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103d:	8b 55 08             	mov    0x8(%ebp),%edx
  801040:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801042:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801046:	74 07                	je     80104f <strtol+0x159>
  801048:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80104b:	f7 d8                	neg    %eax
  80104d:	eb 03                	jmp    801052 <strtol+0x15c>
  80104f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801052:	c9                   	leave  
  801053:	c3                   	ret    

00801054 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	57                   	push   %edi
  801058:	56                   	push   %esi
  801059:	53                   	push   %ebx
  80105a:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105d:	8b 45 08             	mov    0x8(%ebp),%eax
  801060:	8b 55 10             	mov    0x10(%ebp),%edx
  801063:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801066:	8b 5d 18             	mov    0x18(%ebp),%ebx
  801069:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  80106c:	8b 75 20             	mov    0x20(%ebp),%esi
  80106f:	cd 30                	int    $0x30
  801071:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801074:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801078:	74 30                	je     8010aa <syscall+0x56>
  80107a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80107e:	7e 2a                	jle    8010aa <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  801080:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801083:	89 44 24 10          	mov    %eax,0x10(%esp)
  801087:	8b 45 08             	mov    0x8(%ebp),%eax
  80108a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80108e:	c7 44 24 08 84 19 80 	movl   $0x801984,0x8(%esp)
  801095:	00 
  801096:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80109d:	00 
  80109e:	c7 04 24 a1 19 80 00 	movl   $0x8019a1,(%esp)
  8010a5:	e8 4b f2 ff ff       	call   8002f5 <_panic>

	return ret;
  8010aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8010ad:	83 c4 3c             	add    $0x3c,%esp
  8010b0:	5b                   	pop    %ebx
  8010b1:	5e                   	pop    %esi
  8010b2:	5f                   	pop    %edi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010be:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010c5:	00 
  8010c6:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010cd:	00 
  8010ce:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010d5:	00 
  8010d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010e8:	00 
  8010e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f0:	e8 5f ff ff ff       	call   801054 <syscall>
}
  8010f5:	c9                   	leave  
  8010f6:	c3                   	ret    

008010f7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8010fd:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801104:	00 
  801105:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80110c:	00 
  80110d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801114:	00 
  801115:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80111c:	00 
  80111d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801124:	00 
  801125:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80112c:	00 
  80112d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801134:	e8 1b ff ff ff       	call   801054 <syscall>
}
  801139:	c9                   	leave  
  80113a:	c3                   	ret    

0080113b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801141:	8b 45 08             	mov    0x8(%ebp),%eax
  801144:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80114b:	00 
  80114c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801153:	00 
  801154:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80115b:	00 
  80115c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801163:	00 
  801164:	89 44 24 08          	mov    %eax,0x8(%esp)
  801168:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80116f:	00 
  801170:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801177:	e8 d8 fe ff ff       	call   801054 <syscall>
}
  80117c:	c9                   	leave  
  80117d:	c3                   	ret    

0080117e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801184:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80118b:	00 
  80118c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801193:	00 
  801194:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80119b:	00 
  80119c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011a3:	00 
  8011a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011ab:	00 
  8011ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011b3:	00 
  8011b4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8011bb:	e8 94 fe ff ff       	call   801054 <syscall>
}
  8011c0:	c9                   	leave  
  8011c1:	c3                   	ret    

008011c2 <sys_yield>:

void
sys_yield(void)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8011c8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011cf:	00 
  8011d0:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011d7:	00 
  8011d8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011df:	00 
  8011e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011e7:	00 
  8011e8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011ef:	00 
  8011f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011f7:	00 
  8011f8:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8011ff:	e8 50 fe ff ff       	call   801054 <syscall>
}
  801204:	c9                   	leave  
  801205:	c3                   	ret    

00801206 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80120c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80120f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801212:	8b 45 08             	mov    0x8(%ebp),%eax
  801215:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80121c:	00 
  80121d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801224:	00 
  801225:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801229:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80122d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801231:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801238:	00 
  801239:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  801240:	e8 0f fe ff ff       	call   801054 <syscall>
}
  801245:	c9                   	leave  
  801246:	c3                   	ret    

00801247 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	56                   	push   %esi
  80124b:	53                   	push   %ebx
  80124c:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80124f:	8b 75 18             	mov    0x18(%ebp),%esi
  801252:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801255:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801258:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125b:	8b 45 08             	mov    0x8(%ebp),%eax
  80125e:	89 74 24 18          	mov    %esi,0x18(%esp)
  801262:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  801266:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80126a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80126e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801272:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801279:	00 
  80127a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801281:	e8 ce fd ff ff       	call   801054 <syscall>
}
  801286:	83 c4 20             	add    $0x20,%esp
  801289:	5b                   	pop    %ebx
  80128a:	5e                   	pop    %esi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801293:	8b 55 0c             	mov    0xc(%ebp),%edx
  801296:	8b 45 08             	mov    0x8(%ebp),%eax
  801299:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8012a0:	00 
  8012a1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8012a8:	00 
  8012a9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8012b0:	00 
  8012b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012b9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8012c0:	00 
  8012c1:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  8012c8:	e8 87 fd ff ff       	call   801054 <syscall>
}
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    

008012cf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8012d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012db:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8012e2:	00 
  8012e3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8012ea:	00 
  8012eb:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8012f2:	00 
  8012f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012fb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801302:	00 
  801303:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80130a:	e8 45 fd ff ff       	call   801054 <syscall>
}
  80130f:	c9                   	leave  
  801310:	c3                   	ret    

00801311 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801317:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131a:	8b 45 08             	mov    0x8(%ebp),%eax
  80131d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801324:	00 
  801325:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80132c:	00 
  80132d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801334:	00 
  801335:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801339:	89 44 24 08          	mov    %eax,0x8(%esp)
  80133d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801344:	00 
  801345:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80134c:	e8 03 fd ff ff       	call   801054 <syscall>
}
  801351:	c9                   	leave  
  801352:	c3                   	ret    

00801353 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801359:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80135c:	8b 55 10             	mov    0x10(%ebp),%edx
  80135f:	8b 45 08             	mov    0x8(%ebp),%eax
  801362:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801369:	00 
  80136a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80136e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801372:	8b 55 0c             	mov    0xc(%ebp),%edx
  801375:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801379:	89 44 24 08          	mov    %eax,0x8(%esp)
  80137d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801384:	00 
  801385:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  80138c:	e8 c3 fc ff ff       	call   801054 <syscall>
}
  801391:	c9                   	leave  
  801392:	c3                   	ret    

00801393 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801393:	55                   	push   %ebp
  801394:	89 e5                	mov    %esp,%ebp
  801396:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801399:	8b 45 08             	mov    0x8(%ebp),%eax
  80139c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8013a3:	00 
  8013a4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8013ab:	00 
  8013ac:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8013b3:	00 
  8013b4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013bb:	00 
  8013bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013c0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013c7:	00 
  8013c8:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8013cf:	e8 80 fc ff ff       	call   801054 <syscall>
}
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    
  8013d6:	66 90                	xchg   %ax,%ax
  8013d8:	66 90                	xchg   %ax,%ax
  8013da:	66 90                	xchg   %ax,%ax
  8013dc:	66 90                	xchg   %ax,%ax
  8013de:	66 90                	xchg   %ax,%ax

008013e0 <__udivdi3>:
  8013e0:	55                   	push   %ebp
  8013e1:	57                   	push   %edi
  8013e2:	56                   	push   %esi
  8013e3:	83 ec 0c             	sub    $0xc,%esp
  8013e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8013ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8013f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013fc:	89 ea                	mov    %ebp,%edx
  8013fe:	89 0c 24             	mov    %ecx,(%esp)
  801401:	75 2d                	jne    801430 <__udivdi3+0x50>
  801403:	39 e9                	cmp    %ebp,%ecx
  801405:	77 61                	ja     801468 <__udivdi3+0x88>
  801407:	85 c9                	test   %ecx,%ecx
  801409:	89 ce                	mov    %ecx,%esi
  80140b:	75 0b                	jne    801418 <__udivdi3+0x38>
  80140d:	b8 01 00 00 00       	mov    $0x1,%eax
  801412:	31 d2                	xor    %edx,%edx
  801414:	f7 f1                	div    %ecx
  801416:	89 c6                	mov    %eax,%esi
  801418:	31 d2                	xor    %edx,%edx
  80141a:	89 e8                	mov    %ebp,%eax
  80141c:	f7 f6                	div    %esi
  80141e:	89 c5                	mov    %eax,%ebp
  801420:	89 f8                	mov    %edi,%eax
  801422:	f7 f6                	div    %esi
  801424:	89 ea                	mov    %ebp,%edx
  801426:	83 c4 0c             	add    $0xc,%esp
  801429:	5e                   	pop    %esi
  80142a:	5f                   	pop    %edi
  80142b:	5d                   	pop    %ebp
  80142c:	c3                   	ret    
  80142d:	8d 76 00             	lea    0x0(%esi),%esi
  801430:	39 e8                	cmp    %ebp,%eax
  801432:	77 24                	ja     801458 <__udivdi3+0x78>
  801434:	0f bd e8             	bsr    %eax,%ebp
  801437:	83 f5 1f             	xor    $0x1f,%ebp
  80143a:	75 3c                	jne    801478 <__udivdi3+0x98>
  80143c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801440:	39 34 24             	cmp    %esi,(%esp)
  801443:	0f 86 9f 00 00 00    	jbe    8014e8 <__udivdi3+0x108>
  801449:	39 d0                	cmp    %edx,%eax
  80144b:	0f 82 97 00 00 00    	jb     8014e8 <__udivdi3+0x108>
  801451:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801458:	31 d2                	xor    %edx,%edx
  80145a:	31 c0                	xor    %eax,%eax
  80145c:	83 c4 0c             	add    $0xc,%esp
  80145f:	5e                   	pop    %esi
  801460:	5f                   	pop    %edi
  801461:	5d                   	pop    %ebp
  801462:	c3                   	ret    
  801463:	90                   	nop
  801464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801468:	89 f8                	mov    %edi,%eax
  80146a:	f7 f1                	div    %ecx
  80146c:	31 d2                	xor    %edx,%edx
  80146e:	83 c4 0c             	add    $0xc,%esp
  801471:	5e                   	pop    %esi
  801472:	5f                   	pop    %edi
  801473:	5d                   	pop    %ebp
  801474:	c3                   	ret    
  801475:	8d 76 00             	lea    0x0(%esi),%esi
  801478:	89 e9                	mov    %ebp,%ecx
  80147a:	8b 3c 24             	mov    (%esp),%edi
  80147d:	d3 e0                	shl    %cl,%eax
  80147f:	89 c6                	mov    %eax,%esi
  801481:	b8 20 00 00 00       	mov    $0x20,%eax
  801486:	29 e8                	sub    %ebp,%eax
  801488:	89 c1                	mov    %eax,%ecx
  80148a:	d3 ef                	shr    %cl,%edi
  80148c:	89 e9                	mov    %ebp,%ecx
  80148e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801492:	8b 3c 24             	mov    (%esp),%edi
  801495:	09 74 24 08          	or     %esi,0x8(%esp)
  801499:	89 d6                	mov    %edx,%esi
  80149b:	d3 e7                	shl    %cl,%edi
  80149d:	89 c1                	mov    %eax,%ecx
  80149f:	89 3c 24             	mov    %edi,(%esp)
  8014a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014a6:	d3 ee                	shr    %cl,%esi
  8014a8:	89 e9                	mov    %ebp,%ecx
  8014aa:	d3 e2                	shl    %cl,%edx
  8014ac:	89 c1                	mov    %eax,%ecx
  8014ae:	d3 ef                	shr    %cl,%edi
  8014b0:	09 d7                	or     %edx,%edi
  8014b2:	89 f2                	mov    %esi,%edx
  8014b4:	89 f8                	mov    %edi,%eax
  8014b6:	f7 74 24 08          	divl   0x8(%esp)
  8014ba:	89 d6                	mov    %edx,%esi
  8014bc:	89 c7                	mov    %eax,%edi
  8014be:	f7 24 24             	mull   (%esp)
  8014c1:	39 d6                	cmp    %edx,%esi
  8014c3:	89 14 24             	mov    %edx,(%esp)
  8014c6:	72 30                	jb     8014f8 <__udivdi3+0x118>
  8014c8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014cc:	89 e9                	mov    %ebp,%ecx
  8014ce:	d3 e2                	shl    %cl,%edx
  8014d0:	39 c2                	cmp    %eax,%edx
  8014d2:	73 05                	jae    8014d9 <__udivdi3+0xf9>
  8014d4:	3b 34 24             	cmp    (%esp),%esi
  8014d7:	74 1f                	je     8014f8 <__udivdi3+0x118>
  8014d9:	89 f8                	mov    %edi,%eax
  8014db:	31 d2                	xor    %edx,%edx
  8014dd:	e9 7a ff ff ff       	jmp    80145c <__udivdi3+0x7c>
  8014e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014e8:	31 d2                	xor    %edx,%edx
  8014ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ef:	e9 68 ff ff ff       	jmp    80145c <__udivdi3+0x7c>
  8014f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8014fb:	31 d2                	xor    %edx,%edx
  8014fd:	83 c4 0c             	add    $0xc,%esp
  801500:	5e                   	pop    %esi
  801501:	5f                   	pop    %edi
  801502:	5d                   	pop    %ebp
  801503:	c3                   	ret    
  801504:	66 90                	xchg   %ax,%ax
  801506:	66 90                	xchg   %ax,%ax
  801508:	66 90                	xchg   %ax,%ax
  80150a:	66 90                	xchg   %ax,%ax
  80150c:	66 90                	xchg   %ax,%ax
  80150e:	66 90                	xchg   %ax,%ax

00801510 <__umoddi3>:
  801510:	55                   	push   %ebp
  801511:	57                   	push   %edi
  801512:	56                   	push   %esi
  801513:	83 ec 14             	sub    $0x14,%esp
  801516:	8b 44 24 28          	mov    0x28(%esp),%eax
  80151a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80151e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801522:	89 c7                	mov    %eax,%edi
  801524:	89 44 24 04          	mov    %eax,0x4(%esp)
  801528:	8b 44 24 30          	mov    0x30(%esp),%eax
  80152c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801530:	89 34 24             	mov    %esi,(%esp)
  801533:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801537:	85 c0                	test   %eax,%eax
  801539:	89 c2                	mov    %eax,%edx
  80153b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80153f:	75 17                	jne    801558 <__umoddi3+0x48>
  801541:	39 fe                	cmp    %edi,%esi
  801543:	76 4b                	jbe    801590 <__umoddi3+0x80>
  801545:	89 c8                	mov    %ecx,%eax
  801547:	89 fa                	mov    %edi,%edx
  801549:	f7 f6                	div    %esi
  80154b:	89 d0                	mov    %edx,%eax
  80154d:	31 d2                	xor    %edx,%edx
  80154f:	83 c4 14             	add    $0x14,%esp
  801552:	5e                   	pop    %esi
  801553:	5f                   	pop    %edi
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    
  801556:	66 90                	xchg   %ax,%ax
  801558:	39 f8                	cmp    %edi,%eax
  80155a:	77 54                	ja     8015b0 <__umoddi3+0xa0>
  80155c:	0f bd e8             	bsr    %eax,%ebp
  80155f:	83 f5 1f             	xor    $0x1f,%ebp
  801562:	75 5c                	jne    8015c0 <__umoddi3+0xb0>
  801564:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801568:	39 3c 24             	cmp    %edi,(%esp)
  80156b:	0f 87 e7 00 00 00    	ja     801658 <__umoddi3+0x148>
  801571:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801575:	29 f1                	sub    %esi,%ecx
  801577:	19 c7                	sbb    %eax,%edi
  801579:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80157d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801581:	8b 44 24 08          	mov    0x8(%esp),%eax
  801585:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801589:	83 c4 14             	add    $0x14,%esp
  80158c:	5e                   	pop    %esi
  80158d:	5f                   	pop    %edi
  80158e:	5d                   	pop    %ebp
  80158f:	c3                   	ret    
  801590:	85 f6                	test   %esi,%esi
  801592:	89 f5                	mov    %esi,%ebp
  801594:	75 0b                	jne    8015a1 <__umoddi3+0x91>
  801596:	b8 01 00 00 00       	mov    $0x1,%eax
  80159b:	31 d2                	xor    %edx,%edx
  80159d:	f7 f6                	div    %esi
  80159f:	89 c5                	mov    %eax,%ebp
  8015a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8015a5:	31 d2                	xor    %edx,%edx
  8015a7:	f7 f5                	div    %ebp
  8015a9:	89 c8                	mov    %ecx,%eax
  8015ab:	f7 f5                	div    %ebp
  8015ad:	eb 9c                	jmp    80154b <__umoddi3+0x3b>
  8015af:	90                   	nop
  8015b0:	89 c8                	mov    %ecx,%eax
  8015b2:	89 fa                	mov    %edi,%edx
  8015b4:	83 c4 14             	add    $0x14,%esp
  8015b7:	5e                   	pop    %esi
  8015b8:	5f                   	pop    %edi
  8015b9:	5d                   	pop    %ebp
  8015ba:	c3                   	ret    
  8015bb:	90                   	nop
  8015bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015c0:	8b 04 24             	mov    (%esp),%eax
  8015c3:	be 20 00 00 00       	mov    $0x20,%esi
  8015c8:	89 e9                	mov    %ebp,%ecx
  8015ca:	29 ee                	sub    %ebp,%esi
  8015cc:	d3 e2                	shl    %cl,%edx
  8015ce:	89 f1                	mov    %esi,%ecx
  8015d0:	d3 e8                	shr    %cl,%eax
  8015d2:	89 e9                	mov    %ebp,%ecx
  8015d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d8:	8b 04 24             	mov    (%esp),%eax
  8015db:	09 54 24 04          	or     %edx,0x4(%esp)
  8015df:	89 fa                	mov    %edi,%edx
  8015e1:	d3 e0                	shl    %cl,%eax
  8015e3:	89 f1                	mov    %esi,%ecx
  8015e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8015ed:	d3 ea                	shr    %cl,%edx
  8015ef:	89 e9                	mov    %ebp,%ecx
  8015f1:	d3 e7                	shl    %cl,%edi
  8015f3:	89 f1                	mov    %esi,%ecx
  8015f5:	d3 e8                	shr    %cl,%eax
  8015f7:	89 e9                	mov    %ebp,%ecx
  8015f9:	09 f8                	or     %edi,%eax
  8015fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8015ff:	f7 74 24 04          	divl   0x4(%esp)
  801603:	d3 e7                	shl    %cl,%edi
  801605:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801609:	89 d7                	mov    %edx,%edi
  80160b:	f7 64 24 08          	mull   0x8(%esp)
  80160f:	39 d7                	cmp    %edx,%edi
  801611:	89 c1                	mov    %eax,%ecx
  801613:	89 14 24             	mov    %edx,(%esp)
  801616:	72 2c                	jb     801644 <__umoddi3+0x134>
  801618:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80161c:	72 22                	jb     801640 <__umoddi3+0x130>
  80161e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801622:	29 c8                	sub    %ecx,%eax
  801624:	19 d7                	sbb    %edx,%edi
  801626:	89 e9                	mov    %ebp,%ecx
  801628:	89 fa                	mov    %edi,%edx
  80162a:	d3 e8                	shr    %cl,%eax
  80162c:	89 f1                	mov    %esi,%ecx
  80162e:	d3 e2                	shl    %cl,%edx
  801630:	89 e9                	mov    %ebp,%ecx
  801632:	d3 ef                	shr    %cl,%edi
  801634:	09 d0                	or     %edx,%eax
  801636:	89 fa                	mov    %edi,%edx
  801638:	83 c4 14             	add    $0x14,%esp
  80163b:	5e                   	pop    %esi
  80163c:	5f                   	pop    %edi
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    
  80163f:	90                   	nop
  801640:	39 d7                	cmp    %edx,%edi
  801642:	75 da                	jne    80161e <__umoddi3+0x10e>
  801644:	8b 14 24             	mov    (%esp),%edx
  801647:	89 c1                	mov    %eax,%ecx
  801649:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80164d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801651:	eb cb                	jmp    80161e <__umoddi3+0x10e>
  801653:	90                   	nop
  801654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801658:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80165c:	0f 82 0f ff ff ff    	jb     801571 <__umoddi3+0x61>
  801662:	e9 1a ff ff ff       	jmp    801581 <__umoddi3+0x71>
