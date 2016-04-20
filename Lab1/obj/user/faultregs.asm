
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 1b 06 00 00       	call   80064c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	int mismatch = 0;
  800039:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	8b 45 14             	mov    0x14(%ebp),%eax
  800043:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800047:	8b 45 0c             	mov    0xc(%ebp),%eax
  80004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80004e:	c7 44 24 04 c0 1a 80 	movl   $0x801ac0,0x4(%esp)
  800055:	00 
  800056:	c7 04 24 c1 1a 80 00 	movl   $0x801ac1,(%esp)
  80005d:	e8 67 07 00 00       	call   8007c9 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800062:	8b 45 10             	mov    0x10(%ebp),%eax
  800065:	8b 10                	mov    (%eax),%edx
  800067:	8b 45 08             	mov    0x8(%ebp),%eax
  80006a:	8b 00                	mov    (%eax),%eax
  80006c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800070:	89 44 24 08          	mov    %eax,0x8(%esp)
  800074:	c7 44 24 04 d1 1a 80 	movl   $0x801ad1,0x4(%esp)
  80007b:	00 
  80007c:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  800083:	e8 41 07 00 00       	call   8007c9 <cprintf>
  800088:	8b 45 08             	mov    0x8(%ebp),%eax
  80008b:	8b 10                	mov    (%eax),%edx
  80008d:	8b 45 10             	mov    0x10(%ebp),%eax
  800090:	8b 00                	mov    (%eax),%eax
  800092:	39 c2                	cmp    %eax,%edx
  800094:	75 0e                	jne    8000a4 <check_regs+0x71>
  800096:	c7 04 24 e5 1a 80 00 	movl   $0x801ae5,(%esp)
  80009d:	e8 27 07 00 00       	call   8007c9 <cprintf>
  8000a2:	eb 13                	jmp    8000b7 <check_regs+0x84>
  8000a4:	c7 04 24 e9 1a 80 00 	movl   $0x801ae9,(%esp)
  8000ab:	e8 19 07 00 00       	call   8007c9 <cprintf>
  8000b0:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(esi, regs.reg_esi);
  8000b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8000ba:	8b 50 04             	mov    0x4(%eax),%edx
  8000bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c0:	8b 40 04             	mov    0x4(%eax),%eax
  8000c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8000c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000cb:	c7 44 24 04 f3 1a 80 	movl   $0x801af3,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  8000da:	e8 ea 06 00 00       	call   8007c9 <cprintf>
  8000df:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e2:	8b 50 04             	mov    0x4(%eax),%edx
  8000e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8000e8:	8b 40 04             	mov    0x4(%eax),%eax
  8000eb:	39 c2                	cmp    %eax,%edx
  8000ed:	75 0e                	jne    8000fd <check_regs+0xca>
  8000ef:	c7 04 24 e5 1a 80 00 	movl   $0x801ae5,(%esp)
  8000f6:	e8 ce 06 00 00       	call   8007c9 <cprintf>
  8000fb:	eb 13                	jmp    800110 <check_regs+0xdd>
  8000fd:	c7 04 24 e9 1a 80 00 	movl   $0x801ae9,(%esp)
  800104:	e8 c0 06 00 00       	call   8007c9 <cprintf>
  800109:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(ebp, regs.reg_ebp);
  800110:	8b 45 10             	mov    0x10(%ebp),%eax
  800113:	8b 50 08             	mov    0x8(%eax),%edx
  800116:	8b 45 08             	mov    0x8(%ebp),%eax
  800119:	8b 40 08             	mov    0x8(%eax),%eax
  80011c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800120:	89 44 24 08          	mov    %eax,0x8(%esp)
  800124:	c7 44 24 04 f7 1a 80 	movl   $0x801af7,0x4(%esp)
  80012b:	00 
  80012c:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  800133:	e8 91 06 00 00       	call   8007c9 <cprintf>
  800138:	8b 45 08             	mov    0x8(%ebp),%eax
  80013b:	8b 50 08             	mov    0x8(%eax),%edx
  80013e:	8b 45 10             	mov    0x10(%ebp),%eax
  800141:	8b 40 08             	mov    0x8(%eax),%eax
  800144:	39 c2                	cmp    %eax,%edx
  800146:	75 0e                	jne    800156 <check_regs+0x123>
  800148:	c7 04 24 e5 1a 80 00 	movl   $0x801ae5,(%esp)
  80014f:	e8 75 06 00 00       	call   8007c9 <cprintf>
  800154:	eb 13                	jmp    800169 <check_regs+0x136>
  800156:	c7 04 24 e9 1a 80 00 	movl   $0x801ae9,(%esp)
  80015d:	e8 67 06 00 00       	call   8007c9 <cprintf>
  800162:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(ebx, regs.reg_ebx);
  800169:	8b 45 10             	mov    0x10(%ebp),%eax
  80016c:	8b 50 10             	mov    0x10(%eax),%edx
  80016f:	8b 45 08             	mov    0x8(%ebp),%eax
  800172:	8b 40 10             	mov    0x10(%eax),%eax
  800175:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800179:	89 44 24 08          	mov    %eax,0x8(%esp)
  80017d:	c7 44 24 04 fb 1a 80 	movl   $0x801afb,0x4(%esp)
  800184:	00 
  800185:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  80018c:	e8 38 06 00 00       	call   8007c9 <cprintf>
  800191:	8b 45 08             	mov    0x8(%ebp),%eax
  800194:	8b 50 10             	mov    0x10(%eax),%edx
  800197:	8b 45 10             	mov    0x10(%ebp),%eax
  80019a:	8b 40 10             	mov    0x10(%eax),%eax
  80019d:	39 c2                	cmp    %eax,%edx
  80019f:	75 0e                	jne    8001af <check_regs+0x17c>
  8001a1:	c7 04 24 e5 1a 80 00 	movl   $0x801ae5,(%esp)
  8001a8:	e8 1c 06 00 00       	call   8007c9 <cprintf>
  8001ad:	eb 13                	jmp    8001c2 <check_regs+0x18f>
  8001af:	c7 04 24 e9 1a 80 00 	movl   $0x801ae9,(%esp)
  8001b6:	e8 0e 06 00 00       	call   8007c9 <cprintf>
  8001bb:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(edx, regs.reg_edx);
  8001c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c5:	8b 50 14             	mov    0x14(%eax),%edx
  8001c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cb:	8b 40 14             	mov    0x14(%eax),%eax
  8001ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d6:	c7 44 24 04 ff 1a 80 	movl   $0x801aff,0x4(%esp)
  8001dd:	00 
  8001de:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  8001e5:	e8 df 05 00 00       	call   8007c9 <cprintf>
  8001ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ed:	8b 50 14             	mov    0x14(%eax),%edx
  8001f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f3:	8b 40 14             	mov    0x14(%eax),%eax
  8001f6:	39 c2                	cmp    %eax,%edx
  8001f8:	75 0e                	jne    800208 <check_regs+0x1d5>
  8001fa:	c7 04 24 e5 1a 80 00 	movl   $0x801ae5,(%esp)
  800201:	e8 c3 05 00 00       	call   8007c9 <cprintf>
  800206:	eb 13                	jmp    80021b <check_regs+0x1e8>
  800208:	c7 04 24 e9 1a 80 00 	movl   $0x801ae9,(%esp)
  80020f:	e8 b5 05 00 00       	call   8007c9 <cprintf>
  800214:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(ecx, regs.reg_ecx);
  80021b:	8b 45 10             	mov    0x10(%ebp),%eax
  80021e:	8b 50 18             	mov    0x18(%eax),%edx
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	8b 40 18             	mov    0x18(%eax),%eax
  800227:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80022b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022f:	c7 44 24 04 03 1b 80 	movl   $0x801b03,0x4(%esp)
  800236:	00 
  800237:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  80023e:	e8 86 05 00 00       	call   8007c9 <cprintf>
  800243:	8b 45 08             	mov    0x8(%ebp),%eax
  800246:	8b 50 18             	mov    0x18(%eax),%edx
  800249:	8b 45 10             	mov    0x10(%ebp),%eax
  80024c:	8b 40 18             	mov    0x18(%eax),%eax
  80024f:	39 c2                	cmp    %eax,%edx
  800251:	75 0e                	jne    800261 <check_regs+0x22e>
  800253:	c7 04 24 e5 1a 80 00 	movl   $0x801ae5,(%esp)
  80025a:	e8 6a 05 00 00       	call   8007c9 <cprintf>
  80025f:	eb 13                	jmp    800274 <check_regs+0x241>
  800261:	c7 04 24 e9 1a 80 00 	movl   $0x801ae9,(%esp)
  800268:	e8 5c 05 00 00       	call   8007c9 <cprintf>
  80026d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(eax, regs.reg_eax);
  800274:	8b 45 10             	mov    0x10(%ebp),%eax
  800277:	8b 50 1c             	mov    0x1c(%eax),%edx
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	8b 40 1c             	mov    0x1c(%eax),%eax
  800280:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800284:	89 44 24 08          	mov    %eax,0x8(%esp)
  800288:	c7 44 24 04 07 1b 80 	movl   $0x801b07,0x4(%esp)
  80028f:	00 
  800290:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  800297:	e8 2d 05 00 00       	call   8007c9 <cprintf>
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	8b 50 1c             	mov    0x1c(%eax),%edx
  8002a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a5:	8b 40 1c             	mov    0x1c(%eax),%eax
  8002a8:	39 c2                	cmp    %eax,%edx
  8002aa:	75 0e                	jne    8002ba <check_regs+0x287>
  8002ac:	c7 04 24 e5 1a 80 00 	movl   $0x801ae5,(%esp)
  8002b3:	e8 11 05 00 00       	call   8007c9 <cprintf>
  8002b8:	eb 13                	jmp    8002cd <check_regs+0x29a>
  8002ba:	c7 04 24 e9 1a 80 00 	movl   $0x801ae9,(%esp)
  8002c1:	e8 03 05 00 00       	call   8007c9 <cprintf>
  8002c6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(eip, eip);
  8002cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d0:	8b 50 20             	mov    0x20(%eax),%edx
  8002d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d6:	8b 40 20             	mov    0x20(%eax),%eax
  8002d9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e1:	c7 44 24 04 0b 1b 80 	movl   $0x801b0b,0x4(%esp)
  8002e8:	00 
  8002e9:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  8002f0:	e8 d4 04 00 00       	call   8007c9 <cprintf>
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	8b 50 20             	mov    0x20(%eax),%edx
  8002fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fe:	8b 40 20             	mov    0x20(%eax),%eax
  800301:	39 c2                	cmp    %eax,%edx
  800303:	75 0e                	jne    800313 <check_regs+0x2e0>
  800305:	c7 04 24 e5 1a 80 00 	movl   $0x801ae5,(%esp)
  80030c:	e8 b8 04 00 00       	call   8007c9 <cprintf>
  800311:	eb 13                	jmp    800326 <check_regs+0x2f3>
  800313:	c7 04 24 e9 1a 80 00 	movl   $0x801ae9,(%esp)
  80031a:	e8 aa 04 00 00       	call   8007c9 <cprintf>
  80031f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(eflags, eflags);
  800326:	8b 45 10             	mov    0x10(%ebp),%eax
  800329:	8b 50 24             	mov    0x24(%eax),%edx
  80032c:	8b 45 08             	mov    0x8(%ebp),%eax
  80032f:	8b 40 24             	mov    0x24(%eax),%eax
  800332:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800336:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033a:	c7 44 24 04 0f 1b 80 	movl   $0x801b0f,0x4(%esp)
  800341:	00 
  800342:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  800349:	e8 7b 04 00 00       	call   8007c9 <cprintf>
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	8b 50 24             	mov    0x24(%eax),%edx
  800354:	8b 45 10             	mov    0x10(%ebp),%eax
  800357:	8b 40 24             	mov    0x24(%eax),%eax
  80035a:	39 c2                	cmp    %eax,%edx
  80035c:	75 0e                	jne    80036c <check_regs+0x339>
  80035e:	c7 04 24 e5 1a 80 00 	movl   $0x801ae5,(%esp)
  800365:	e8 5f 04 00 00       	call   8007c9 <cprintf>
  80036a:	eb 13                	jmp    80037f <check_regs+0x34c>
  80036c:	c7 04 24 e9 1a 80 00 	movl   $0x801ae9,(%esp)
  800373:	e8 51 04 00 00       	call   8007c9 <cprintf>
  800378:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(esp, esp);
  80037f:	8b 45 10             	mov    0x10(%ebp),%eax
  800382:	8b 50 28             	mov    0x28(%eax),%edx
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	8b 40 28             	mov    0x28(%eax),%eax
  80038b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80038f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800393:	c7 44 24 04 16 1b 80 	movl   $0x801b16,0x4(%esp)
  80039a:	00 
  80039b:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  8003a2:	e8 22 04 00 00       	call   8007c9 <cprintf>
  8003a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003aa:	8b 50 28             	mov    0x28(%eax),%edx
  8003ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b0:	8b 40 28             	mov    0x28(%eax),%eax
  8003b3:	39 c2                	cmp    %eax,%edx
  8003b5:	75 0e                	jne    8003c5 <check_regs+0x392>
  8003b7:	c7 04 24 e5 1a 80 00 	movl   $0x801ae5,(%esp)
  8003be:	e8 06 04 00 00       	call   8007c9 <cprintf>
  8003c3:	eb 13                	jmp    8003d8 <check_regs+0x3a5>
  8003c5:	c7 04 24 e9 1a 80 00 	movl   $0x801ae9,(%esp)
  8003cc:	e8 f8 03 00 00       	call   8007c9 <cprintf>
  8003d1:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)

