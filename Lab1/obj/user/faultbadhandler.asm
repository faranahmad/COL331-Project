
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 45 00 00 00       	call   800076 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800040:	00 
  800041:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800048:	ee 
  800049:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800050:	e8 35 02 00 00       	call   80028a <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800055:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005c:	de 
  80005d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800064:	e8 2c 03 00 00       	call   800395 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800069:	b8 00 00 00 00       	mov    $0x0,%eax
  80006e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    

00800076 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800076:	55                   	push   %ebp
  800077:	89 e5                	mov    %esp,%ebp
  800079:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80007c:	e8 81 01 00 00       	call   800202 <sys_getenvid>
  800081:	25 ff 03 00 00       	and    $0x3ff,%eax
  800086:	c1 e0 02             	shl    $0x2,%eax
  800089:	89 c2                	mov    %eax,%edx
  80008b:	c1 e2 05             	shl    $0x5,%edx
  80008e:	29 c2                	sub    %eax,%edx
  800090:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  800096:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80009f:	7e 0a                	jle    8000ab <libmain+0x35>
		binaryname = argv[0];
  8000a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000a4:	8b 00                	mov    (%eax),%eax
  8000a6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8000b5:	89 04 24             	mov    %eax,(%esp)
  8000b8:	e8 76 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000bd:	e8 02 00 00 00       	call   8000c4 <exit>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d1:	e8 e9 00 00 00       	call   8001bf <sys_env_destroy>
}
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	57                   	push   %edi
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
  8000de:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e4:	8b 55 10             	mov    0x10(%ebp),%edx
  8000e7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000ea:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000ed:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000f0:	8b 75 20             	mov    0x20(%ebp),%esi
  8000f3:	cd 30                	int    $0x30
  8000f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000fc:	74 30                	je     80012e <syscall+0x56>
  8000fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800102:	7e 2a                	jle    80012e <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800104:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800107:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010b:	8b 45 08             	mov    0x8(%ebp),%eax
  80010e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800112:	c7 44 24 08 6a 14 80 	movl   $0x80146a,0x8(%esp)
  800119:	00 
  80011a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800121:	00 
  800122:	c7 04 24 87 14 80 00 	movl   $0x801487,(%esp)
  800129:	e8 2c 03 00 00       	call   80045a <_panic>

	return ret;
  80012e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800131:	83 c4 3c             	add    $0x3c,%esp
  800134:	5b                   	pop    %ebx
  800135:	5e                   	pop    %esi
  800136:	5f                   	pop    %edi
  800137:	5d                   	pop    %ebp
  800138:	c3                   	ret    

00800139 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80013f:	8b 45 08             	mov    0x8(%ebp),%eax
  800142:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800149:	00 
  80014a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800151:	00 
  800152:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800159:	00 
  80015a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80015d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800161:	89 44 24 08          	mov    %eax,0x8(%esp)
  800165:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80016c:	00 
  80016d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800174:	e8 5f ff ff ff       	call   8000d8 <syscall>
}
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <sys_cgetc>:

int
sys_cgetc(void)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800181:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800188:	00 
  800189:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800190:	00 
  800191:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800198:	00 
  800199:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001a0:	00 
  8001a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001a8:	00 
  8001a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001b0:	00 
  8001b1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001b8:	e8 1b ff ff ff       	call   8000d8 <syscall>
}
  8001bd:	c9                   	leave  
  8001be:	c3                   	ret    

008001bf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8001c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001cf:	00 
  8001d0:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001df:	00 
  8001e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001e7:	00 
  8001e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ec:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001f3:	00 
  8001f4:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001fb:	e8 d8 fe ff ff       	call   8000d8 <syscall>
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800208:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80020f:	00 
  800210:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800217:	00 
  800218:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80021f:	00 
  800220:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800227:	00 
  800228:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80022f:	00 
  800230:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800237:	00 
  800238:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80023f:	e8 94 fe ff ff       	call   8000d8 <syscall>
}
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <sys_yield>:

void
sys_yield(void)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80024c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800253:	00 
  800254:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80025b:	00 
  80025c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800263:	00 
  800264:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026b:	00 
  80026c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800273:	00 
  800274:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80027b:	00 
  80027c:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800283:	e8 50 fe ff ff       	call   8000d8 <syscall>
}
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800290:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800293:	8b 55 0c             	mov    0xc(%ebp),%edx
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002a0:	00 
  8002a1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002a8:	00 
  8002a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002bc:	00 
  8002bd:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8002c4:	e8 0f fe ff ff       	call   8000d8 <syscall>
}
  8002c9:	c9                   	leave  
  8002ca:	c3                   	ret    

008002cb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8002d3:	8b 75 18             	mov    0x18(%ebp),%esi
  8002d6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002e6:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002ea:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002fd:	00 
  8002fe:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800305:	e8 ce fd ff ff       	call   8000d8 <syscall>
}
  80030a:	83 c4 20             	add    $0x20,%esp
  80030d:	5b                   	pop    %ebx
  80030e:	5e                   	pop    %esi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800317:	8b 55 0c             	mov    0xc(%ebp),%edx
  80031a:	8b 45 08             	mov    0x8(%ebp),%eax
  80031d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800324:	00 
  800325:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80032c:	00 
  80032d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800334:	00 
  800335:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800339:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800344:	00 
  800345:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80034c:	e8 87 fd ff ff       	call   8000d8 <syscall>
}
  800351:	c9                   	leave  
  800352:	c3                   	ret    

00800353 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800359:	8b 55 0c             	mov    0xc(%ebp),%edx
  80035c:	8b 45 08             	mov    0x8(%ebp),%eax
  80035f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800366:	00 
  800367:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80036e:	00 
  80036f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800376:	00 
  800377:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80037b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800386:	00 
  800387:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80038e:	e8 45 fd ff ff       	call   8000d8 <syscall>
}
  800393:	c9                   	leave  
  800394:	c3                   	ret    

00800395 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80039b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80039e:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003a8:	00 
  8003a9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003b0:	00 
  8003b1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8003b8:	00 
  8003b9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8003c8:	00 
  8003c9:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8003d0:	e8 03 fd ff ff       	call   8000d8 <syscall>
}
  8003d5:	c9                   	leave  
  8003d6:	c3                   	ret    

008003d7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003dd:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003e0:	8b 55 10             	mov    0x10(%ebp),%edx
  8003e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003ed:	00 
  8003ee:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003f2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800401:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800408:	00 
  800409:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  800410:	e8 c3 fc ff ff       	call   8000d8 <syscall>
}
  800415:	c9                   	leave  
  800416:	c3                   	ret    

00800417 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80041d:	8b 45 08             	mov    0x8(%ebp),%eax
  800420:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800427:	00 
  800428:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80042f:	00 
  800430:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800437:	00 
  800438:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80043f:	00 
  800440:	89 44 24 08          	mov    %eax,0x8(%esp)
  800444:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80044b:	00 
  80044c:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800453:	e8 80 fc ff ff       	call   8000d8 <syscall>
}
  800458:	c9                   	leave  
  800459:	c3                   	ret    

0080045a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
  80045d:	53                   	push   %ebx
  80045e:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800461:	8d 45 14             	lea    0x14(%ebp),%eax
  800464:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800467:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80046d:	e8 90 fd ff ff       	call   800202 <sys_getenvid>
  800472:	8b 55 0c             	mov    0xc(%ebp),%edx
  800475:	89 54 24 10          	mov    %edx,0x10(%esp)
  800479:	8b 55 08             	mov    0x8(%ebp),%edx
  80047c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800480:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800484:	89 44 24 04          	mov    %eax,0x4(%esp)
  800488:	c7 04 24 98 14 80 00 	movl   $0x801498,(%esp)
  80048f:	e8 e1 00 00 00       	call   800575 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800494:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049b:	8b 45 10             	mov    0x10(%ebp),%eax
  80049e:	89 04 24             	mov    %eax,(%esp)
  8004a1:	e8 6b 00 00 00       	call   800511 <vcprintf>
	cprintf("\n");
  8004a6:	c7 04 24 bb 14 80 00 	movl   $0x8014bb,(%esp)
  8004ad:	e8 c3 00 00 00       	call   800575 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004b2:	cc                   	int3   
  8004b3:	eb fd                	jmp    8004b2 <_panic+0x58>