#undef CHECK

	cprintf("Registers %s ", testname);
  8003d8:	8b 45 18             	mov    0x18(%ebp),%eax
  8003db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003df:	c7 04 24 1a 1b 80 00 	movl   $0x801b1a,(%esp)
  8003e6:	e8 de 03 00 00       	call   8007c9 <cprintf>
	if (!mismatch)
  8003eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8003ef:	75 0e                	jne    8003ff <check_regs+0x3cc>
		cprintf("OK\n");
  8003f1:	c7 04 24 e5 1a 80 00 	movl   $0x801ae5,(%esp)
  8003f8:	e8 cc 03 00 00       	call   8007c9 <cprintf>
  8003fd:	eb 0c                	jmp    80040b <check_regs+0x3d8>
	else
		cprintf("MISMATCH\n");
  8003ff:	c7 04 24 e9 1a 80 00 	movl   $0x801ae9,(%esp)
  800406:	e8 be 03 00 00       	call   8007c9 <cprintf>
}
  80040b:	c9                   	leave  
  80040c:	c3                   	ret    

0080040d <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	83 ec 38             	sub    $0x38,%esp
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  800413:	8b 45 08             	mov    0x8(%ebp),%eax
  800416:	8b 00                	mov    (%eax),%eax
  800418:	3d 00 00 40 00       	cmp    $0x400000,%eax
  80041d:	74 2f                	je     80044e <pgfault+0x41>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  80041f:	8b 45 08             	mov    0x8(%ebp),%eax
  800422:	8b 50 28             	mov    0x28(%eax),%edx
  800425:	8b 45 08             	mov    0x8(%ebp),%eax
  800428:	8b 00                	mov    (%eax),%eax
  80042a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80042e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800432:	c7 44 24 08 28 1b 80 	movl   $0x801b28,0x8(%esp)
  800439:	00 
  80043a:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800441:	00 
  800442:	c7 04 24 59 1b 80 00 	movl   $0x801b59,(%esp)
  800449:	e8 60 02 00 00       	call   8006ae <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	8b 50 08             	mov    0x8(%eax),%edx
  800454:	89 15 60 20 80 00    	mov    %edx,0x802060
  80045a:	8b 50 0c             	mov    0xc(%eax),%edx
  80045d:	89 15 64 20 80 00    	mov    %edx,0x802064
  800463:	8b 50 10             	mov    0x10(%eax),%edx
  800466:	89 15 68 20 80 00    	mov    %edx,0x802068
  80046c:	8b 50 14             	mov    0x14(%eax),%edx
  80046f:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  800475:	8b 50 18             	mov    0x18(%eax),%edx
  800478:	89 15 70 20 80 00    	mov    %edx,0x802070
  80047e:	8b 50 1c             	mov    0x1c(%eax),%edx
  800481:	89 15 74 20 80 00    	mov    %edx,0x802074
  800487:	8b 50 20             	mov    0x20(%eax),%edx
  80048a:	89 15 78 20 80 00    	mov    %edx,0x802078
  800490:	8b 40 24             	mov    0x24(%eax),%eax
  800493:	a3 7c 20 80 00       	mov    %eax,0x80207c
	during.eip = utf->utf_eip;
  800498:	8b 45 08             	mov    0x8(%ebp),%eax
  80049b:	8b 40 28             	mov    0x28(%eax),%eax
  80049e:	a3 80 20 80 00       	mov    %eax,0x802080
	during.eflags = utf->utf_eflags;
  8004a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a6:	8b 40 2c             	mov    0x2c(%eax),%eax
  8004a9:	a3 84 20 80 00       	mov    %eax,0x802084
	during.esp = utf->utf_esp;
  8004ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b1:	8b 40 30             	mov    0x30(%eax),%eax
  8004b4:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8004b9:	c7 44 24 10 6a 1b 80 	movl   $0x801b6a,0x10(%esp)
  8004c0:	00 
  8004c1:	c7 44 24 0c 78 1b 80 	movl   $0x801b78,0xc(%esp)
  8004c8:	00 
  8004c9:	c7 44 24 08 60 20 80 	movl   $0x802060,0x8(%esp)
  8004d0:	00 
  8004d1:	c7 44 24 04 7f 1b 80 	movl   $0x801b7f,0x4(%esp)
  8004d8:	00 
  8004d9:	c7 04 24 20 20 80 00 	movl   $0x802020,(%esp)
  8004e0:	e8 4e fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  8004e5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8004ec:	00 
  8004ed:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8004f4:	00 
  8004f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8004fc:	e8 be 10 00 00       	call   8015bf <sys_page_alloc>
  800501:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800504:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800508:	79 23                	jns    80052d <pgfault+0x120>
		panic("sys_page_alloc: %e", r);
  80050a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80050d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800511:	c7 44 24 08 86 1b 80 	movl   $0x801b86,0x8(%esp)
  800518:	00 
  800519:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800520:	00 
  800521:	c7 04 24 59 1b 80 00 	movl   $0x801b59,(%esp)
  800528:	e8 81 01 00 00       	call   8006ae <_panic>
}
  80052d:	c9                   	leave  
  80052e:	c3                   	ret    

0080052f <umain>:

void
umain(int argc, char **argv)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800535:	c7 04 24 0d 04 80 00 	movl   $0x80040d,(%esp)
  80053c:	e8 4e 12 00 00       	call   80178f <set_pgfault_handler>

	__asm __volatile(
  800541:	50                   	push   %eax
  800542:	9c                   	pushf  
  800543:	58                   	pop    %eax
  800544:	0d d5 08 00 00       	or     $0x8d5,%eax
  800549:	50                   	push   %eax
  80054a:	9d                   	popf   
  80054b:	a3 44 20 80 00       	mov    %eax,0x802044
  800550:	8d 05 8b 05 80 00    	lea    0x80058b,%eax
  800556:	a3 40 20 80 00       	mov    %eax,0x802040
  80055b:	58                   	pop    %eax
  80055c:	89 3d 20 20 80 00    	mov    %edi,0x802020
  800562:	89 35 24 20 80 00    	mov    %esi,0x802024
  800568:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  80056e:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  800574:	89 15 34 20 80 00    	mov    %edx,0x802034
  80057a:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800580:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800585:	89 25 48 20 80 00    	mov    %esp,0x802048
  80058b:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800592:	00 00 00 
  800595:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  80059b:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8005a1:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  8005a7:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  8005ad:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8005b3:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8005b9:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8005be:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8005c4:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  8005ca:	8b 35 24 20 80 00    	mov    0x802024,%esi
  8005d0:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  8005d6:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  8005dc:	8b 15 34 20 80 00    	mov    0x802034,%edx
  8005e2:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  8005e8:	a1 3c 20 80 00       	mov    0x80203c,%eax
  8005ed:	8b 25 48 20 80 00    	mov    0x802048,%esp
  8005f3:	50                   	push   %eax
  8005f4:	9c                   	pushf  
  8005f5:	58                   	pop    %eax
  8005f6:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8005fb:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  8005fc:	b8 00 00 40 00       	mov    $0x400000,%eax
  800601:	8b 00                	mov    (%eax),%eax
  800603:	83 f8 2a             	cmp    $0x2a,%eax
  800606:	74 0c                	je     800614 <umain+0xe5>
		cprintf("EIP after page-fault MISMATCH\n");
  800608:	c7 04 24 9c 1b 80 00 	movl   $0x801b9c,(%esp)
  80060f:	e8 b5 01 00 00       	call   8007c9 <cprintf>
	after.eip = before.eip;
  800614:	a1 40 20 80 00       	mov    0x802040,%eax
  800619:	a3 c0 20 80 00       	mov    %eax,0x8020c0

	check_regs(&before, "before", &after, "after", "after page-fault");
  80061e:	c7 44 24 10 bb 1b 80 	movl   $0x801bbb,0x10(%esp)
  800625:	00 
  800626:	c7 44 24 0c cc 1b 80 	movl   $0x801bcc,0xc(%esp)
  80062d:	00 
  80062e:	c7 44 24 08 a0 20 80 	movl   $0x8020a0,0x8(%esp)
  800635:	00 
  800636:	c7 44 24 04 7f 1b 80 	movl   $0x801b7f,0x4(%esp)
  80063d:	00 
  80063e:	c7 04 24 20 20 80 00 	movl   $0x802020,(%esp)
  800645:	e8 e9 f9 ff ff       	call   800033 <check_regs>
}
  80064a:	c9                   	leave  
  80064b:	c3                   	ret    

0080064c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800652:	e8 e0 0e 00 00       	call   801537 <sys_getenvid>
  800657:	25 ff 03 00 00       	and    $0x3ff,%eax
  80065c:	c1 e0 02             	shl    $0x2,%eax
  80065f:	89 c2                	mov    %eax,%edx
  800661:	c1 e2 05             	shl    $0x5,%edx
  800664:	29 c2                	sub    %eax,%edx
  800666:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80066c:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800671:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800675:	7e 0a                	jle    800681 <libmain+0x35>
		binaryname = argv[0];
  800677:	8b 45 0c             	mov    0xc(%ebp),%eax
  80067a:	8b 00                	mov    (%eax),%eax
  80067c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800681:	8b 45 0c             	mov    0xc(%ebp),%eax
  800684:	89 44 24 04          	mov    %eax,0x4(%esp)
  800688:	8b 45 08             	mov    0x8(%ebp),%eax
  80068b:	89 04 24             	mov    %eax,(%esp)
  80068e:	e8 9c fe ff ff       	call   80052f <umain>

	// exit gracefully
	exit();
  800693:	e8 02 00 00 00       	call   80069a <exit>
}
  800698:	c9                   	leave  
  800699:	c3                   	ret    

0080069a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8006a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006a7:	e8 48 0e 00 00       	call   8014f4 <sys_env_destroy>
}
  8006ac:	c9                   	leave  
  8006ad:	c3                   	ret    

008006ae <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006ae:	55                   	push   %ebp
  8006af:	89 e5                	mov    %esp,%ebp
  8006b1:	53                   	push   %ebx
  8006b2:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8006b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b8:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8006bb:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8006c1:	e8 71 0e 00 00       	call   801537 <sys_getenvid>
  8006c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006c9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006dc:	c7 04 24 dc 1b 80 00 	movl   $0x801bdc,(%esp)
  8006e3:	e8 e1 00 00 00       	call   8007c9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f2:	89 04 24             	mov    %eax,(%esp)
  8006f5:	e8 6b 00 00 00       	call   800765 <vcprintf>
	cprintf("\n");
  8006fa:	c7 04 24 ff 1b 80 00 	movl   $0x801bff,(%esp)
  800701:	e8 c3 00 00 00       	call   8007c9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800706:	cc                   	int3   
  800707:	eb fd                	jmp    800706 <_panic+0x58>

00800709 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80070f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800712:	8b 00                	mov    (%eax),%eax
  800714:	8d 48 01             	lea    0x1(%eax),%ecx
  800717:	8b 55 0c             	mov    0xc(%ebp),%edx
  80071a:	89 0a                	mov    %ecx,(%edx)
  80071c:	8b 55 08             	mov    0x8(%ebp),%edx
  80071f:	89 d1                	mov    %edx,%ecx
  800721:	8b 55 0c             	mov    0xc(%ebp),%edx
  800724:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800728:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072b:	8b 00                	mov    (%eax),%eax
  80072d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800732:	75 20                	jne    800754 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800734:	8b 45 0c             	mov    0xc(%ebp),%eax
  800737:	8b 00                	mov    (%eax),%eax
  800739:	8b 55 0c             	mov    0xc(%ebp),%edx
  80073c:	83 c2 08             	add    $0x8,%edx
  80073f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800743:	89 14 24             	mov    %edx,(%esp)
  800746:	e8 23 0d 00 00       	call   80146e <sys_cputs>
		b->idx = 0;
  80074b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800754:	8b 45 0c             	mov    0xc(%ebp),%eax
  800757:	8b 40 04             	mov    0x4(%eax),%eax
  80075a:	8d 50 01             	lea    0x1(%eax),%edx
  80075d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800760:	89 50 04             	mov    %edx,0x4(%eax)
}
  800763:	c9                   	leave  
  800764:	c3                   	ret    

00800765 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80076e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800775:	00 00 00 
	b.cnt = 0;
  800778:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80077f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800782:	8b 45 0c             	mov    0xc(%ebp),%eax
  800785:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800789:	8b 45 08             	mov    0x8(%ebp),%eax
  80078c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800790:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800796:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079a:	c7 04 24 09 07 80 00 	movl   $0x800709,(%esp)
  8007a1:	e8 bd 01 00 00       	call   800963 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8007a6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8007ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007b6:	83 c0 08             	add    $0x8,%eax
  8007b9:	89 04 24             	mov    %eax,(%esp)
  8007bc:	e8 ad 0c 00 00       	call   80146e <sys_cputs>

	return b.cnt;
  8007c1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8007cf:	8d 45 0c             	lea    0xc(%ebp),%eax
  8007d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8007d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007df:	89 04 24             	mov    %eax,(%esp)
  8007e2:	e8 7e ff ff ff       	call   800765 <vcprintf>
  8007e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8007ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007ed:	c9                   	leave  
  8007ee:	c3                   	ret    