008004b5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004b5:	55                   	push   %ebp
  8004b6:	89 e5                	mov    %esp,%ebp
  8004b8:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8004bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004be:	8b 00                	mov    (%eax),%eax
  8004c0:	8d 48 01             	lea    0x1(%eax),%ecx
  8004c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c6:	89 0a                	mov    %ecx,(%edx)
  8004c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cb:	89 d1                	mov    %edx,%ecx
  8004cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d0:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d7:	8b 00                	mov    (%eax),%eax
  8004d9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004de:	75 20                	jne    800500 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e3:	8b 00                	mov    (%eax),%eax
  8004e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e8:	83 c2 08             	add    $0x8,%edx
  8004eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ef:	89 14 24             	mov    %edx,(%esp)
  8004f2:	e8 42 fc ff ff       	call   800139 <sys_cputs>
		b->idx = 0;
  8004f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800500:	8b 45 0c             	mov    0xc(%ebp),%eax
  800503:	8b 40 04             	mov    0x4(%eax),%eax
  800506:	8d 50 01             	lea    0x1(%eax),%edx
  800509:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050c:	89 50 04             	mov    %edx,0x4(%eax)
}
  80050f:	c9                   	leave  
  800510:	c3                   	ret    

00800511 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80051a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800521:	00 00 00 
	b.cnt = 0;
  800524:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80052b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80052e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800531:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800535:	8b 45 08             	mov    0x8(%ebp),%eax
  800538:	89 44 24 08          	mov    %eax,0x8(%esp)
  80053c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800542:	89 44 24 04          	mov    %eax,0x4(%esp)
  800546:	c7 04 24 b5 04 80 00 	movl   $0x8004b5,(%esp)
  80054d:	e8 bd 01 00 00       	call   80070f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800552:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800562:	83 c0 08             	add    $0x8,%eax
  800565:	89 04 24             	mov    %eax,(%esp)
  800568:	e8 cc fb ff ff       	call   800139 <sys_cputs>

	return b.cnt;
  80056d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800573:	c9                   	leave  
  800574:	c3                   	ret    

00800575 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800575:	55                   	push   %ebp
  800576:	89 e5                	mov    %esp,%ebp
  800578:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80057b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80057e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800581:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800584:	89 44 24 04          	mov    %eax,0x4(%esp)
  800588:	8b 45 08             	mov    0x8(%ebp),%eax
  80058b:	89 04 24             	mov    %eax,(%esp)
  80058e:	e8 7e ff ff ff       	call   800511 <vcprintf>
  800593:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800596:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800599:	c9                   	leave  
  80059a:	c3                   	ret    

0080059b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
  80059e:	53                   	push   %ebx
  80059f:	83 ec 34             	sub    $0x34,%esp
  8005a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8005a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ae:	8b 45 18             	mov    0x18(%ebp),%eax
  8005b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005b6:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005b9:	77 72                	ja     80062d <printnum+0x92>
  8005bb:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005be:	72 05                	jb     8005c5 <printnum+0x2a>
  8005c0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8005c3:	77 68                	ja     80062d <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005c5:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8005c8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005cb:	8b 45 18             	mov    0x18(%ebp),%eax
  8005ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005e1:	89 04 24             	mov    %eax,(%esp)
  8005e4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005e8:	e8 d3 0b 00 00       	call   8011c0 <__udivdi3>
  8005ed:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005f0:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005f4:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005f8:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005fb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800603:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800607:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060e:	8b 45 08             	mov    0x8(%ebp),%eax
  800611:	89 04 24             	mov    %eax,(%esp)
  800614:	e8 82 ff ff ff       	call   80059b <printnum>
  800619:	eb 1c                	jmp    800637 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80061b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80061e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800622:	8b 45 20             	mov    0x20(%ebp),%eax
  800625:	89 04 24             	mov    %eax,(%esp)
  800628:	8b 45 08             	mov    0x8(%ebp),%eax
  80062b:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80062d:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800631:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800635:	7f e4                	jg     80061b <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800637:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80063a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80063f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800642:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800645:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800649:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80064d:	89 04 24             	mov    %eax,(%esp)
  800650:	89 54 24 04          	mov    %edx,0x4(%esp)
  800654:	e8 97 0c 00 00       	call   8012f0 <__umoddi3>
  800659:	05 88 15 80 00       	add    $0x801588,%eax
  80065e:	0f b6 00             	movzbl (%eax),%eax
  800661:	0f be c0             	movsbl %al,%eax
  800664:	8b 55 0c             	mov    0xc(%ebp),%edx
  800667:	89 54 24 04          	mov    %edx,0x4(%esp)
  80066b:	89 04 24             	mov    %eax,(%esp)
  80066e:	8b 45 08             	mov    0x8(%ebp),%eax
  800671:	ff d0                	call   *%eax
}
  800673:	83 c4 34             	add    $0x34,%esp
  800676:	5b                   	pop    %ebx
  800677:	5d                   	pop    %ebp
  800678:	c3                   	ret    

00800679 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80067c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800680:	7e 14                	jle    800696 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800682:	8b 45 08             	mov    0x8(%ebp),%eax
  800685:	8b 00                	mov    (%eax),%eax
  800687:	8d 48 08             	lea    0x8(%eax),%ecx
  80068a:	8b 55 08             	mov    0x8(%ebp),%edx
  80068d:	89 0a                	mov    %ecx,(%edx)
  80068f:	8b 50 04             	mov    0x4(%eax),%edx
  800692:	8b 00                	mov    (%eax),%eax
  800694:	eb 30                	jmp    8006c6 <getuint+0x4d>
	else if (lflag)
  800696:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80069a:	74 16                	je     8006b2 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80069c:	8b 45 08             	mov    0x8(%ebp),%eax
  80069f:	8b 00                	mov    (%eax),%eax
  8006a1:	8d 48 04             	lea    0x4(%eax),%ecx
  8006a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a7:	89 0a                	mov    %ecx,(%edx)
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b0:	eb 14                	jmp    8006c6 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b5:	8b 00                	mov    (%eax),%eax
  8006b7:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8006bd:	89 0a                	mov    %ecx,(%edx)
  8006bf:	8b 00                	mov    (%eax),%eax
  8006c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006c6:	5d                   	pop    %ebp
  8006c7:	c3                   	ret    