008007ef <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	83 ec 34             	sub    $0x34,%esp
  8007f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800802:	8b 45 18             	mov    0x18(%ebp),%eax
  800805:	ba 00 00 00 00       	mov    $0x0,%edx
  80080a:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80080d:	77 72                	ja     800881 <printnum+0x92>
  80080f:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800812:	72 05                	jb     800819 <printnum+0x2a>
  800814:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800817:	77 68                	ja     800881 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800819:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80081c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80081f:	8b 45 18             	mov    0x18(%ebp),%eax
  800822:	ba 00 00 00 00       	mov    $0x0,%edx
  800827:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80082f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800832:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800835:	89 04 24             	mov    %eax,(%esp)
  800838:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083c:	e8 ef 0f 00 00       	call   801830 <__udivdi3>
  800841:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800844:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800848:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80084c:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80084f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800853:	89 44 24 08          	mov    %eax,0x8(%esp)
  800857:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	89 04 24             	mov    %eax,(%esp)
  800868:	e8 82 ff ff ff       	call   8007ef <printnum>
  80086d:	eb 1c                	jmp    80088b <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80086f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800872:	89 44 24 04          	mov    %eax,0x4(%esp)
  800876:	8b 45 20             	mov    0x20(%ebp),%eax
  800879:	89 04 24             	mov    %eax,(%esp)
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800881:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800885:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800889:	7f e4                	jg     80086f <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80088b:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80088e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800893:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800896:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800899:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80089d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008a1:	89 04 24             	mov    %eax,(%esp)
  8008a4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a8:	e8 b3 10 00 00       	call   801960 <__umoddi3>
  8008ad:	05 e8 1c 80 00       	add    $0x801ce8,%eax
  8008b2:	0f b6 00             	movzbl (%eax),%eax
  8008b5:	0f be c0             	movsbl %al,%eax
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008bf:	89 04 24             	mov    %eax,(%esp)
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	ff d0                	call   *%eax
}
  8008c7:	83 c4 34             	add    $0x34,%esp
  8008ca:	5b                   	pop    %ebx
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8008d0:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8008d4:	7e 14                	jle    8008ea <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	8b 00                	mov    (%eax),%eax
  8008db:	8d 48 08             	lea    0x8(%eax),%ecx
  8008de:	8b 55 08             	mov    0x8(%ebp),%edx
  8008e1:	89 0a                	mov    %ecx,(%edx)
  8008e3:	8b 50 04             	mov    0x4(%eax),%edx
  8008e6:	8b 00                	mov    (%eax),%eax
  8008e8:	eb 30                	jmp    80091a <getuint+0x4d>
	else if (lflag)
  8008ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008ee:	74 16                	je     800906 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8b 00                	mov    (%eax),%eax
  8008f5:	8d 48 04             	lea    0x4(%eax),%ecx
  8008f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008fb:	89 0a                	mov    %ecx,(%edx)
  8008fd:	8b 00                	mov    (%eax),%eax
  8008ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800904:	eb 14                	jmp    80091a <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 00                	mov    (%eax),%eax
  80090b:	8d 48 04             	lea    0x4(%eax),%ecx
  80090e:	8b 55 08             	mov    0x8(%ebp),%edx
  800911:	89 0a                	mov    %ecx,(%edx)
  800913:	8b 00                	mov    (%eax),%eax
  800915:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80091f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800923:	7e 14                	jle    800939 <getint+0x1d>
		return va_arg(*ap, long long);
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 00                	mov    (%eax),%eax
  80092a:	8d 48 08             	lea    0x8(%eax),%ecx
  80092d:	8b 55 08             	mov    0x8(%ebp),%edx
  800930:	89 0a                	mov    %ecx,(%edx)
  800932:	8b 50 04             	mov    0x4(%eax),%edx
  800935:	8b 00                	mov    (%eax),%eax
  800937:	eb 28                	jmp    800961 <getint+0x45>
	else if (lflag)
  800939:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80093d:	74 12                	je     800951 <getint+0x35>
		return va_arg(*ap, long);
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 00                	mov    (%eax),%eax
  800944:	8d 48 04             	lea    0x4(%eax),%ecx
  800947:	8b 55 08             	mov    0x8(%ebp),%edx
  80094a:	89 0a                	mov    %ecx,(%edx)
  80094c:	8b 00                	mov    (%eax),%eax
  80094e:	99                   	cltd   
  80094f:	eb 10                	jmp    800961 <getint+0x45>
	else
		return va_arg(*ap, int);
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	8b 00                	mov    (%eax),%eax
  800956:	8d 48 04             	lea    0x4(%eax),%ecx
  800959:	8b 55 08             	mov    0x8(%ebp),%edx
  80095c:	89 0a                	mov    %ecx,(%edx)
  80095e:	8b 00                	mov    (%eax),%eax
  800960:	99                   	cltd   
}
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
  800968:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80096b:	eb 18                	jmp    800985 <vprintfmt+0x22>
			if (ch == '\0')
  80096d:	85 db                	test   %ebx,%ebx
  80096f:	75 05                	jne    800976 <vprintfmt+0x13>
				return;
  800971:	e9 05 04 00 00       	jmp    800d7b <vprintfmt+0x418>
			putch(ch, putdat);
  800976:	8b 45 0c             	mov    0xc(%ebp),%eax
  800979:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097d:	89 1c 24             	mov    %ebx,(%esp)
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800985:	8b 45 10             	mov    0x10(%ebp),%eax
  800988:	8d 50 01             	lea    0x1(%eax),%edx
  80098b:	89 55 10             	mov    %edx,0x10(%ebp)
  80098e:	0f b6 00             	movzbl (%eax),%eax
  800991:	0f b6 d8             	movzbl %al,%ebx
  800994:	83 fb 25             	cmp    $0x25,%ebx
  800997:	75 d4                	jne    80096d <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800999:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80099d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8009a4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8009ab:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8009b2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8009bc:	8d 50 01             	lea    0x1(%eax),%edx
  8009bf:	89 55 10             	mov    %edx,0x10(%ebp)
  8009c2:	0f b6 00             	movzbl (%eax),%eax
  8009c5:	0f b6 d8             	movzbl %al,%ebx
  8009c8:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8009cb:	83 f8 55             	cmp    $0x55,%eax
  8009ce:	0f 87 76 03 00 00    	ja     800d4a <vprintfmt+0x3e7>
  8009d4:	8b 04 85 0c 1d 80 00 	mov    0x801d0c(,%eax,4),%eax
  8009db:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8009dd:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8009e1:	eb d6                	jmp    8009b9 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8009e3:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8009e7:	eb d0                	jmp    8009b9 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8009e9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8009f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8009f3:	89 d0                	mov    %edx,%eax
  8009f5:	c1 e0 02             	shl    $0x2,%eax
  8009f8:	01 d0                	add    %edx,%eax
  8009fa:	01 c0                	add    %eax,%eax
  8009fc:	01 d8                	add    %ebx,%eax
  8009fe:	83 e8 30             	sub    $0x30,%eax
  800a01:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800a04:	8b 45 10             	mov    0x10(%ebp),%eax
  800a07:	0f b6 00             	movzbl (%eax),%eax
  800a0a:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800a0d:	83 fb 2f             	cmp    $0x2f,%ebx
  800a10:	7e 0b                	jle    800a1d <vprintfmt+0xba>
  800a12:	83 fb 39             	cmp    $0x39,%ebx
  800a15:	7f 06                	jg     800a1d <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a17:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a1b:	eb d3                	jmp    8009f0 <vprintfmt+0x8d>
			goto process_precision;
  800a1d:	eb 33                	jmp    800a52 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800a1f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a22:	8d 50 04             	lea    0x4(%eax),%edx
  800a25:	89 55 14             	mov    %edx,0x14(%ebp)
  800a28:	8b 00                	mov    (%eax),%eax
  800a2a:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800a2d:	eb 23                	jmp    800a52 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800a2f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a33:	79 0c                	jns    800a41 <vprintfmt+0xde>
				width = 0;
  800a35:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800a3c:	e9 78 ff ff ff       	jmp    8009b9 <vprintfmt+0x56>
  800a41:	e9 73 ff ff ff       	jmp    8009b9 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800a46:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800a4d:	e9 67 ff ff ff       	jmp    8009b9 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800a52:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a56:	79 12                	jns    800a6a <vprintfmt+0x107>
				width = precision, precision = -1;
  800a58:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a5e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800a65:	e9 4f ff ff ff       	jmp    8009b9 <vprintfmt+0x56>
  800a6a:	e9 4a ff ff ff       	jmp    8009b9 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a6f:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800a73:	e9 41 ff ff ff       	jmp    8009b9 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800a78:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7b:	8d 50 04             	lea    0x4(%eax),%edx
  800a7e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a81:	8b 00                	mov    (%eax),%eax
  800a83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a86:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a8a:	89 04 24             	mov    %eax,(%esp)
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	ff d0                	call   *%eax
			break;
  800a92:	e9 de 02 00 00       	jmp    800d75 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800a97:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9a:	8d 50 04             	lea    0x4(%eax),%edx
  800a9d:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa0:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800aa2:	85 db                	test   %ebx,%ebx
  800aa4:	79 02                	jns    800aa8 <vprintfmt+0x145>
				err = -err;
  800aa6:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800aa8:	83 fb 09             	cmp    $0x9,%ebx
  800aab:	7f 0b                	jg     800ab8 <vprintfmt+0x155>
  800aad:	8b 34 9d c0 1c 80 00 	mov    0x801cc0(,%ebx,4),%esi
  800ab4:	85 f6                	test   %esi,%esi
  800ab6:	75 23                	jne    800adb <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800ab8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800abc:	c7 44 24 08 f9 1c 80 	movl   $0x801cf9,0x8(%esp)
  800ac3:	00 
  800ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	89 04 24             	mov    %eax,(%esp)
  800ad1:	e8 ac 02 00 00       	call   800d82 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800ad6:	e9 9a 02 00 00       	jmp    800d75 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800adb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800adf:	c7 44 24 08 02 1d 80 	movl   $0x801d02,0x8(%esp)
  800ae6:	00 
  800ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aea:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aee:	8b 45 08             	mov    0x8(%ebp),%eax
  800af1:	89 04 24             	mov    %eax,(%esp)
  800af4:	e8 89 02 00 00       	call   800d82 <printfmt>
			break;
  800af9:	e9 77 02 00 00       	jmp    800d75 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800afe:	8b 45 14             	mov    0x14(%ebp),%eax
  800b01:	8d 50 04             	lea    0x4(%eax),%edx
  800b04:	89 55 14             	mov    %edx,0x14(%ebp)
  800b07:	8b 30                	mov    (%eax),%esi
  800b09:	85 f6                	test   %esi,%esi
  800b0b:	75 05                	jne    800b12 <vprintfmt+0x1af>
				p = "(null)";
  800b0d:	be 05 1d 80 00       	mov    $0x801d05,%esi
			if (width > 0 && padc != '-')
  800b12:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b16:	7e 37                	jle    800b4f <vprintfmt+0x1ec>
  800b18:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800b1c:	74 31                	je     800b4f <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b25:	89 34 24             	mov    %esi,(%esp)
  800b28:	e8 72 03 00 00       	call   800e9f <strnlen>
  800b2d:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800b30:	eb 17                	jmp    800b49 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800b32:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800b36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b39:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b3d:	89 04 24             	mov    %eax,(%esp)
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
  800b43:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b45:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800b49:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b4d:	7f e3                	jg     800b32 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b4f:	eb 38                	jmp    800b89 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800b51:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b55:	74 1f                	je     800b76 <vprintfmt+0x213>
  800b57:	83 fb 1f             	cmp    $0x1f,%ebx
  800b5a:	7e 05                	jle    800b61 <vprintfmt+0x1fe>
  800b5c:	83 fb 7e             	cmp    $0x7e,%ebx
  800b5f:	7e 15                	jle    800b76 <vprintfmt+0x213>
					putch('?', putdat);
  800b61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b68:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b72:	ff d0                	call   *%eax
  800b74:	eb 0f                	jmp    800b85 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800b76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b7d:	89 1c 24             	mov    %ebx,(%esp)
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
  800b83:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b85:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800b89:	89 f0                	mov    %esi,%eax
  800b8b:	8d 70 01             	lea    0x1(%eax),%esi
  800b8e:	0f b6 00             	movzbl (%eax),%eax
  800b91:	0f be d8             	movsbl %al,%ebx
  800b94:	85 db                	test   %ebx,%ebx
  800b96:	74 10                	je     800ba8 <vprintfmt+0x245>
  800b98:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b9c:	78 b3                	js     800b51 <vprintfmt+0x1ee>
  800b9e:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800ba2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ba6:	79 a9                	jns    800b51 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ba8:	eb 17                	jmp    800bc1 <vprintfmt+0x25e>
				putch(' ', putdat);
  800baa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bad:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbb:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bbd:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800bc1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800bc5:	7f e3                	jg     800baa <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800bc7:	e9 a9 01 00 00       	jmp    800d75 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800bcc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd3:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd6:	89 04 24             	mov    %eax,(%esp)
  800bd9:	e8 3e fd ff ff       	call   80091c <getint>
  800bde:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800be1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800be4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800be7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bea:	85 d2                	test   %edx,%edx
  800bec:	79 26                	jns    800c14 <vprintfmt+0x2b1>
				putch('-', putdat);
  800bee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf5:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bff:	ff d0                	call   *%eax
				num = -(long long) num;
  800c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c07:	f7 d8                	neg    %eax
  800c09:	83 d2 00             	adc    $0x0,%edx
  800c0c:	f7 da                	neg    %edx
  800c0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c11:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800c14:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800c1b:	e9 e1 00 00 00       	jmp    800d01 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c20:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800c23:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c27:	8d 45 14             	lea    0x14(%ebp),%eax
  800c2a:	89 04 24             	mov    %eax,(%esp)
  800c2d:	e8 9b fc ff ff       	call   8008cd <getuint>
  800c32:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c35:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800c38:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800c3f:	e9 bd 00 00 00       	jmp    800d01 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  800c44:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  800c4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c52:	8d 45 14             	lea    0x14(%ebp),%eax
  800c55:	89 04 24             	mov    %eax,(%esp)
  800c58:	e8 70 fc ff ff       	call   8008cd <getuint>
  800c5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c60:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  800c63:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800c67:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c6a:	89 54 24 18          	mov    %edx,0x18(%esp)
  800c6e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c71:	89 54 24 14          	mov    %edx,0x14(%esp)
  800c75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c83:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c91:	89 04 24             	mov    %eax,(%esp)
  800c94:	e8 56 fb ff ff       	call   8007ef <printnum>
			break;
  800c99:	e9 d7 00 00 00       	jmp    800d75 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  800c9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca5:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800cac:	8b 45 08             	mov    0x8(%ebp),%eax
  800caf:	ff d0                	call   *%eax
			putch('x', putdat);
  800cb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc2:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800cc4:	8b 45 14             	mov    0x14(%ebp),%eax
  800cc7:	8d 50 04             	lea    0x4(%eax),%edx
  800cca:	89 55 14             	mov    %edx,0x14(%ebp)
  800ccd:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ccf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cd2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800cd9:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800ce0:	eb 1f                	jmp    800d01 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ce2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ce5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce9:	8d 45 14             	lea    0x14(%ebp),%eax
  800cec:	89 04 24             	mov    %eax,(%esp)
  800cef:	e8 d9 fb ff ff       	call   8008cd <getuint>
  800cf4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cf7:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800cfa:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d01:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800d05:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d08:	89 54 24 18          	mov    %edx,0x18(%esp)
  800d0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d0f:	89 54 24 14          	mov    %edx,0x14(%esp)
  800d13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d1d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d21:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d28:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2f:	89 04 24             	mov    %eax,(%esp)
  800d32:	e8 b8 fa ff ff       	call   8007ef <printnum>
			break;
  800d37:	eb 3c                	jmp    800d75 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d40:	89 1c 24             	mov    %ebx,(%esp)
  800d43:	8b 45 08             	mov    0x8(%ebp),%eax
  800d46:	ff d0                	call   *%eax
			break;
  800d48:	eb 2b                	jmp    800d75 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d51:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d5d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d61:	eb 04                	jmp    800d67 <vprintfmt+0x404>
  800d63:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d67:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6a:	83 e8 01             	sub    $0x1,%eax
  800d6d:	0f b6 00             	movzbl (%eax),%eax
  800d70:	3c 25                	cmp    $0x25,%al
  800d72:	75 ef                	jne    800d63 <vprintfmt+0x400>
				/* do nothing */;
			break;
  800d74:	90                   	nop
		}
	}
  800d75:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800d76:	e9 0a fc ff ff       	jmp    800985 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800d7b:	83 c4 40             	add    $0x40,%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800d88:	8d 45 14             	lea    0x14(%ebp),%eax
  800d8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d91:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d95:	8b 45 10             	mov    0x10(%ebp),%eax
  800d98:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da3:	8b 45 08             	mov    0x8(%ebp),%eax
  800da6:	89 04 24             	mov    %eax,(%esp)
  800da9:	e8 b5 fb ff ff       	call   800963 <vprintfmt>
	va_end(ap);
}
  800dae:	c9                   	leave  
  800daf:	c3                   	ret    

00800db0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800db3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db6:	8b 40 08             	mov    0x8(%eax),%eax
  800db9:	8d 50 01             	lea    0x1(%eax),%edx
  800dbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbf:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc5:	8b 10                	mov    (%eax),%edx
  800dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dca:	8b 40 04             	mov    0x4(%eax),%eax
  800dcd:	39 c2                	cmp    %eax,%edx
  800dcf:	73 12                	jae    800de3 <sprintputch+0x33>
		*b->buf++ = ch;
  800dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd4:	8b 00                	mov    (%eax),%eax
  800dd6:	8d 48 01             	lea    0x1(%eax),%ecx
  800dd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ddc:	89 0a                	mov    %ecx,(%edx)
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	88 10                	mov    %dl,(%eax)
}
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800deb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800df1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df4:	8d 50 ff             	lea    -0x1(%eax),%edx
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfa:	01 d0                	add    %edx,%eax
  800dfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800dff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e06:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800e0a:	74 06                	je     800e12 <vsnprintf+0x2d>
  800e0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e10:	7f 07                	jg     800e19 <vsnprintf+0x34>
		return -E_INVAL;
  800e12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e17:	eb 2a                	jmp    800e43 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e19:	8b 45 14             	mov    0x14(%ebp),%eax
  800e1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e20:	8b 45 10             	mov    0x10(%ebp),%eax
  800e23:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e27:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e2e:	c7 04 24 b0 0d 80 00 	movl   $0x800db0,(%esp)
  800e35:	e8 29 fb ff ff       	call   800963 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e3d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800e43:	c9                   	leave  
  800e44:	c3                   	ret    