008006c8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006cb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006cf:	7e 14                	jle    8006e5 <getint+0x1d>
		return va_arg(*ap, long long);
  8006d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	8d 48 08             	lea    0x8(%eax),%ecx
  8006d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8006dc:	89 0a                	mov    %ecx,(%edx)
  8006de:	8b 50 04             	mov    0x4(%eax),%edx
  8006e1:	8b 00                	mov    (%eax),%eax
  8006e3:	eb 28                	jmp    80070d <getint+0x45>
	else if (lflag)
  8006e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006e9:	74 12                	je     8006fd <getint+0x35>
		return va_arg(*ap, long);
  8006eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ee:	8b 00                	mov    (%eax),%eax
  8006f0:	8d 48 04             	lea    0x4(%eax),%ecx
  8006f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f6:	89 0a                	mov    %ecx,(%edx)
  8006f8:	8b 00                	mov    (%eax),%eax
  8006fa:	99                   	cltd   
  8006fb:	eb 10                	jmp    80070d <getint+0x45>
	else
		return va_arg(*ap, int);
  8006fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800700:	8b 00                	mov    (%eax),%eax
  800702:	8d 48 04             	lea    0x4(%eax),%ecx
  800705:	8b 55 08             	mov    0x8(%ebp),%edx
  800708:	89 0a                	mov    %ecx,(%edx)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	99                   	cltd   
}
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	56                   	push   %esi
  800713:	53                   	push   %ebx
  800714:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800717:	eb 18                	jmp    800731 <vprintfmt+0x22>
			if (ch == '\0')
  800719:	85 db                	test   %ebx,%ebx
  80071b:	75 05                	jne    800722 <vprintfmt+0x13>
				return;
  80071d:	e9 05 04 00 00       	jmp    800b27 <vprintfmt+0x418>
			putch(ch, putdat);
  800722:	8b 45 0c             	mov    0xc(%ebp),%eax
  800725:	89 44 24 04          	mov    %eax,0x4(%esp)
  800729:	89 1c 24             	mov    %ebx,(%esp)
  80072c:	8b 45 08             	mov    0x8(%ebp),%eax
  80072f:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800731:	8b 45 10             	mov    0x10(%ebp),%eax
  800734:	8d 50 01             	lea    0x1(%eax),%edx
  800737:	89 55 10             	mov    %edx,0x10(%ebp)
  80073a:	0f b6 00             	movzbl (%eax),%eax
  80073d:	0f b6 d8             	movzbl %al,%ebx
  800740:	83 fb 25             	cmp    $0x25,%ebx
  800743:	75 d4                	jne    800719 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800745:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800749:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800750:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800757:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80075e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800765:	8b 45 10             	mov    0x10(%ebp),%eax
  800768:	8d 50 01             	lea    0x1(%eax),%edx
  80076b:	89 55 10             	mov    %edx,0x10(%ebp)
  80076e:	0f b6 00             	movzbl (%eax),%eax
  800771:	0f b6 d8             	movzbl %al,%ebx
  800774:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800777:	83 f8 55             	cmp    $0x55,%eax
  80077a:	0f 87 76 03 00 00    	ja     800af6 <vprintfmt+0x3e7>
  800780:	8b 04 85 ac 15 80 00 	mov    0x8015ac(,%eax,4),%eax
  800787:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800789:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80078d:	eb d6                	jmp    800765 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80078f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800793:	eb d0                	jmp    800765 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800795:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80079c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80079f:	89 d0                	mov    %edx,%eax
  8007a1:	c1 e0 02             	shl    $0x2,%eax
  8007a4:	01 d0                	add    %edx,%eax
  8007a6:	01 c0                	add    %eax,%eax
  8007a8:	01 d8                	add    %ebx,%eax
  8007aa:	83 e8 30             	sub    $0x30,%eax
  8007ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b3:	0f b6 00             	movzbl (%eax),%eax
  8007b6:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007b9:	83 fb 2f             	cmp    $0x2f,%ebx
  8007bc:	7e 0b                	jle    8007c9 <vprintfmt+0xba>
  8007be:	83 fb 39             	cmp    $0x39,%ebx
  8007c1:	7f 06                	jg     8007c9 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007c3:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007c7:	eb d3                	jmp    80079c <vprintfmt+0x8d>
			goto process_precision;
  8007c9:	eb 33                	jmp    8007fe <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 50 04             	lea    0x4(%eax),%edx
  8007d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d4:	8b 00                	mov    (%eax),%eax
  8007d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007d9:	eb 23                	jmp    8007fe <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007df:	79 0c                	jns    8007ed <vprintfmt+0xde>
				width = 0;
  8007e1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007e8:	e9 78 ff ff ff       	jmp    800765 <vprintfmt+0x56>
  8007ed:	e9 73 ff ff ff       	jmp    800765 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007f2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007f9:	e9 67 ff ff ff       	jmp    800765 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8007fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800802:	79 12                	jns    800816 <vprintfmt+0x107>
				width = precision, precision = -1;
  800804:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800807:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80080a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800811:	e9 4f ff ff ff       	jmp    800765 <vprintfmt+0x56>
  800816:	e9 4a ff ff ff       	jmp    800765 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80081b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80081f:	e9 41 ff ff ff       	jmp    800765 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8d 50 04             	lea    0x4(%eax),%edx
  80082a:	89 55 14             	mov    %edx,0x14(%ebp)
  80082d:	8b 00                	mov    (%eax),%eax
  80082f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800832:	89 54 24 04          	mov    %edx,0x4(%esp)
  800836:	89 04 24             	mov    %eax,(%esp)
  800839:	8b 45 08             	mov    0x8(%ebp),%eax
  80083c:	ff d0                	call   *%eax
			break;
  80083e:	e9 de 02 00 00       	jmp    800b21 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800843:	8b 45 14             	mov    0x14(%ebp),%eax
  800846:	8d 50 04             	lea    0x4(%eax),%edx
  800849:	89 55 14             	mov    %edx,0x14(%ebp)
  80084c:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80084e:	85 db                	test   %ebx,%ebx
  800850:	79 02                	jns    800854 <vprintfmt+0x145>
				err = -err;
  800852:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800854:	83 fb 09             	cmp    $0x9,%ebx
  800857:	7f 0b                	jg     800864 <vprintfmt+0x155>
  800859:	8b 34 9d 60 15 80 00 	mov    0x801560(,%ebx,4),%esi
  800860:	85 f6                	test   %esi,%esi
  800862:	75 23                	jne    800887 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800864:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800868:	c7 44 24 08 99 15 80 	movl   $0x801599,0x8(%esp)
  80086f:	00 
  800870:	8b 45 0c             	mov    0xc(%ebp),%eax
  800873:	89 44 24 04          	mov    %eax,0x4(%esp)
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	89 04 24             	mov    %eax,(%esp)
  80087d:	e8 ac 02 00 00       	call   800b2e <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800882:	e9 9a 02 00 00       	jmp    800b21 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800887:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80088b:	c7 44 24 08 a2 15 80 	movl   $0x8015a2,0x8(%esp)
  800892:	00 
  800893:	8b 45 0c             	mov    0xc(%ebp),%eax
  800896:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	89 04 24             	mov    %eax,(%esp)
  8008a0:	e8 89 02 00 00       	call   800b2e <printfmt>
			break;
  8008a5:	e9 77 02 00 00       	jmp    800b21 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ad:	8d 50 04             	lea    0x4(%eax),%edx
  8008b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b3:	8b 30                	mov    (%eax),%esi
  8008b5:	85 f6                	test   %esi,%esi
  8008b7:	75 05                	jne    8008be <vprintfmt+0x1af>
				p = "(null)";
  8008b9:	be a5 15 80 00       	mov    $0x8015a5,%esi
			if (width > 0 && padc != '-')
  8008be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008c2:	7e 37                	jle    8008fb <vprintfmt+0x1ec>
  8008c4:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8008c8:	74 31                	je     8008fb <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d1:	89 34 24             	mov    %esi,(%esp)
  8008d4:	e8 72 03 00 00       	call   800c4b <strnlen>
  8008d9:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008dc:	eb 17                	jmp    8008f5 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008de:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e9:	89 04 24             	mov    %eax,(%esp)
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008f1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008f5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008f9:	7f e3                	jg     8008de <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008fb:	eb 38                	jmp    800935 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8008fd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800901:	74 1f                	je     800922 <vprintfmt+0x213>
  800903:	83 fb 1f             	cmp    $0x1f,%ebx
  800906:	7e 05                	jle    80090d <vprintfmt+0x1fe>
  800908:	83 fb 7e             	cmp    $0x7e,%ebx
  80090b:	7e 15                	jle    800922 <vprintfmt+0x213>
					putch('?', putdat);
  80090d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800910:	89 44 24 04          	mov    %eax,0x4(%esp)
  800914:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	ff d0                	call   *%eax
  800920:	eb 0f                	jmp    800931 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800922:	8b 45 0c             	mov    0xc(%ebp),%eax
  800925:	89 44 24 04          	mov    %eax,0x4(%esp)
  800929:	89 1c 24             	mov    %ebx,(%esp)
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800931:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800935:	89 f0                	mov    %esi,%eax
  800937:	8d 70 01             	lea    0x1(%eax),%esi
  80093a:	0f b6 00             	movzbl (%eax),%eax
  80093d:	0f be d8             	movsbl %al,%ebx
  800940:	85 db                	test   %ebx,%ebx
  800942:	74 10                	je     800954 <vprintfmt+0x245>
  800944:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800948:	78 b3                	js     8008fd <vprintfmt+0x1ee>
  80094a:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80094e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800952:	79 a9                	jns    8008fd <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800954:	eb 17                	jmp    80096d <vprintfmt+0x25e>
				putch(' ', putdat);
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800969:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80096d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800971:	7f e3                	jg     800956 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800973:	e9 a9 01 00 00       	jmp    800b21 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800978:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80097b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097f:	8d 45 14             	lea    0x14(%ebp),%eax
  800982:	89 04 24             	mov    %eax,(%esp)
  800985:	e8 3e fd ff ff       	call   8006c8 <getint>
  80098a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80098d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800990:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800993:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800996:	85 d2                	test   %edx,%edx
  800998:	79 26                	jns    8009c0 <vprintfmt+0x2b1>
				putch('-', putdat);
  80099a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	ff d0                	call   *%eax
				num = -(long long) num;
  8009ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009b3:	f7 d8                	neg    %eax
  8009b5:	83 d2 00             	adc    $0x0,%edx
  8009b8:	f7 da                	neg    %edx
  8009ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009bd:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8009c0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009c7:	e9 e1 00 00 00       	jmp    800aad <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d6:	89 04 24             	mov    %eax,(%esp)
  8009d9:	e8 9b fc ff ff       	call   800679 <getuint>
  8009de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009e1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009e4:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009eb:	e9 bd 00 00 00       	jmp    800aad <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  8009f0:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  8009f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800a01:	89 04 24             	mov    %eax,(%esp)
  800a04:	e8 70 fc ff ff       	call   800679 <getuint>
  800a09:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a0c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  800a0f:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a16:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a1a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a1d:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a21:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a28:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a2f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a36:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	89 04 24             	mov    %eax,(%esp)
  800a40:	e8 56 fb ff ff       	call   80059b <printnum>
			break;
  800a45:	e9 d7 00 00 00       	jmp    800b21 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  800a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a51:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5b:	ff d0                	call   *%eax
			putch('x', putdat);
  800a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a60:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a64:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a70:	8b 45 14             	mov    0x14(%ebp),%eax
  800a73:	8d 50 04             	lea    0x4(%eax),%edx
  800a76:	89 55 14             	mov    %edx,0x14(%ebp)
  800a79:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a85:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a8c:	eb 1f                	jmp    800aad <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a95:	8d 45 14             	lea    0x14(%ebp),%eax
  800a98:	89 04 24             	mov    %eax,(%esp)
  800a9b:	e8 d9 fb ff ff       	call   800679 <getuint>
  800aa0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aa3:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800aa6:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800aad:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800ab1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ab4:	89 54 24 18          	mov    %edx,0x18(%esp)
  800ab8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800abb:	89 54 24 14          	mov    %edx,0x14(%esp)
  800abf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800acd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ad1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	89 04 24             	mov    %eax,(%esp)
  800ade:	e8 b8 fa ff ff       	call   80059b <printnum>
			break;
  800ae3:	eb 3c                	jmp    800b21 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aec:	89 1c 24             	mov    %ebx,(%esp)
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	ff d0                	call   *%eax
			break;
  800af4:	eb 2b                	jmp    800b21 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800af6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b09:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b0d:	eb 04                	jmp    800b13 <vprintfmt+0x404>
  800b0f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b13:	8b 45 10             	mov    0x10(%ebp),%eax
  800b16:	83 e8 01             	sub    $0x1,%eax
  800b19:	0f b6 00             	movzbl (%eax),%eax
  800b1c:	3c 25                	cmp    $0x25,%al
  800b1e:	75 ef                	jne    800b0f <vprintfmt+0x400>
				/* do nothing */;
			break;
  800b20:	90                   	nop
		}
	}
  800b21:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b22:	e9 0a fc ff ff       	jmp    800731 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b27:	83 c4 40             	add    $0x40,%esp
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b34:	8d 45 14             	lea    0x14(%ebp),%eax
  800b37:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b41:	8b 45 10             	mov    0x10(%ebp),%eax
  800b44:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b52:	89 04 24             	mov    %eax,(%esp)
  800b55:	e8 b5 fb ff ff       	call   80070f <vprintfmt>
	va_end(ap);
}
  800b5a:	c9                   	leave  
  800b5b:	c3                   	ret    

00800b5c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b62:	8b 40 08             	mov    0x8(%eax),%eax
  800b65:	8d 50 01             	lea    0x1(%eax),%edx
  800b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6b:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b71:	8b 10                	mov    (%eax),%edx
  800b73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b76:	8b 40 04             	mov    0x4(%eax),%eax
  800b79:	39 c2                	cmp    %eax,%edx
  800b7b:	73 12                	jae    800b8f <sprintputch+0x33>
		*b->buf++ = ch;
  800b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b80:	8b 00                	mov    (%eax),%eax
  800b82:	8d 48 01             	lea    0x1(%eax),%ecx
  800b85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b88:	89 0a                	mov    %ecx,(%edx)
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	88 10                	mov    %dl,(%eax)
}
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b97:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba0:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba6:	01 d0                	add    %edx,%eax
  800ba8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bb2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800bb6:	74 06                	je     800bbe <vsnprintf+0x2d>
  800bb8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbc:	7f 07                	jg     800bc5 <vsnprintf+0x34>
		return -E_INVAL;
  800bbe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bc3:	eb 2a                	jmp    800bef <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bc5:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bcc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bda:	c7 04 24 5c 0b 80 00 	movl   $0x800b5c,(%esp)
  800be1:	e8 29 fb ff ff       	call   80070f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800be6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800be9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bef:	c9                   	leave  
  800bf0:	c3                   	ret    

00800bf1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bf7:	8d 45 14             	lea    0x14(%ebp),%eax
  800bfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800bfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c00:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c04:	8b 45 10             	mov    0x10(%ebp),%eax
  800c07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c12:	8b 45 08             	mov    0x8(%ebp),%eax
  800c15:	89 04 24             	mov    %eax,(%esp)
  800c18:	e8 74 ff ff ff       	call   800b91 <vsnprintf>
  800c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c2b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c32:	eb 08                	jmp    800c3c <strlen+0x17>
		n++;
  800c34:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c38:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3f:	0f b6 00             	movzbl (%eax),%eax
  800c42:	84 c0                	test   %al,%al
  800c44:	75 ee                	jne    800c34 <strlen+0xf>
		n++;
	return n;
  800c46:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c49:	c9                   	leave  
  800c4a:	c3                   	ret    

00800c4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c51:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c58:	eb 0c                	jmp    800c66 <strnlen+0x1b>
		n++;
  800c5a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c5e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c62:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6a:	74 0a                	je     800c76 <strnlen+0x2b>
  800c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6f:	0f b6 00             	movzbl (%eax),%eax
  800c72:	84 c0                	test   %al,%al
  800c74:	75 e4                	jne    800c5a <strnlen+0xf>
		n++;
	return n;
  800c76:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c79:	c9                   	leave  
  800c7a:	c3                   	ret    

00800c7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c81:	8b 45 08             	mov    0x8(%ebp),%eax
  800c84:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c87:	90                   	nop
  800c88:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8b:	8d 50 01             	lea    0x1(%eax),%edx
  800c8e:	89 55 08             	mov    %edx,0x8(%ebp)
  800c91:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c94:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c97:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c9a:	0f b6 12             	movzbl (%edx),%edx
  800c9d:	88 10                	mov    %dl,(%eax)
  800c9f:	0f b6 00             	movzbl (%eax),%eax
  800ca2:	84 c0                	test   %al,%al
  800ca4:	75 e2                	jne    800c88 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800ca6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800ca9:	c9                   	leave  
  800caa:	c3                   	ret    