00800e45 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e4b:	8d 45 14             	lea    0x14(%ebp),%eax
  800e4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800e51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e54:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e58:	8b 45 10             	mov    0x10(%ebp),%eax
  800e5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e62:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e66:	8b 45 08             	mov    0x8(%ebp),%eax
  800e69:	89 04 24             	mov    %eax,(%esp)
  800e6c:	e8 74 ff ff ff       	call   800de5 <vsnprintf>
  800e71:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800e77:	c9                   	leave  
  800e78:	c3                   	ret    

00800e79 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800e7f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800e86:	eb 08                	jmp    800e90 <strlen+0x17>
		n++;
  800e88:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e8c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e90:	8b 45 08             	mov    0x8(%ebp),%eax
  800e93:	0f b6 00             	movzbl (%eax),%eax
  800e96:	84 c0                	test   %al,%al
  800e98:	75 ee                	jne    800e88 <strlen+0xf>
		n++;
	return n;
  800e9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    

00800e9f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ea5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800eac:	eb 0c                	jmp    800eba <strnlen+0x1b>
		n++;
  800eae:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800eb2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800eb6:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800eba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ebe:	74 0a                	je     800eca <strnlen+0x2b>
  800ec0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec3:	0f b6 00             	movzbl (%eax),%eax
  800ec6:	84 c0                	test   %al,%al
  800ec8:	75 e4                	jne    800eae <strnlen+0xf>
		n++;
	return n;
  800eca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800ecd:	c9                   	leave  
  800ece:	c3                   	ret    

00800ecf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800ed5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800edb:	90                   	nop
  800edc:	8b 45 08             	mov    0x8(%ebp),%eax
  800edf:	8d 50 01             	lea    0x1(%eax),%edx
  800ee2:	89 55 08             	mov    %edx,0x8(%ebp)
  800ee5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee8:	8d 4a 01             	lea    0x1(%edx),%ecx
  800eeb:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800eee:	0f b6 12             	movzbl (%edx),%edx
  800ef1:	88 10                	mov    %dl,(%eax)
  800ef3:	0f b6 00             	movzbl (%eax),%eax
  800ef6:	84 c0                	test   %al,%al
  800ef8:	75 e2                	jne    800edc <strcpy+0xd>
		/* do nothing */;
	return ret;
  800efa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <strcat>:

char *
strcat(char *dst, const char *src)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800f05:	8b 45 08             	mov    0x8(%ebp),%eax
  800f08:	89 04 24             	mov    %eax,(%esp)
  800f0b:	e8 69 ff ff ff       	call   800e79 <strlen>
  800f10:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800f13:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800f16:	8b 45 08             	mov    0x8(%ebp),%eax
  800f19:	01 c2                	add    %eax,%edx
  800f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f22:	89 14 24             	mov    %edx,(%esp)
  800f25:	e8 a5 ff ff ff       	call   800ecf <strcpy>
	return dst;
  800f2a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800f35:	8b 45 08             	mov    0x8(%ebp),%eax
  800f38:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800f3b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800f42:	eb 23                	jmp    800f67 <strncpy+0x38>
		*dst++ = *src;
  800f44:	8b 45 08             	mov    0x8(%ebp),%eax
  800f47:	8d 50 01             	lea    0x1(%eax),%edx
  800f4a:	89 55 08             	mov    %edx,0x8(%ebp)
  800f4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f50:	0f b6 12             	movzbl (%edx),%edx
  800f53:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800f55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f58:	0f b6 00             	movzbl (%eax),%eax
  800f5b:	84 c0                	test   %al,%al
  800f5d:	74 04                	je     800f63 <strncpy+0x34>
			src++;
  800f5f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f63:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800f67:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f6a:	3b 45 10             	cmp    0x10(%ebp),%eax
  800f6d:	72 d5                	jb     800f44 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800f6f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800f80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f84:	74 33                	je     800fb9 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800f86:	eb 17                	jmp    800f9f <strlcpy+0x2b>
			*dst++ = *src++;
  800f88:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8b:	8d 50 01             	lea    0x1(%eax),%edx
  800f8e:	89 55 08             	mov    %edx,0x8(%ebp)
  800f91:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f94:	8d 4a 01             	lea    0x1(%edx),%ecx
  800f97:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800f9a:	0f b6 12             	movzbl (%edx),%edx
  800f9d:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800f9f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800fa3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fa7:	74 0a                	je     800fb3 <strlcpy+0x3f>
  800fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fac:	0f b6 00             	movzbl (%eax),%eax
  800faf:	84 c0                	test   %al,%al
  800fb1:	75 d5                	jne    800f88 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800fb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fbf:	29 c2                	sub    %eax,%edx
  800fc1:	89 d0                	mov    %edx,%eax
}
  800fc3:	c9                   	leave  
  800fc4:	c3                   	ret    

00800fc5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800fc8:	eb 08                	jmp    800fd2 <strcmp+0xd>
		p++, q++;
  800fca:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800fce:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd5:	0f b6 00             	movzbl (%eax),%eax
  800fd8:	84 c0                	test   %al,%al
  800fda:	74 10                	je     800fec <strcmp+0x27>
  800fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdf:	0f b6 10             	movzbl (%eax),%edx
  800fe2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe5:	0f b6 00             	movzbl (%eax),%eax
  800fe8:	38 c2                	cmp    %al,%dl
  800fea:	74 de                	je     800fca <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800fec:	8b 45 08             	mov    0x8(%ebp),%eax
  800fef:	0f b6 00             	movzbl (%eax),%eax
  800ff2:	0f b6 d0             	movzbl %al,%edx
  800ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff8:	0f b6 00             	movzbl (%eax),%eax
  800ffb:	0f b6 c0             	movzbl %al,%eax
  800ffe:	29 c2                	sub    %eax,%edx
  801000:	89 d0                	mov    %edx,%eax
}
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  801007:	eb 0c                	jmp    801015 <strncmp+0x11>
		n--, p++, q++;
  801009:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80100d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801011:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801015:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801019:	74 1a                	je     801035 <strncmp+0x31>
  80101b:	8b 45 08             	mov    0x8(%ebp),%eax
  80101e:	0f b6 00             	movzbl (%eax),%eax
  801021:	84 c0                	test   %al,%al
  801023:	74 10                	je     801035 <strncmp+0x31>
  801025:	8b 45 08             	mov    0x8(%ebp),%eax
  801028:	0f b6 10             	movzbl (%eax),%edx
  80102b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102e:	0f b6 00             	movzbl (%eax),%eax
  801031:	38 c2                	cmp    %al,%dl
  801033:	74 d4                	je     801009 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  801035:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801039:	75 07                	jne    801042 <strncmp+0x3e>
		return 0;
  80103b:	b8 00 00 00 00       	mov    $0x0,%eax
  801040:	eb 16                	jmp    801058 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801042:	8b 45 08             	mov    0x8(%ebp),%eax
  801045:	0f b6 00             	movzbl (%eax),%eax
  801048:	0f b6 d0             	movzbl %al,%edx
  80104b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80104e:	0f b6 00             	movzbl (%eax),%eax
  801051:	0f b6 c0             	movzbl %al,%eax
  801054:	29 c2                	sub    %eax,%edx
  801056:	89 d0                	mov    %edx,%eax
}
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    

0080105a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	83 ec 04             	sub    $0x4,%esp
  801060:	8b 45 0c             	mov    0xc(%ebp),%eax
  801063:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  801066:	eb 14                	jmp    80107c <strchr+0x22>
		if (*s == c)
  801068:	8b 45 08             	mov    0x8(%ebp),%eax
  80106b:	0f b6 00             	movzbl (%eax),%eax
  80106e:	3a 45 fc             	cmp    -0x4(%ebp),%al
  801071:	75 05                	jne    801078 <strchr+0x1e>
			return (char *) s;
  801073:	8b 45 08             	mov    0x8(%ebp),%eax
  801076:	eb 13                	jmp    80108b <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801078:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80107c:	8b 45 08             	mov    0x8(%ebp),%eax
  80107f:	0f b6 00             	movzbl (%eax),%eax
  801082:	84 c0                	test   %al,%al
  801084:	75 e2                	jne    801068 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  801086:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	83 ec 04             	sub    $0x4,%esp
  801093:	8b 45 0c             	mov    0xc(%ebp),%eax
  801096:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  801099:	eb 11                	jmp    8010ac <strfind+0x1f>
		if (*s == c)
  80109b:	8b 45 08             	mov    0x8(%ebp),%eax
  80109e:	0f b6 00             	movzbl (%eax),%eax
  8010a1:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8010a4:	75 02                	jne    8010a8 <strfind+0x1b>
			break;
  8010a6:	eb 0e                	jmp    8010b6 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8010a8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8010af:	0f b6 00             	movzbl (%eax),%eax
  8010b2:	84 c0                	test   %al,%al
  8010b4:	75 e5                	jne    80109b <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  8010b6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8010b9:	c9                   	leave  
  8010ba:	c3                   	ret    