00800cab <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800cb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb4:	89 04 24             	mov    %eax,(%esp)
  800cb7:	e8 69 ff ff ff       	call   800c25 <strlen>
  800cbc:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800cbf:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc5:	01 c2                	add    %eax,%edx
  800cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cca:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cce:	89 14 24             	mov    %edx,(%esp)
  800cd1:	e8 a5 ff ff ff       	call   800c7b <strcpy>
	return dst;
  800cd6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cd9:	c9                   	leave  
  800cda:	c3                   	ret    

00800cdb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce4:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800ce7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cee:	eb 23                	jmp    800d13 <strncpy+0x38>
		*dst++ = *src;
  800cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf3:	8d 50 01             	lea    0x1(%eax),%edx
  800cf6:	89 55 08             	mov    %edx,0x8(%ebp)
  800cf9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cfc:	0f b6 12             	movzbl (%edx),%edx
  800cff:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d04:	0f b6 00             	movzbl (%eax),%eax
  800d07:	84 c0                	test   %al,%al
  800d09:	74 04                	je     800d0f <strncpy+0x34>
			src++;
  800d0b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d0f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d13:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d16:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d19:	72 d5                	jb     800cf0 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d1b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d1e:	c9                   	leave  
  800d1f:	c3                   	ret    

00800d20 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d26:	8b 45 08             	mov    0x8(%ebp),%eax
  800d29:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d30:	74 33                	je     800d65 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d32:	eb 17                	jmp    800d4b <strlcpy+0x2b>
			*dst++ = *src++;
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	8d 50 01             	lea    0x1(%eax),%edx
  800d3a:	89 55 08             	mov    %edx,0x8(%ebp)
  800d3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d40:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d43:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d46:	0f b6 12             	movzbl (%edx),%edx
  800d49:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d4b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d4f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d53:	74 0a                	je     800d5f <strlcpy+0x3f>
  800d55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d58:	0f b6 00             	movzbl (%eax),%eax
  800d5b:	84 c0                	test   %al,%al
  800d5d:	75 d5                	jne    800d34 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d62:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d6b:	29 c2                	sub    %eax,%edx
  800d6d:	89 d0                	mov    %edx,%eax
}
  800d6f:	c9                   	leave  
  800d70:	c3                   	ret    

00800d71 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d74:	eb 08                	jmp    800d7e <strcmp+0xd>
		p++, q++;
  800d76:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d7a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d81:	0f b6 00             	movzbl (%eax),%eax
  800d84:	84 c0                	test   %al,%al
  800d86:	74 10                	je     800d98 <strcmp+0x27>
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8b:	0f b6 10             	movzbl (%eax),%edx
  800d8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d91:	0f b6 00             	movzbl (%eax),%eax
  800d94:	38 c2                	cmp    %al,%dl
  800d96:	74 de                	je     800d76 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9b:	0f b6 00             	movzbl (%eax),%eax
  800d9e:	0f b6 d0             	movzbl %al,%edx
  800da1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da4:	0f b6 00             	movzbl (%eax),%eax
  800da7:	0f b6 c0             	movzbl %al,%eax
  800daa:	29 c2                	sub    %eax,%edx
  800dac:	89 d0                	mov    %edx,%eax
}
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800db3:	eb 0c                	jmp    800dc1 <strncmp+0x11>
		n--, p++, q++;
  800db5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800db9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dbd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dc1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dc5:	74 1a                	je     800de1 <strncmp+0x31>
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dca:	0f b6 00             	movzbl (%eax),%eax
  800dcd:	84 c0                	test   %al,%al
  800dcf:	74 10                	je     800de1 <strncmp+0x31>
  800dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd4:	0f b6 10             	movzbl (%eax),%edx
  800dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dda:	0f b6 00             	movzbl (%eax),%eax
  800ddd:	38 c2                	cmp    %al,%dl
  800ddf:	74 d4                	je     800db5 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800de1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800de5:	75 07                	jne    800dee <strncmp+0x3e>
		return 0;
  800de7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dec:	eb 16                	jmp    800e04 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	0f b6 00             	movzbl (%eax),%eax
  800df4:	0f b6 d0             	movzbl %al,%edx
  800df7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfa:	0f b6 00             	movzbl (%eax),%eax
  800dfd:	0f b6 c0             	movzbl %al,%eax
  800e00:	29 c2                	sub    %eax,%edx
  800e02:	89 d0                	mov    %edx,%eax
}
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	83 ec 04             	sub    $0x4,%esp
  800e0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0f:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e12:	eb 14                	jmp    800e28 <strchr+0x22>
		if (*s == c)
  800e14:	8b 45 08             	mov    0x8(%ebp),%eax
  800e17:	0f b6 00             	movzbl (%eax),%eax
  800e1a:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e1d:	75 05                	jne    800e24 <strchr+0x1e>
			return (char *) s;
  800e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e22:	eb 13                	jmp    800e37 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e24:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	0f b6 00             	movzbl (%eax),%eax
  800e2e:	84 c0                	test   %al,%al
  800e30:	75 e2                	jne    800e14 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e37:	c9                   	leave  
  800e38:	c3                   	ret    

00800e39 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	83 ec 04             	sub    $0x4,%esp
  800e3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e42:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e45:	eb 11                	jmp    800e58 <strfind+0x1f>
		if (*s == c)
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4a:	0f b6 00             	movzbl (%eax),%eax
  800e4d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e50:	75 02                	jne    800e54 <strfind+0x1b>
			break;
  800e52:	eb 0e                	jmp    800e62 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e54:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e58:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5b:	0f b6 00             	movzbl (%eax),%eax
  800e5e:	84 c0                	test   %al,%al
  800e60:	75 e5                	jne    800e47 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e62:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e65:	c9                   	leave  
  800e66:	c3                   	ret    

00800e67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e6b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e6f:	75 05                	jne    800e76 <memset+0xf>
		return v;
  800e71:	8b 45 08             	mov    0x8(%ebp),%eax
  800e74:	eb 5c                	jmp    800ed2 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e76:	8b 45 08             	mov    0x8(%ebp),%eax
  800e79:	83 e0 03             	and    $0x3,%eax
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	75 41                	jne    800ec1 <memset+0x5a>
  800e80:	8b 45 10             	mov    0x10(%ebp),%eax
  800e83:	83 e0 03             	and    $0x3,%eax
  800e86:	85 c0                	test   %eax,%eax
  800e88:	75 37                	jne    800ec1 <memset+0x5a>
		c &= 0xFF;
  800e8a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e94:	c1 e0 18             	shl    $0x18,%eax
  800e97:	89 c2                	mov    %eax,%edx
  800e99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9c:	c1 e0 10             	shl    $0x10,%eax
  800e9f:	09 c2                	or     %eax,%edx
  800ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea4:	c1 e0 08             	shl    $0x8,%eax
  800ea7:	09 d0                	or     %edx,%eax
  800ea9:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800eac:	8b 45 10             	mov    0x10(%ebp),%eax
  800eaf:	c1 e8 02             	shr    $0x2,%eax
  800eb2:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800eb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eba:	89 d7                	mov    %edx,%edi
  800ebc:	fc                   	cld    
  800ebd:	f3 ab                	rep stos %eax,%es:(%edi)
  800ebf:	eb 0e                	jmp    800ecf <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ec1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800eca:	89 d7                	mov    %edx,%edi
  800ecc:	fc                   	cld    
  800ecd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ecf:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	57                   	push   %edi
  800ed9:	56                   	push   %esi
  800eda:	53                   	push   %ebx
  800edb:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ede:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800ee4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee7:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eed:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ef0:	73 6d                	jae    800f5f <memmove+0x8a>
  800ef2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ef8:	01 d0                	add    %edx,%eax
  800efa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800efd:	76 60                	jbe    800f5f <memmove+0x8a>
		s += n;
  800eff:	8b 45 10             	mov    0x10(%ebp),%eax
  800f02:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f05:	8b 45 10             	mov    0x10(%ebp),%eax
  800f08:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f0e:	83 e0 03             	and    $0x3,%eax
  800f11:	85 c0                	test   %eax,%eax
  800f13:	75 2f                	jne    800f44 <memmove+0x6f>
  800f15:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f18:	83 e0 03             	and    $0x3,%eax
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	75 25                	jne    800f44 <memmove+0x6f>
  800f1f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f22:	83 e0 03             	and    $0x3,%eax
  800f25:	85 c0                	test   %eax,%eax
  800f27:	75 1b                	jne    800f44 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f29:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f2c:	83 e8 04             	sub    $0x4,%eax
  800f2f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f32:	83 ea 04             	sub    $0x4,%edx
  800f35:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f38:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f3b:	89 c7                	mov    %eax,%edi
  800f3d:	89 d6                	mov    %edx,%esi
  800f3f:	fd                   	std    
  800f40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f42:	eb 18                	jmp    800f5c <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f44:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f47:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4d:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f50:	8b 45 10             	mov    0x10(%ebp),%eax
  800f53:	89 d7                	mov    %edx,%edi
  800f55:	89 de                	mov    %ebx,%esi
  800f57:	89 c1                	mov    %eax,%ecx
  800f59:	fd                   	std    
  800f5a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f5c:	fc                   	cld    
  800f5d:	eb 45                	jmp    800fa4 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f62:	83 e0 03             	and    $0x3,%eax
  800f65:	85 c0                	test   %eax,%eax
  800f67:	75 2b                	jne    800f94 <memmove+0xbf>
  800f69:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f6c:	83 e0 03             	and    $0x3,%eax
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	75 21                	jne    800f94 <memmove+0xbf>
  800f73:	8b 45 10             	mov    0x10(%ebp),%eax
  800f76:	83 e0 03             	and    $0x3,%eax
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	75 17                	jne    800f94 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f80:	c1 e8 02             	shr    $0x2,%eax
  800f83:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f85:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f8b:	89 c7                	mov    %eax,%edi
  800f8d:	89 d6                	mov    %edx,%esi
  800f8f:	fc                   	cld    
  800f90:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f92:	eb 10                	jmp    800fa4 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f94:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f97:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f9d:	89 c7                	mov    %eax,%edi
  800f9f:	89 d6                	mov    %edx,%esi
  800fa1:	fc                   	cld    
  800fa2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800fa4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	5b                   	pop    %ebx
  800fab:	5e                   	pop    %esi
  800fac:	5f                   	pop    %edi
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    

00800faf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fb5:	8b 45 10             	mov    0x10(%ebp),%eax
  800fb8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc6:	89 04 24             	mov    %eax,(%esp)
  800fc9:	e8 07 ff ff ff       	call   800ed5 <memmove>
}
  800fce:	c9                   	leave  
  800fcf:	c3                   	ret    

00800fd0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdf:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fe2:	eb 30                	jmp    801014 <memcmp+0x44>
		if (*s1 != *s2)
  800fe4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fe7:	0f b6 10             	movzbl (%eax),%edx
  800fea:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fed:	0f b6 00             	movzbl (%eax),%eax
  800ff0:	38 c2                	cmp    %al,%dl
  800ff2:	74 18                	je     80100c <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800ff4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ff7:	0f b6 00             	movzbl (%eax),%eax
  800ffa:	0f b6 d0             	movzbl %al,%edx
  800ffd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801000:	0f b6 00             	movzbl (%eax),%eax
  801003:	0f b6 c0             	movzbl %al,%eax
  801006:	29 c2                	sub    %eax,%edx
  801008:	89 d0                	mov    %edx,%eax
  80100a:	eb 1a                	jmp    801026 <memcmp+0x56>
		s1++, s2++;
  80100c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801010:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801014:	8b 45 10             	mov    0x10(%ebp),%eax
  801017:	8d 50 ff             	lea    -0x1(%eax),%edx
  80101a:	89 55 10             	mov    %edx,0x10(%ebp)
  80101d:	85 c0                	test   %eax,%eax
  80101f:	75 c3                	jne    800fe4 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801021:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801026:	c9                   	leave  
  801027:	c3                   	ret    

00801028 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  80102e:	8b 45 10             	mov    0x10(%ebp),%eax
  801031:	8b 55 08             	mov    0x8(%ebp),%edx
  801034:	01 d0                	add    %edx,%eax
  801036:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801039:	eb 13                	jmp    80104e <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  80103b:	8b 45 08             	mov    0x8(%ebp),%eax
  80103e:	0f b6 10             	movzbl (%eax),%edx
  801041:	8b 45 0c             	mov    0xc(%ebp),%eax
  801044:	38 c2                	cmp    %al,%dl
  801046:	75 02                	jne    80104a <memfind+0x22>
			break;
  801048:	eb 0c                	jmp    801056 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80104a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80104e:	8b 45 08             	mov    0x8(%ebp),%eax
  801051:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801054:	72 e5                	jb     80103b <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801056:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801059:	c9                   	leave  
  80105a:	c3                   	ret    

0080105b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801061:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801068:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80106f:	eb 04                	jmp    801075 <strtol+0x1a>
		s++;
  801071:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801075:	8b 45 08             	mov    0x8(%ebp),%eax
  801078:	0f b6 00             	movzbl (%eax),%eax
  80107b:	3c 20                	cmp    $0x20,%al
  80107d:	74 f2                	je     801071 <strtol+0x16>
  80107f:	8b 45 08             	mov    0x8(%ebp),%eax
  801082:	0f b6 00             	movzbl (%eax),%eax
  801085:	3c 09                	cmp    $0x9,%al
  801087:	74 e8                	je     801071 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801089:	8b 45 08             	mov    0x8(%ebp),%eax
  80108c:	0f b6 00             	movzbl (%eax),%eax
  80108f:	3c 2b                	cmp    $0x2b,%al
  801091:	75 06                	jne    801099 <strtol+0x3e>
		s++;
  801093:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801097:	eb 15                	jmp    8010ae <strtol+0x53>
	else if (*s == '-')
  801099:	8b 45 08             	mov    0x8(%ebp),%eax
  80109c:	0f b6 00             	movzbl (%eax),%eax
  80109f:	3c 2d                	cmp    $0x2d,%al
  8010a1:	75 0b                	jne    8010ae <strtol+0x53>
		s++, neg = 1;
  8010a3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010a7:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010b2:	74 06                	je     8010ba <strtol+0x5f>
  8010b4:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8010b8:	75 24                	jne    8010de <strtol+0x83>
  8010ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bd:	0f b6 00             	movzbl (%eax),%eax
  8010c0:	3c 30                	cmp    $0x30,%al
  8010c2:	75 1a                	jne    8010de <strtol+0x83>
  8010c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c7:	83 c0 01             	add    $0x1,%eax
  8010ca:	0f b6 00             	movzbl (%eax),%eax
  8010cd:	3c 78                	cmp    $0x78,%al
  8010cf:	75 0d                	jne    8010de <strtol+0x83>
		s += 2, base = 16;
  8010d1:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010d5:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010dc:	eb 2a                	jmp    801108 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010de:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010e2:	75 17                	jne    8010fb <strtol+0xa0>
  8010e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e7:	0f b6 00             	movzbl (%eax),%eax
  8010ea:	3c 30                	cmp    $0x30,%al
  8010ec:	75 0d                	jne    8010fb <strtol+0xa0>
		s++, base = 8;
  8010ee:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010f2:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010f9:	eb 0d                	jmp    801108 <strtol+0xad>
	else if (base == 0)
  8010fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010ff:	75 07                	jne    801108 <strtol+0xad>
		base = 10;
  801101:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801108:	8b 45 08             	mov    0x8(%ebp),%eax
  80110b:	0f b6 00             	movzbl (%eax),%eax
  80110e:	3c 2f                	cmp    $0x2f,%al
  801110:	7e 1b                	jle    80112d <strtol+0xd2>
  801112:	8b 45 08             	mov    0x8(%ebp),%eax
  801115:	0f b6 00             	movzbl (%eax),%eax
  801118:	3c 39                	cmp    $0x39,%al
  80111a:	7f 11                	jg     80112d <strtol+0xd2>
			dig = *s - '0';
  80111c:	8b 45 08             	mov    0x8(%ebp),%eax
  80111f:	0f b6 00             	movzbl (%eax),%eax
  801122:	0f be c0             	movsbl %al,%eax
  801125:	83 e8 30             	sub    $0x30,%eax
  801128:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80112b:	eb 48                	jmp    801175 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  80112d:	8b 45 08             	mov    0x8(%ebp),%eax
  801130:	0f b6 00             	movzbl (%eax),%eax
  801133:	3c 60                	cmp    $0x60,%al
  801135:	7e 1b                	jle    801152 <strtol+0xf7>
  801137:	8b 45 08             	mov    0x8(%ebp),%eax
  80113a:	0f b6 00             	movzbl (%eax),%eax
  80113d:	3c 7a                	cmp    $0x7a,%al
  80113f:	7f 11                	jg     801152 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801141:	8b 45 08             	mov    0x8(%ebp),%eax
  801144:	0f b6 00             	movzbl (%eax),%eax
  801147:	0f be c0             	movsbl %al,%eax
  80114a:	83 e8 57             	sub    $0x57,%eax
  80114d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801150:	eb 23                	jmp    801175 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801152:	8b 45 08             	mov    0x8(%ebp),%eax
  801155:	0f b6 00             	movzbl (%eax),%eax
  801158:	3c 40                	cmp    $0x40,%al
  80115a:	7e 3d                	jle    801199 <strtol+0x13e>
  80115c:	8b 45 08             	mov    0x8(%ebp),%eax
  80115f:	0f b6 00             	movzbl (%eax),%eax
  801162:	3c 5a                	cmp    $0x5a,%al
  801164:	7f 33                	jg     801199 <strtol+0x13e>
			dig = *s - 'A' + 10;
  801166:	8b 45 08             	mov    0x8(%ebp),%eax
  801169:	0f b6 00             	movzbl (%eax),%eax
  80116c:	0f be c0             	movsbl %al,%eax
  80116f:	83 e8 37             	sub    $0x37,%eax
  801172:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801175:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801178:	3b 45 10             	cmp    0x10(%ebp),%eax
  80117b:	7c 02                	jl     80117f <strtol+0x124>
			break;
  80117d:	eb 1a                	jmp    801199 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80117f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801183:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801186:	0f af 45 10          	imul   0x10(%ebp),%eax
  80118a:	89 c2                	mov    %eax,%edx
  80118c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118f:	01 d0                	add    %edx,%eax
  801191:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801194:	e9 6f ff ff ff       	jmp    801108 <strtol+0xad>

	if (endptr)
  801199:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80119d:	74 08                	je     8011a7 <strtol+0x14c>
		*endptr = (char *) s;
  80119f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a5:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011a7:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011ab:	74 07                	je     8011b4 <strtol+0x159>
  8011ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011b0:	f7 d8                	neg    %eax
  8011b2:	eb 03                	jmp    8011b7 <strtol+0x15c>
  8011b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8011b7:	c9                   	leave  
  8011b8:	c3                   	ret    
  8011b9:	66 90                	xchg   %ax,%ax
  8011bb:	66 90                	xchg   %ax,%ax
  8011bd:	66 90                	xchg   %ax,%ax
  8011bf:	90                   	nop