008010bb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	57                   	push   %edi
	char *p;

	if (n == 0)
  8010bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010c3:	75 05                	jne    8010ca <memset+0xf>
		return v;
  8010c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c8:	eb 5c                	jmp    801126 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  8010ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cd:	83 e0 03             	and    $0x3,%eax
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	75 41                	jne    801115 <memset+0x5a>
  8010d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d7:	83 e0 03             	and    $0x3,%eax
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	75 37                	jne    801115 <memset+0x5a>
		c &= 0xFF;
  8010de:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8010e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e8:	c1 e0 18             	shl    $0x18,%eax
  8010eb:	89 c2                	mov    %eax,%edx
  8010ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f0:	c1 e0 10             	shl    $0x10,%eax
  8010f3:	09 c2                	or     %eax,%edx
  8010f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f8:	c1 e0 08             	shl    $0x8,%eax
  8010fb:	09 d0                	or     %edx,%eax
  8010fd:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801100:	8b 45 10             	mov    0x10(%ebp),%eax
  801103:	c1 e8 02             	shr    $0x2,%eax
  801106:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801108:	8b 55 08             	mov    0x8(%ebp),%edx
  80110b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110e:	89 d7                	mov    %edx,%edi
  801110:	fc                   	cld    
  801111:	f3 ab                	rep stos %eax,%es:(%edi)
  801113:	eb 0e                	jmp    801123 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801115:	8b 55 08             	mov    0x8(%ebp),%edx
  801118:	8b 45 0c             	mov    0xc(%ebp),%eax
  80111b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80111e:	89 d7                	mov    %edx,%edi
  801120:	fc                   	cld    
  801121:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  801123:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801126:	5f                   	pop    %edi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	57                   	push   %edi
  80112d:	56                   	push   %esi
  80112e:	53                   	push   %ebx
  80112f:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  801132:	8b 45 0c             	mov    0xc(%ebp),%eax
  801135:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  801138:	8b 45 08             	mov    0x8(%ebp),%eax
  80113b:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  80113e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801141:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  801144:	73 6d                	jae    8011b3 <memmove+0x8a>
  801146:	8b 45 10             	mov    0x10(%ebp),%eax
  801149:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80114c:	01 d0                	add    %edx,%eax
  80114e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  801151:	76 60                	jbe    8011b3 <memmove+0x8a>
		s += n;
  801153:	8b 45 10             	mov    0x10(%ebp),%eax
  801156:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  801159:	8b 45 10             	mov    0x10(%ebp),%eax
  80115c:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80115f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801162:	83 e0 03             	and    $0x3,%eax
  801165:	85 c0                	test   %eax,%eax
  801167:	75 2f                	jne    801198 <memmove+0x6f>
  801169:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80116c:	83 e0 03             	and    $0x3,%eax
  80116f:	85 c0                	test   %eax,%eax
  801171:	75 25                	jne    801198 <memmove+0x6f>
  801173:	8b 45 10             	mov    0x10(%ebp),%eax
  801176:	83 e0 03             	and    $0x3,%eax
  801179:	85 c0                	test   %eax,%eax
  80117b:	75 1b                	jne    801198 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80117d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801180:	83 e8 04             	sub    $0x4,%eax
  801183:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801186:	83 ea 04             	sub    $0x4,%edx
  801189:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80118c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80118f:	89 c7                	mov    %eax,%edi
  801191:	89 d6                	mov    %edx,%esi
  801193:	fd                   	std    
  801194:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801196:	eb 18                	jmp    8011b0 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801198:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80119b:	8d 50 ff             	lea    -0x1(%eax),%edx
  80119e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a1:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8011a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a7:	89 d7                	mov    %edx,%edi
  8011a9:	89 de                	mov    %ebx,%esi
  8011ab:	89 c1                	mov    %eax,%ecx
  8011ad:	fd                   	std    
  8011ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8011b0:	fc                   	cld    
  8011b1:	eb 45                	jmp    8011f8 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8011b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b6:	83 e0 03             	and    $0x3,%eax
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	75 2b                	jne    8011e8 <memmove+0xbf>
  8011bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011c0:	83 e0 03             	and    $0x3,%eax
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	75 21                	jne    8011e8 <memmove+0xbf>
  8011c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ca:	83 e0 03             	and    $0x3,%eax
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	75 17                	jne    8011e8 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8011d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d4:	c1 e8 02             	shr    $0x2,%eax
  8011d7:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8011d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011df:	89 c7                	mov    %eax,%edi
  8011e1:	89 d6                	mov    %edx,%esi
  8011e3:	fc                   	cld    
  8011e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8011e6:	eb 10                	jmp    8011f8 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8011e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011f1:	89 c7                	mov    %eax,%edi
  8011f3:	89 d6                	mov    %edx,%esi
  8011f5:	fc                   	cld    
  8011f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  8011f8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8011fb:	83 c4 10             	add    $0x10,%esp
  8011fe:	5b                   	pop    %ebx
  8011ff:	5e                   	pop    %esi
  801200:	5f                   	pop    %edi
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801209:	8b 45 10             	mov    0x10(%ebp),%eax
  80120c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801210:	8b 45 0c             	mov    0xc(%ebp),%eax
  801213:	89 44 24 04          	mov    %eax,0x4(%esp)
  801217:	8b 45 08             	mov    0x8(%ebp),%eax
  80121a:	89 04 24             	mov    %eax,(%esp)
  80121d:	e8 07 ff ff ff       	call   801129 <memmove>
}
  801222:	c9                   	leave  
  801223:	c3                   	ret    

00801224 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  80122a:	8b 45 08             	mov    0x8(%ebp),%eax
  80122d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  801230:	8b 45 0c             	mov    0xc(%ebp),%eax
  801233:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  801236:	eb 30                	jmp    801268 <memcmp+0x44>
		if (*s1 != *s2)
  801238:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80123b:	0f b6 10             	movzbl (%eax),%edx
  80123e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801241:	0f b6 00             	movzbl (%eax),%eax
  801244:	38 c2                	cmp    %al,%dl
  801246:	74 18                	je     801260 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  801248:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80124b:	0f b6 00             	movzbl (%eax),%eax
  80124e:	0f b6 d0             	movzbl %al,%edx
  801251:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801254:	0f b6 00             	movzbl (%eax),%eax
  801257:	0f b6 c0             	movzbl %al,%eax
  80125a:	29 c2                	sub    %eax,%edx
  80125c:	89 d0                	mov    %edx,%eax
  80125e:	eb 1a                	jmp    80127a <memcmp+0x56>
		s1++, s2++;
  801260:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801264:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801268:	8b 45 10             	mov    0x10(%ebp),%eax
  80126b:	8d 50 ff             	lea    -0x1(%eax),%edx
  80126e:	89 55 10             	mov    %edx,0x10(%ebp)
  801271:	85 c0                	test   %eax,%eax
  801273:	75 c3                	jne    801238 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    

0080127c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801282:	8b 45 10             	mov    0x10(%ebp),%eax
  801285:	8b 55 08             	mov    0x8(%ebp),%edx
  801288:	01 d0                	add    %edx,%eax
  80128a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  80128d:	eb 13                	jmp    8012a2 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  80128f:	8b 45 08             	mov    0x8(%ebp),%eax
  801292:	0f b6 10             	movzbl (%eax),%edx
  801295:	8b 45 0c             	mov    0xc(%ebp),%eax
  801298:	38 c2                	cmp    %al,%dl
  80129a:	75 02                	jne    80129e <memfind+0x22>
			break;
  80129c:	eb 0c                	jmp    8012aa <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80129e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8012a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  8012a8:	72 e5                	jb     80128f <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  8012aa:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8012ad:	c9                   	leave  
  8012ae:	c3                   	ret    

008012af <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  8012b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  8012bc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012c3:	eb 04                	jmp    8012c9 <strtol+0x1a>
		s++;
  8012c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cc:	0f b6 00             	movzbl (%eax),%eax
  8012cf:	3c 20                	cmp    $0x20,%al
  8012d1:	74 f2                	je     8012c5 <strtol+0x16>
  8012d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d6:	0f b6 00             	movzbl (%eax),%eax
  8012d9:	3c 09                	cmp    $0x9,%al
  8012db:	74 e8                	je     8012c5 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  8012dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e0:	0f b6 00             	movzbl (%eax),%eax
  8012e3:	3c 2b                	cmp    $0x2b,%al
  8012e5:	75 06                	jne    8012ed <strtol+0x3e>
		s++;
  8012e7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8012eb:	eb 15                	jmp    801302 <strtol+0x53>
	else if (*s == '-')
  8012ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f0:	0f b6 00             	movzbl (%eax),%eax
  8012f3:	3c 2d                	cmp    $0x2d,%al
  8012f5:	75 0b                	jne    801302 <strtol+0x53>
		s++, neg = 1;
  8012f7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8012fb:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801302:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801306:	74 06                	je     80130e <strtol+0x5f>
  801308:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  80130c:	75 24                	jne    801332 <strtol+0x83>
  80130e:	8b 45 08             	mov    0x8(%ebp),%eax
  801311:	0f b6 00             	movzbl (%eax),%eax
  801314:	3c 30                	cmp    $0x30,%al
  801316:	75 1a                	jne    801332 <strtol+0x83>
  801318:	8b 45 08             	mov    0x8(%ebp),%eax
  80131b:	83 c0 01             	add    $0x1,%eax
  80131e:	0f b6 00             	movzbl (%eax),%eax
  801321:	3c 78                	cmp    $0x78,%al
  801323:	75 0d                	jne    801332 <strtol+0x83>
		s += 2, base = 16;
  801325:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801329:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801330:	eb 2a                	jmp    80135c <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  801332:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801336:	75 17                	jne    80134f <strtol+0xa0>
  801338:	8b 45 08             	mov    0x8(%ebp),%eax
  80133b:	0f b6 00             	movzbl (%eax),%eax
  80133e:	3c 30                	cmp    $0x30,%al
  801340:	75 0d                	jne    80134f <strtol+0xa0>
		s++, base = 8;
  801342:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801346:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  80134d:	eb 0d                	jmp    80135c <strtol+0xad>
	else if (base == 0)
  80134f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801353:	75 07                	jne    80135c <strtol+0xad>
		base = 10;
  801355:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80135c:	8b 45 08             	mov    0x8(%ebp),%eax
  80135f:	0f b6 00             	movzbl (%eax),%eax
  801362:	3c 2f                	cmp    $0x2f,%al
  801364:	7e 1b                	jle    801381 <strtol+0xd2>
  801366:	8b 45 08             	mov    0x8(%ebp),%eax
  801369:	0f b6 00             	movzbl (%eax),%eax
  80136c:	3c 39                	cmp    $0x39,%al
  80136e:	7f 11                	jg     801381 <strtol+0xd2>
			dig = *s - '0';
  801370:	8b 45 08             	mov    0x8(%ebp),%eax
  801373:	0f b6 00             	movzbl (%eax),%eax
  801376:	0f be c0             	movsbl %al,%eax
  801379:	83 e8 30             	sub    $0x30,%eax
  80137c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80137f:	eb 48                	jmp    8013c9 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801381:	8b 45 08             	mov    0x8(%ebp),%eax
  801384:	0f b6 00             	movzbl (%eax),%eax
  801387:	3c 60                	cmp    $0x60,%al
  801389:	7e 1b                	jle    8013a6 <strtol+0xf7>
  80138b:	8b 45 08             	mov    0x8(%ebp),%eax
  80138e:	0f b6 00             	movzbl (%eax),%eax
  801391:	3c 7a                	cmp    $0x7a,%al
  801393:	7f 11                	jg     8013a6 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801395:	8b 45 08             	mov    0x8(%ebp),%eax
  801398:	0f b6 00             	movzbl (%eax),%eax
  80139b:	0f be c0             	movsbl %al,%eax
  80139e:	83 e8 57             	sub    $0x57,%eax
  8013a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8013a4:	eb 23                	jmp    8013c9 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  8013a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a9:	0f b6 00             	movzbl (%eax),%eax
  8013ac:	3c 40                	cmp    $0x40,%al
  8013ae:	7e 3d                	jle    8013ed <strtol+0x13e>
  8013b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b3:	0f b6 00             	movzbl (%eax),%eax
  8013b6:	3c 5a                	cmp    $0x5a,%al
  8013b8:	7f 33                	jg     8013ed <strtol+0x13e>
			dig = *s - 'A' + 10;
  8013ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bd:	0f b6 00             	movzbl (%eax),%eax
  8013c0:	0f be c0             	movsbl %al,%eax
  8013c3:	83 e8 37             	sub    $0x37,%eax
  8013c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  8013c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cc:	3b 45 10             	cmp    0x10(%ebp),%eax
  8013cf:	7c 02                	jl     8013d3 <strtol+0x124>
			break;
  8013d1:	eb 1a                	jmp    8013ed <strtol+0x13e>
		s++, val = (val * base) + dig;
  8013d3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8013d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8013da:	0f af 45 10          	imul   0x10(%ebp),%eax
  8013de:	89 c2                	mov    %eax,%edx
  8013e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e3:	01 d0                	add    %edx,%eax
  8013e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8013e8:	e9 6f ff ff ff       	jmp    80135c <strtol+0xad>

	if (endptr)
  8013ed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013f1:	74 08                	je     8013fb <strtol+0x14c>
		*endptr = (char *) s;
  8013f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f9:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8013fb:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8013ff:	74 07                	je     801408 <strtol+0x159>
  801401:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801404:	f7 d8                	neg    %eax
  801406:	eb 03                	jmp    80140b <strtol+0x15c>
  801408:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80140b:	c9                   	leave  
  80140c:	c3                   	ret    