008011c0 <__udivdi3>:
  8011c0:	55                   	push   %ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	83 ec 0c             	sub    $0xc,%esp
  8011c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011dc:	89 ea                	mov    %ebp,%edx
  8011de:	89 0c 24             	mov    %ecx,(%esp)
  8011e1:	75 2d                	jne    801210 <__udivdi3+0x50>
  8011e3:	39 e9                	cmp    %ebp,%ecx
  8011e5:	77 61                	ja     801248 <__udivdi3+0x88>
  8011e7:	85 c9                	test   %ecx,%ecx
  8011e9:	89 ce                	mov    %ecx,%esi
  8011eb:	75 0b                	jne    8011f8 <__udivdi3+0x38>
  8011ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f2:	31 d2                	xor    %edx,%edx
  8011f4:	f7 f1                	div    %ecx
  8011f6:	89 c6                	mov    %eax,%esi
  8011f8:	31 d2                	xor    %edx,%edx
  8011fa:	89 e8                	mov    %ebp,%eax
  8011fc:	f7 f6                	div    %esi
  8011fe:	89 c5                	mov    %eax,%ebp
  801200:	89 f8                	mov    %edi,%eax
  801202:	f7 f6                	div    %esi
  801204:	89 ea                	mov    %ebp,%edx
  801206:	83 c4 0c             	add    $0xc,%esp
  801209:	5e                   	pop    %esi
  80120a:	5f                   	pop    %edi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    
  80120d:	8d 76 00             	lea    0x0(%esi),%esi
  801210:	39 e8                	cmp    %ebp,%eax
  801212:	77 24                	ja     801238 <__udivdi3+0x78>
  801214:	0f bd e8             	bsr    %eax,%ebp
  801217:	83 f5 1f             	xor    $0x1f,%ebp
  80121a:	75 3c                	jne    801258 <__udivdi3+0x98>
  80121c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801220:	39 34 24             	cmp    %esi,(%esp)
  801223:	0f 86 9f 00 00 00    	jbe    8012c8 <__udivdi3+0x108>
  801229:	39 d0                	cmp    %edx,%eax
  80122b:	0f 82 97 00 00 00    	jb     8012c8 <__udivdi3+0x108>
  801231:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801238:	31 d2                	xor    %edx,%edx
  80123a:	31 c0                	xor    %eax,%eax
  80123c:	83 c4 0c             	add    $0xc,%esp
  80123f:	5e                   	pop    %esi
  801240:	5f                   	pop    %edi
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    
  801243:	90                   	nop
  801244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801248:	89 f8                	mov    %edi,%eax
  80124a:	f7 f1                	div    %ecx
  80124c:	31 d2                	xor    %edx,%edx
  80124e:	83 c4 0c             	add    $0xc,%esp
  801251:	5e                   	pop    %esi
  801252:	5f                   	pop    %edi
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    
  801255:	8d 76 00             	lea    0x0(%esi),%esi
  801258:	89 e9                	mov    %ebp,%ecx
  80125a:	8b 3c 24             	mov    (%esp),%edi
  80125d:	d3 e0                	shl    %cl,%eax
  80125f:	89 c6                	mov    %eax,%esi
  801261:	b8 20 00 00 00       	mov    $0x20,%eax
  801266:	29 e8                	sub    %ebp,%eax
  801268:	89 c1                	mov    %eax,%ecx
  80126a:	d3 ef                	shr    %cl,%edi
  80126c:	89 e9                	mov    %ebp,%ecx
  80126e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801272:	8b 3c 24             	mov    (%esp),%edi
  801275:	09 74 24 08          	or     %esi,0x8(%esp)
  801279:	89 d6                	mov    %edx,%esi
  80127b:	d3 e7                	shl    %cl,%edi
  80127d:	89 c1                	mov    %eax,%ecx
  80127f:	89 3c 24             	mov    %edi,(%esp)
  801282:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801286:	d3 ee                	shr    %cl,%esi
  801288:	89 e9                	mov    %ebp,%ecx
  80128a:	d3 e2                	shl    %cl,%edx
  80128c:	89 c1                	mov    %eax,%ecx
  80128e:	d3 ef                	shr    %cl,%edi
  801290:	09 d7                	or     %edx,%edi
  801292:	89 f2                	mov    %esi,%edx
  801294:	89 f8                	mov    %edi,%eax
  801296:	f7 74 24 08          	divl   0x8(%esp)
  80129a:	89 d6                	mov    %edx,%esi
  80129c:	89 c7                	mov    %eax,%edi
  80129e:	f7 24 24             	mull   (%esp)
  8012a1:	39 d6                	cmp    %edx,%esi
  8012a3:	89 14 24             	mov    %edx,(%esp)
  8012a6:	72 30                	jb     8012d8 <__udivdi3+0x118>
  8012a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012ac:	89 e9                	mov    %ebp,%ecx
  8012ae:	d3 e2                	shl    %cl,%edx
  8012b0:	39 c2                	cmp    %eax,%edx
  8012b2:	73 05                	jae    8012b9 <__udivdi3+0xf9>
  8012b4:	3b 34 24             	cmp    (%esp),%esi
  8012b7:	74 1f                	je     8012d8 <__udivdi3+0x118>
  8012b9:	89 f8                	mov    %edi,%eax
  8012bb:	31 d2                	xor    %edx,%edx
  8012bd:	e9 7a ff ff ff       	jmp    80123c <__udivdi3+0x7c>
  8012c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012c8:	31 d2                	xor    %edx,%edx
  8012ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8012cf:	e9 68 ff ff ff       	jmp    80123c <__udivdi3+0x7c>
  8012d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012db:	31 d2                	xor    %edx,%edx
  8012dd:	83 c4 0c             	add    $0xc,%esp
  8012e0:	5e                   	pop    %esi
  8012e1:	5f                   	pop    %edi
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    
  8012e4:	66 90                	xchg   %ax,%ax
  8012e6:	66 90                	xchg   %ax,%ax
  8012e8:	66 90                	xchg   %ax,%ax
  8012ea:	66 90                	xchg   %ax,%ax
  8012ec:	66 90                	xchg   %ax,%ax
  8012ee:	66 90                	xchg   %ax,%ax