0080140d <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	57                   	push   %edi
  801411:	56                   	push   %esi
  801412:	53                   	push   %ebx
  801413:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801416:	8b 45 08             	mov    0x8(%ebp),%eax
  801419:	8b 55 10             	mov    0x10(%ebp),%edx
  80141c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80141f:	8b 5d 18             	mov    0x18(%ebp),%ebx
  801422:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  801425:	8b 75 20             	mov    0x20(%ebp),%esi
  801428:	cd 30                	int    $0x30
  80142a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80142d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801431:	74 30                	je     801463 <syscall+0x56>
  801433:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801437:	7e 2a                	jle    801463 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  801439:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80143c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801440:	8b 45 08             	mov    0x8(%ebp),%eax
  801443:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801447:	c7 44 24 08 64 1e 80 	movl   $0x801e64,0x8(%esp)
  80144e:	00 
  80144f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801456:	00 
  801457:	c7 04 24 81 1e 80 00 	movl   $0x801e81,(%esp)
  80145e:	e8 4b f2 ff ff       	call   8006ae <_panic>

	return ret;
  801463:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801466:	83 c4 3c             	add    $0x3c,%esp
  801469:	5b                   	pop    %ebx
  80146a:	5e                   	pop    %esi
  80146b:	5f                   	pop    %edi
  80146c:	5d                   	pop    %ebp
  80146d:	c3                   	ret    

0080146e <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  801474:	8b 45 08             	mov    0x8(%ebp),%eax
  801477:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80147e:	00 
  80147f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801486:	00 
  801487:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80148e:	00 
  80148f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801492:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801496:	89 44 24 08          	mov    %eax,0x8(%esp)
  80149a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014a1:	00 
  8014a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a9:	e8 5f ff ff ff       	call   80140d <syscall>
}
  8014ae:	c9                   	leave  
  8014af:	c3                   	ret    

008014b0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8014b6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8014bd:	00 
  8014be:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8014c5:	00 
  8014c6:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8014cd:	00 
  8014ce:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8014d5:	00 
  8014d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014dd:	00 
  8014de:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014e5:	00 
  8014e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014ed:	e8 1b ff ff ff       	call   80140d <syscall>
}
  8014f2:	c9                   	leave  
  8014f3:	c3                   	ret    

008014f4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8014fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fd:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801504:	00 
  801505:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80150c:	00 
  80150d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801514:	00 
  801515:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80151c:	00 
  80151d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801521:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801528:	00 
  801529:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801530:	e8 d8 fe ff ff       	call   80140d <syscall>
}
  801535:	c9                   	leave  
  801536:	c3                   	ret    

00801537 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80153d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801544:	00 
  801545:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80154c:	00 
  80154d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801554:	00 
  801555:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80155c:	00 
  80155d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801564:	00 
  801565:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80156c:	00 
  80156d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801574:	e8 94 fe ff ff       	call   80140d <syscall>
}
  801579:	c9                   	leave  
  80157a:	c3                   	ret    

0080157b <sys_yield>:

void
sys_yield(void)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801581:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801588:	00 
  801589:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801590:	00 
  801591:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801598:	00 
  801599:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8015a0:	00 
  8015a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015a8:	00 
  8015a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015b0:	00 
  8015b1:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8015b8:	e8 50 fe ff ff       	call   80140d <syscall>
}
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8015c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ce:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8015d5:	00 
  8015d6:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8015dd:	00 
  8015de:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8015e2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015ea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015f1:	00 
  8015f2:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8015f9:	e8 0f fe ff ff       	call   80140d <syscall>
}
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	56                   	push   %esi
  801604:	53                   	push   %ebx
  801605:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801608:	8b 75 18             	mov    0x18(%ebp),%esi
  80160b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80160e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801611:	8b 55 0c             	mov    0xc(%ebp),%edx
  801614:	8b 45 08             	mov    0x8(%ebp),%eax
  801617:	89 74 24 18          	mov    %esi,0x18(%esp)
  80161b:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80161f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801623:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801627:	89 44 24 08          	mov    %eax,0x8(%esp)
  80162b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801632:	00 
  801633:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  80163a:	e8 ce fd ff ff       	call   80140d <syscall>
}
  80163f:	83 c4 20             	add    $0x20,%esp
  801642:	5b                   	pop    %ebx
  801643:	5e                   	pop    %esi
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    

00801646 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80164c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80164f:	8b 45 08             	mov    0x8(%ebp),%eax
  801652:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801659:	00 
  80165a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801661:	00 
  801662:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801669:	00 
  80166a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80166e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801672:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801679:	00 
  80167a:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801681:	e8 87 fd ff ff       	call   80140d <syscall>
}
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80168e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801691:	8b 45 08             	mov    0x8(%ebp),%eax
  801694:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80169b:	00 
  80169c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8016a3:	00 
  8016a4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8016ab:	00 
  8016ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016b4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016bb:	00 
  8016bc:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8016c3:	e8 45 fd ff ff       	call   80140d <syscall>
}
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8016d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8016dd:	00 
  8016de:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8016e5:	00 
  8016e6:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8016ed:	00 
  8016ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016f6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016fd:	00 
  8016fe:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801705:	e8 03 fd ff ff       	call   80140d <syscall>
}
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    

0080170c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801712:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801715:	8b 55 10             	mov    0x10(%ebp),%edx
  801718:	8b 45 08             	mov    0x8(%ebp),%eax
  80171b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801722:	00 
  801723:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801727:	89 54 24 10          	mov    %edx,0x10(%esp)
  80172b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80172e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801732:	89 44 24 08          	mov    %eax,0x8(%esp)
  801736:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80173d:	00 
  80173e:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801745:	e8 c3 fc ff ff       	call   80140d <syscall>
}
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801752:	8b 45 08             	mov    0x8(%ebp),%eax
  801755:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80175c:	00 
  80175d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801764:	00 
  801765:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80176c:	00 
  80176d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801774:	00 
  801775:	89 44 24 08          	mov    %eax,0x8(%esp)
  801779:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801780:	00 
  801781:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801788:	e8 80 fc ff ff       	call   80140d <syscall>
}
  80178d:	c9                   	leave  
  80178e:	c3                   	ret    

0080178f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  801795:	a1 d0 20 80 00       	mov    0x8020d0,%eax
  80179a:	85 c0                	test   %eax,%eax
  80179c:	75 55                	jne    8017f3 <set_pgfault_handler+0x64>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE),PTE_U|PTE_P|PTE_W);
  80179e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8017a5:	00 
  8017a6:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8017ad:	ee 
  8017ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b5:	e8 05 fe ff ff       	call   8015bf <sys_page_alloc>
  8017ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(r < 0)
  8017bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8017c1:	79 1c                	jns    8017df <set_pgfault_handler+0x50>
		{
			panic("sys_page_alloc_failed");
  8017c3:	c7 44 24 08 8f 1e 80 	movl   $0x801e8f,0x8(%esp)
  8017ca:	00 
  8017cb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8017d2:	00 
  8017d3:	c7 04 24 a5 1e 80 00 	movl   $0x801ea5,(%esp)
  8017da:	e8 cf ee ff ff       	call   8006ae <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8017df:	c7 44 24 04 fd 17 80 	movl   $0x8017fd,0x4(%esp)
  8017e6:	00 
  8017e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017ee:	e8 d7 fe ff ff       	call   8016ca <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f6:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  8017fb:	c9                   	leave  
  8017fc:	c3                   	ret    

008017fd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8017fd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8017fe:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  801803:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801805:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  801808:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  80180c:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80180f:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 0x28(%esp), %ecx
  801813:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  801817:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//add $8, %esp
	popl %edx 
  801819:	5a                   	pop    %edx
	popl %edx
  80181a:	5a                   	pop    %edx
	popal
  80181b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  80181c:	83 c4 04             	add    $0x4,%esp
	popf
  80181f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801820:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801821:	c3                   	ret    
  801822:	66 90                	xchg   %ax,%ax
  801824:	66 90                	xchg   %ax,%ax
  801826:	66 90                	xchg   %ax,%ax
  801828:	66 90                	xchg   %ax,%ax
  80182a:	66 90                	xchg   %ax,%ax
  80182c:	66 90                	xchg   %ax,%ax
  80182e:	66 90                	xchg   %ax,%ax

00801830 <__udivdi3>:
  801830:	55                   	push   %ebp
  801831:	57                   	push   %edi
  801832:	56                   	push   %esi
  801833:	83 ec 0c             	sub    $0xc,%esp
  801836:	8b 44 24 28          	mov    0x28(%esp),%eax
  80183a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80183e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801842:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801846:	85 c0                	test   %eax,%eax
  801848:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80184c:	89 ea                	mov    %ebp,%edx
  80184e:	89 0c 24             	mov    %ecx,(%esp)
  801851:	75 2d                	jne    801880 <__udivdi3+0x50>
  801853:	39 e9                	cmp    %ebp,%ecx
  801855:	77 61                	ja     8018b8 <__udivdi3+0x88>
  801857:	85 c9                	test   %ecx,%ecx
  801859:	89 ce                	mov    %ecx,%esi
  80185b:	75 0b                	jne    801868 <__udivdi3+0x38>
  80185d:	b8 01 00 00 00       	mov    $0x1,%eax
  801862:	31 d2                	xor    %edx,%edx
  801864:	f7 f1                	div    %ecx
  801866:	89 c6                	mov    %eax,%esi
  801868:	31 d2                	xor    %edx,%edx
  80186a:	89 e8                	mov    %ebp,%eax
  80186c:	f7 f6                	div    %esi
  80186e:	89 c5                	mov    %eax,%ebp
  801870:	89 f8                	mov    %edi,%eax
  801872:	f7 f6                	div    %esi
  801874:	89 ea                	mov    %ebp,%edx
  801876:	83 c4 0c             	add    $0xc,%esp
  801879:	5e                   	pop    %esi
  80187a:	5f                   	pop    %edi
  80187b:	5d                   	pop    %ebp
  80187c:	c3                   	ret    
  80187d:	8d 76 00             	lea    0x0(%esi),%esi
  801880:	39 e8                	cmp    %ebp,%eax
  801882:	77 24                	ja     8018a8 <__udivdi3+0x78>
  801884:	0f bd e8             	bsr    %eax,%ebp
  801887:	83 f5 1f             	xor    $0x1f,%ebp
  80188a:	75 3c                	jne    8018c8 <__udivdi3+0x98>
  80188c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801890:	39 34 24             	cmp    %esi,(%esp)
  801893:	0f 86 9f 00 00 00    	jbe    801938 <__udivdi3+0x108>
  801899:	39 d0                	cmp    %edx,%eax
  80189b:	0f 82 97 00 00 00    	jb     801938 <__udivdi3+0x108>
  8018a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8018a8:	31 d2                	xor    %edx,%edx
  8018aa:	31 c0                	xor    %eax,%eax
  8018ac:	83 c4 0c             	add    $0xc,%esp
  8018af:	5e                   	pop    %esi
  8018b0:	5f                   	pop    %edi
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    
  8018b3:	90                   	nop
  8018b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8018b8:	89 f8                	mov    %edi,%eax
  8018ba:	f7 f1                	div    %ecx
  8018bc:	31 d2                	xor    %edx,%edx
  8018be:	83 c4 0c             	add    $0xc,%esp
  8018c1:	5e                   	pop    %esi
  8018c2:	5f                   	pop    %edi
  8018c3:	5d                   	pop    %ebp
  8018c4:	c3                   	ret    
  8018c5:	8d 76 00             	lea    0x0(%esi),%esi
  8018c8:	89 e9                	mov    %ebp,%ecx
  8018ca:	8b 3c 24             	mov    (%esp),%edi
  8018cd:	d3 e0                	shl    %cl,%eax
  8018cf:	89 c6                	mov    %eax,%esi
  8018d1:	b8 20 00 00 00       	mov    $0x20,%eax
  8018d6:	29 e8                	sub    %ebp,%eax
  8018d8:	89 c1                	mov    %eax,%ecx
  8018da:	d3 ef                	shr    %cl,%edi
  8018dc:	89 e9                	mov    %ebp,%ecx
  8018de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8018e2:	8b 3c 24             	mov    (%esp),%edi
  8018e5:	09 74 24 08          	or     %esi,0x8(%esp)
  8018e9:	89 d6                	mov    %edx,%esi
  8018eb:	d3 e7                	shl    %cl,%edi
  8018ed:	89 c1                	mov    %eax,%ecx
  8018ef:	89 3c 24             	mov    %edi,(%esp)
  8018f2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018f6:	d3 ee                	shr    %cl,%esi
  8018f8:	89 e9                	mov    %ebp,%ecx
  8018fa:	d3 e2                	shl    %cl,%edx
  8018fc:	89 c1                	mov    %eax,%ecx
  8018fe:	d3 ef                	shr    %cl,%edi
  801900:	09 d7                	or     %edx,%edi
  801902:	89 f2                	mov    %esi,%edx
  801904:	89 f8                	mov    %edi,%eax
  801906:	f7 74 24 08          	divl   0x8(%esp)
  80190a:	89 d6                	mov    %edx,%esi
  80190c:	89 c7                	mov    %eax,%edi
  80190e:	f7 24 24             	mull   (%esp)
  801911:	39 d6                	cmp    %edx,%esi
  801913:	89 14 24             	mov    %edx,(%esp)
  801916:	72 30                	jb     801948 <__udivdi3+0x118>
  801918:	8b 54 24 04          	mov    0x4(%esp),%edx
  80191c:	89 e9                	mov    %ebp,%ecx
  80191e:	d3 e2                	shl    %cl,%edx
  801920:	39 c2                	cmp    %eax,%edx
  801922:	73 05                	jae    801929 <__udivdi3+0xf9>
  801924:	3b 34 24             	cmp    (%esp),%esi
  801927:	74 1f                	je     801948 <__udivdi3+0x118>
  801929:	89 f8                	mov    %edi,%eax
  80192b:	31 d2                	xor    %edx,%edx
  80192d:	e9 7a ff ff ff       	jmp    8018ac <__udivdi3+0x7c>
  801932:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801938:	31 d2                	xor    %edx,%edx
  80193a:	b8 01 00 00 00       	mov    $0x1,%eax
  80193f:	e9 68 ff ff ff       	jmp    8018ac <__udivdi3+0x7c>
  801944:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801948:	8d 47 ff             	lea    -0x1(%edi),%eax
  80194b:	31 d2                	xor    %edx,%edx
  80194d:	83 c4 0c             	add    $0xc,%esp
  801950:	5e                   	pop    %esi
  801951:	5f                   	pop    %edi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    
  801954:	66 90                	xchg   %ax,%ax
  801956:	66 90                	xchg   %ax,%ax
  801958:	66 90                	xchg   %ax,%ax
  80195a:	66 90                	xchg   %ax,%ax
  80195c:	66 90                	xchg   %ax,%ax
  80195e:	66 90                	xchg   %ax,%ax

00801960 <__umoddi3>:
  801960:	55                   	push   %ebp
  801961:	57                   	push   %edi
  801962:	56                   	push   %esi
  801963:	83 ec 14             	sub    $0x14,%esp
  801966:	8b 44 24 28          	mov    0x28(%esp),%eax
  80196a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80196e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801972:	89 c7                	mov    %eax,%edi
  801974:	89 44 24 04          	mov    %eax,0x4(%esp)
  801978:	8b 44 24 30          	mov    0x30(%esp),%eax
  80197c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801980:	89 34 24             	mov    %esi,(%esp)
  801983:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801987:	85 c0                	test   %eax,%eax
  801989:	89 c2                	mov    %eax,%edx
  80198b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80198f:	75 17                	jne    8019a8 <__umoddi3+0x48>
  801991:	39 fe                	cmp    %edi,%esi
  801993:	76 4b                	jbe    8019e0 <__umoddi3+0x80>
  801995:	89 c8                	mov    %ecx,%eax
  801997:	89 fa                	mov    %edi,%edx
  801999:	f7 f6                	div    %esi
  80199b:	89 d0                	mov    %edx,%eax
  80199d:	31 d2                	xor    %edx,%edx
  80199f:	83 c4 14             	add    $0x14,%esp
  8019a2:	5e                   	pop    %esi
  8019a3:	5f                   	pop    %edi
  8019a4:	5d                   	pop    %ebp
  8019a5:	c3                   	ret    
  8019a6:	66 90                	xchg   %ax,%ax
  8019a8:	39 f8                	cmp    %edi,%eax
  8019aa:	77 54                	ja     801a00 <__umoddi3+0xa0>
  8019ac:	0f bd e8             	bsr    %eax,%ebp
  8019af:	83 f5 1f             	xor    $0x1f,%ebp
  8019b2:	75 5c                	jne    801a10 <__umoddi3+0xb0>
  8019b4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8019b8:	39 3c 24             	cmp    %edi,(%esp)
  8019bb:	0f 87 e7 00 00 00    	ja     801aa8 <__umoddi3+0x148>
  8019c1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8019c5:	29 f1                	sub    %esi,%ecx
  8019c7:	19 c7                	sbb    %eax,%edi
  8019c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019cd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019d1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8019d5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8019d9:	83 c4 14             	add    $0x14,%esp
  8019dc:	5e                   	pop    %esi
  8019dd:	5f                   	pop    %edi
  8019de:	5d                   	pop    %ebp
  8019df:	c3                   	ret    
  8019e0:	85 f6                	test   %esi,%esi
  8019e2:	89 f5                	mov    %esi,%ebp
  8019e4:	75 0b                	jne    8019f1 <__umoddi3+0x91>
  8019e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019eb:	31 d2                	xor    %edx,%edx
  8019ed:	f7 f6                	div    %esi
  8019ef:	89 c5                	mov    %eax,%ebp
  8019f1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8019f5:	31 d2                	xor    %edx,%edx
  8019f7:	f7 f5                	div    %ebp
  8019f9:	89 c8                	mov    %ecx,%eax
  8019fb:	f7 f5                	div    %ebp
  8019fd:	eb 9c                	jmp    80199b <__umoddi3+0x3b>
  8019ff:	90                   	nop
  801a00:	89 c8                	mov    %ecx,%eax
  801a02:	89 fa                	mov    %edi,%edx
  801a04:	83 c4 14             	add    $0x14,%esp
  801a07:	5e                   	pop    %esi
  801a08:	5f                   	pop    %edi
  801a09:	5d                   	pop    %ebp
  801a0a:	c3                   	ret    
  801a0b:	90                   	nop
  801a0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a10:	8b 04 24             	mov    (%esp),%eax
  801a13:	be 20 00 00 00       	mov    $0x20,%esi
  801a18:	89 e9                	mov    %ebp,%ecx
  801a1a:	29 ee                	sub    %ebp,%esi
  801a1c:	d3 e2                	shl    %cl,%edx
  801a1e:	89 f1                	mov    %esi,%ecx
  801a20:	d3 e8                	shr    %cl,%eax
  801a22:	89 e9                	mov    %ebp,%ecx
  801a24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a28:	8b 04 24             	mov    (%esp),%eax
  801a2b:	09 54 24 04          	or     %edx,0x4(%esp)
  801a2f:	89 fa                	mov    %edi,%edx
  801a31:	d3 e0                	shl    %cl,%eax
  801a33:	89 f1                	mov    %esi,%ecx
  801a35:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a39:	8b 44 24 10          	mov    0x10(%esp),%eax
  801a3d:	d3 ea                	shr    %cl,%edx
  801a3f:	89 e9                	mov    %ebp,%ecx
  801a41:	d3 e7                	shl    %cl,%edi
  801a43:	89 f1                	mov    %esi,%ecx
  801a45:	d3 e8                	shr    %cl,%eax
  801a47:	89 e9                	mov    %ebp,%ecx
  801a49:	09 f8                	or     %edi,%eax
  801a4b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801a4f:	f7 74 24 04          	divl   0x4(%esp)
  801a53:	d3 e7                	shl    %cl,%edi
  801a55:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a59:	89 d7                	mov    %edx,%edi
  801a5b:	f7 64 24 08          	mull   0x8(%esp)
  801a5f:	39 d7                	cmp    %edx,%edi
  801a61:	89 c1                	mov    %eax,%ecx
  801a63:	89 14 24             	mov    %edx,(%esp)
  801a66:	72 2c                	jb     801a94 <__umoddi3+0x134>
  801a68:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801a6c:	72 22                	jb     801a90 <__umoddi3+0x130>
  801a6e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801a72:	29 c8                	sub    %ecx,%eax
  801a74:	19 d7                	sbb    %edx,%edi
  801a76:	89 e9                	mov    %ebp,%ecx
  801a78:	89 fa                	mov    %edi,%edx
  801a7a:	d3 e8                	shr    %cl,%eax
  801a7c:	89 f1                	mov    %esi,%ecx
  801a7e:	d3 e2                	shl    %cl,%edx
  801a80:	89 e9                	mov    %ebp,%ecx
  801a82:	d3 ef                	shr    %cl,%edi
  801a84:	09 d0                	or     %edx,%eax
  801a86:	89 fa                	mov    %edi,%edx
  801a88:	83 c4 14             	add    $0x14,%esp
  801a8b:	5e                   	pop    %esi
  801a8c:	5f                   	pop    %edi
  801a8d:	5d                   	pop    %ebp
  801a8e:	c3                   	ret    
  801a8f:	90                   	nop
  801a90:	39 d7                	cmp    %edx,%edi
  801a92:	75 da                	jne    801a6e <__umoddi3+0x10e>
  801a94:	8b 14 24             	mov    (%esp),%edx
  801a97:	89 c1                	mov    %eax,%ecx
  801a99:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801a9d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801aa1:	eb cb                	jmp    801a6e <__umoddi3+0x10e>
  801aa3:	90                   	nop
  801aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801aa8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801aac:	0f 82 0f ff ff ff    	jb     8019c1 <__umoddi3+0x61>
  801ab2:	e9 1a ff ff ff       	jmp    8019d1 <__umoddi3+0x71>