008012f0 <__umoddi3>:
  8012f0:	55                   	push   %ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	83 ec 14             	sub    $0x14,%esp
  8012f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801302:	89 c7                	mov    %eax,%edi
  801304:	89 44 24 04          	mov    %eax,0x4(%esp)
  801308:	8b 44 24 30          	mov    0x30(%esp),%eax
  80130c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801310:	89 34 24             	mov    %esi,(%esp)
  801313:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801317:	85 c0                	test   %eax,%eax
  801319:	89 c2                	mov    %eax,%edx
  80131b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80131f:	75 17                	jne    801338 <__umoddi3+0x48>
  801321:	39 fe                	cmp    %edi,%esi
  801323:	76 4b                	jbe    801370 <__umoddi3+0x80>
  801325:	89 c8                	mov    %ecx,%eax
  801327:	89 fa                	mov    %edi,%edx
  801329:	f7 f6                	div    %esi
  80132b:	89 d0                	mov    %edx,%eax
  80132d:	31 d2                	xor    %edx,%edx
  80132f:	83 c4 14             	add    $0x14,%esp
  801332:	5e                   	pop    %esi
  801333:	5f                   	pop    %edi
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    
  801336:	66 90                	xchg   %ax,%ax
  801338:	39 f8                	cmp    %edi,%eax
  80133a:	77 54                	ja     801390 <__umoddi3+0xa0>
  80133c:	0f bd e8             	bsr    %eax,%ebp
  80133f:	83 f5 1f             	xor    $0x1f,%ebp
  801342:	75 5c                	jne    8013a0 <__umoddi3+0xb0>
  801344:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801348:	39 3c 24             	cmp    %edi,(%esp)
  80134b:	0f 87 e7 00 00 00    	ja     801438 <__umoddi3+0x148>
  801351:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801355:	29 f1                	sub    %esi,%ecx
  801357:	19 c7                	sbb    %eax,%edi
  801359:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80135d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801361:	8b 44 24 08          	mov    0x8(%esp),%eax
  801365:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801369:	83 c4 14             	add    $0x14,%esp
  80136c:	5e                   	pop    %esi
  80136d:	5f                   	pop    %edi
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    
  801370:	85 f6                	test   %esi,%esi
  801372:	89 f5                	mov    %esi,%ebp
  801374:	75 0b                	jne    801381 <__umoddi3+0x91>
  801376:	b8 01 00 00 00       	mov    $0x1,%eax
  80137b:	31 d2                	xor    %edx,%edx
  80137d:	f7 f6                	div    %esi
  80137f:	89 c5                	mov    %eax,%ebp
  801381:	8b 44 24 04          	mov    0x4(%esp),%eax
  801385:	31 d2                	xor    %edx,%edx
  801387:	f7 f5                	div    %ebp
  801389:	89 c8                	mov    %ecx,%eax
  80138b:	f7 f5                	div    %ebp
  80138d:	eb 9c                	jmp    80132b <__umoddi3+0x3b>
  80138f:	90                   	nop
  801390:	89 c8                	mov    %ecx,%eax
  801392:	89 fa                	mov    %edi,%edx
  801394:	83 c4 14             	add    $0x14,%esp
  801397:	5e                   	pop    %esi
  801398:	5f                   	pop    %edi
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    
  80139b:	90                   	nop
  80139c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a0:	8b 04 24             	mov    (%esp),%eax
  8013a3:	be 20 00 00 00       	mov    $0x20,%esi
  8013a8:	89 e9                	mov    %ebp,%ecx
  8013aa:	29 ee                	sub    %ebp,%esi
  8013ac:	d3 e2                	shl    %cl,%edx
  8013ae:	89 f1                	mov    %esi,%ecx
  8013b0:	d3 e8                	shr    %cl,%eax
  8013b2:	89 e9                	mov    %ebp,%ecx
  8013b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b8:	8b 04 24             	mov    (%esp),%eax
  8013bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8013bf:	89 fa                	mov    %edi,%edx
  8013c1:	d3 e0                	shl    %cl,%eax
  8013c3:	89 f1                	mov    %esi,%ecx
  8013c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013cd:	d3 ea                	shr    %cl,%edx
  8013cf:	89 e9                	mov    %ebp,%ecx
  8013d1:	d3 e7                	shl    %cl,%edi
  8013d3:	89 f1                	mov    %esi,%ecx
  8013d5:	d3 e8                	shr    %cl,%eax
  8013d7:	89 e9                	mov    %ebp,%ecx
  8013d9:	09 f8                	or     %edi,%eax
  8013db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013df:	f7 74 24 04          	divl   0x4(%esp)
  8013e3:	d3 e7                	shl    %cl,%edi
  8013e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013e9:	89 d7                	mov    %edx,%edi
  8013eb:	f7 64 24 08          	mull   0x8(%esp)
  8013ef:	39 d7                	cmp    %edx,%edi
  8013f1:	89 c1                	mov    %eax,%ecx
  8013f3:	89 14 24             	mov    %edx,(%esp)
  8013f6:	72 2c                	jb     801424 <__umoddi3+0x134>
  8013f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8013fc:	72 22                	jb     801420 <__umoddi3+0x130>
  8013fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801402:	29 c8                	sub    %ecx,%eax
  801404:	19 d7                	sbb    %edx,%edi
  801406:	89 e9                	mov    %ebp,%ecx
  801408:	89 fa                	mov    %edi,%edx
  80140a:	d3 e8                	shr    %cl,%eax
  80140c:	89 f1                	mov    %esi,%ecx
  80140e:	d3 e2                	shl    %cl,%edx
  801410:	89 e9                	mov    %ebp,%ecx
  801412:	d3 ef                	shr    %cl,%edi
  801414:	09 d0                	or     %edx,%eax
  801416:	89 fa                	mov    %edi,%edx
  801418:	83 c4 14             	add    $0x14,%esp
  80141b:	5e                   	pop    %esi
  80141c:	5f                   	pop    %edi
  80141d:	5d                   	pop    %ebp
  80141e:	c3                   	ret    
  80141f:	90                   	nop
  801420:	39 d7                	cmp    %edx,%edi
  801422:	75 da                	jne    8013fe <__umoddi3+0x10e>
  801424:	8b 14 24             	mov    (%esp),%edx
  801427:	89 c1                	mov    %eax,%ecx
  801429:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80142d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801431:	eb cb                	jmp    8013fe <__umoddi3+0x10e>
  801433:	90                   	nop
  801434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801438:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80143c:	0f 82 0f ff ff ff    	jb     801351 <__umoddi3+0x61>
  801442:	e9 1a ff ff ff       	jmp    801361 <__umoddi3+0x71>
