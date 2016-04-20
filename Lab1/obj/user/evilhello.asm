
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 1e 00 00 00       	call   80004f <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800048:	e8 c5 00 00 00       	call   800112 <sys_cputs>
}
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    

0080004f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004f:	55                   	push   %ebp
  800050:	89 e5                	mov    %esp,%ebp
  800052:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 81 01 00 00       	call   8001db <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	c1 e0 02             	shl    $0x2,%eax
  800062:	89 c2                	mov    %eax,%edx
  800064:	c1 e2 05             	shl    $0x5,%edx
  800067:	29 c2                	sub    %eax,%edx
  800069:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80006f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800078:	7e 0a                	jle    800084 <libmain+0x35>
		binaryname = argv[0];
  80007a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80007d:	8b 00                	mov    (%eax),%eax
  80007f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800084:	8b 45 0c             	mov    0xc(%ebp),%eax
  800087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008b:	8b 45 08             	mov    0x8(%ebp),%eax
  80008e:	89 04 24             	mov    %eax,(%esp)
  800091:	e8 9d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800096:	e8 02 00 00 00       	call   80009d <exit>
}
  80009b:	c9                   	leave  
  80009c:	c3                   	ret    

0080009d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000aa:	e8 e9 00 00 00       	call   800198 <sys_env_destroy>
}
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    

008000b1 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	57                   	push   %edi
  8000b5:	56                   	push   %esi
  8000b6:	53                   	push   %ebx
  8000b7:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8000bd:	8b 55 10             	mov    0x10(%ebp),%edx
  8000c0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000c3:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000c6:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000c9:	8b 75 20             	mov    0x20(%ebp),%esi
  8000cc:	cd 30                	int    $0x30
  8000ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000d1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000d5:	74 30                	je     800107 <syscall+0x56>
  8000d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000db:	7e 2a                	jle    800107 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000eb:	c7 44 24 08 4a 14 80 	movl   $0x80144a,0x8(%esp)
  8000f2:	00 
  8000f3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000fa:	00 
  8000fb:	c7 04 24 67 14 80 00 	movl   $0x801467,(%esp)
  800102:	e8 2c 03 00 00       	call   800433 <_panic>

	return ret;
  800107:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  80010a:	83 c4 3c             	add    $0x3c,%esp
  80010d:	5b                   	pop    %ebx
  80010e:	5e                   	pop    %esi
  80010f:	5f                   	pop    %edi
  800110:	5d                   	pop    %ebp
  800111:	c3                   	ret    

00800112 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800118:	8b 45 08             	mov    0x8(%ebp),%eax
  80011b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800122:	00 
  800123:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80012a:	00 
  80012b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800132:	00 
  800133:	8b 55 0c             	mov    0xc(%ebp),%edx
  800136:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80013a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014d:	e8 5f ff ff ff       	call   8000b1 <syscall>
}
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <sys_cgetc>:

int
sys_cgetc(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80015a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800161:	00 
  800162:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800169:	00 
  80016a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800171:	00 
  800172:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800179:	00 
  80017a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800181:	00 
  800182:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800189:	00 
  80018a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800191:	e8 1b ff ff ff       	call   8000b1 <syscall>
}
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001a8:	00 
  8001a9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001b0:	00 
  8001b1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001b8:	00 
  8001b9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001c0:	00 
  8001c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001cc:	00 
  8001cd:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001d4:	e8 d8 fe ff ff       	call   8000b1 <syscall>
}
  8001d9:	c9                   	leave  
  8001da:	c3                   	ret    

008001db <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001e1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001e8:	00 
  8001e9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001f0:	00 
  8001f1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001f8:	00 
  8001f9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800200:	00 
  800201:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800208:	00 
  800209:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800210:	00 
  800211:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800218:	e8 94 fe ff ff       	call   8000b1 <syscall>
}
  80021d:	c9                   	leave  
  80021e:	c3                   	ret    

0080021f <sys_yield>:

void
sys_yield(void)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800225:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80022c:	00 
  80022d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800234:	00 
  800235:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80023c:	00 
  80023d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800244:	00 
  800245:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80024c:	00 
  80024d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800254:	00 
  800255:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80025c:	e8 50 fe ff ff       	call   8000b1 <syscall>
}
  800261:	c9                   	leave  
  800262:	c3                   	ret    

00800263 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800269:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80026c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80026f:	8b 45 08             	mov    0x8(%ebp),%eax
  800272:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800279:	00 
  80027a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800281:	00 
  800282:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800286:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80028a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800295:	00 
  800296:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80029d:	e8 0f fe ff ff       	call   8000b1 <syscall>
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	56                   	push   %esi
  8002a8:	53                   	push   %ebx
  8002a9:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8002ac:	8b 75 18             	mov    0x18(%ebp),%esi
  8002af:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bb:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002bf:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002cf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002d6:	00 
  8002d7:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002de:	e8 ce fd ff ff       	call   8000b1 <syscall>
}
  8002e3:	83 c4 20             	add    $0x20,%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002fd:	00 
  8002fe:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800305:	00 
  800306:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80030d:	00 
  80030e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800312:	89 44 24 08          	mov    %eax,0x8(%esp)
  800316:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80031d:	00 
  80031e:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800325:	e8 87 fd ff ff       	call   8000b1 <syscall>
}
  80032a:	c9                   	leave  
  80032b:	c3                   	ret    

0080032c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800332:	8b 55 0c             	mov    0xc(%ebp),%edx
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80033f:	00 
  800340:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800347:	00 
  800348:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80034f:	00 
  800350:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800354:	89 44 24 08          	mov    %eax,0x8(%esp)
  800358:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80035f:	00 
  800360:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800367:	e8 45 fd ff ff       	call   8000b1 <syscall>
}
  80036c:	c9                   	leave  
  80036d:	c3                   	ret    

0080036e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800374:	8b 55 0c             	mov    0xc(%ebp),%edx
  800377:	8b 45 08             	mov    0x8(%ebp),%eax
  80037a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800381:	00 
  800382:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800389:	00 
  80038a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800391:	00 
  800392:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800396:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8003a1:	00 
  8003a2:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8003a9:	e8 03 fd ff ff       	call   8000b1 <syscall>
}
  8003ae:	c9                   	leave  
  8003af:	c3                   	ret    

008003b0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003b6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003b9:	8b 55 10             	mov    0x10(%ebp),%edx
  8003bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bf:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003c6:	00 
  8003c7:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003cb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003e1:	00 
  8003e2:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003e9:	e8 c3 fc ff ff       	call   8000b1 <syscall>
}
  8003ee:	c9                   	leave  
  8003ef:	c3                   	ret    

008003f0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800400:	00 
  800401:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800408:	00 
  800409:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800410:	00 
  800411:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800418:	00 
  800419:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800424:	00 
  800425:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80042c:	e8 80 fc ff ff       	call   8000b1 <syscall>
}
  800431:	c9                   	leave  
  800432:	c3                   	ret    

00800433 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	53                   	push   %ebx
  800437:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80043a:	8d 45 14             	lea    0x14(%ebp),%eax
  80043d:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800440:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800446:	e8 90 fd ff ff       	call   8001db <sys_getenvid>
  80044b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800452:	8b 55 08             	mov    0x8(%ebp),%edx
  800455:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800459:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80045d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800461:	c7 04 24 78 14 80 00 	movl   $0x801478,(%esp)
  800468:	e8 e1 00 00 00       	call   80054e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80046d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800470:	89 44 24 04          	mov    %eax,0x4(%esp)
  800474:	8b 45 10             	mov    0x10(%ebp),%eax
  800477:	89 04 24             	mov    %eax,(%esp)
  80047a:	e8 6b 00 00 00       	call   8004ea <vcprintf>
	cprintf("\n");
  80047f:	c7 04 24 9b 14 80 00 	movl   $0x80149b,(%esp)
  800486:	e8 c3 00 00 00       	call   80054e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80048b:	cc                   	int3   
  80048c:	eb fd                	jmp    80048b <_panic+0x58>

0080048e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80048e:	55                   	push   %ebp
  80048f:	89 e5                	mov    %esp,%ebp
  800491:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800494:	8b 45 0c             	mov    0xc(%ebp),%eax
  800497:	8b 00                	mov    (%eax),%eax
  800499:	8d 48 01             	lea    0x1(%eax),%ecx
  80049c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049f:	89 0a                	mov    %ecx,(%edx)
  8004a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a4:	89 d1                	mov    %edx,%ecx
  8004a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a9:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b0:	8b 00                	mov    (%eax),%eax
  8004b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004b7:	75 20                	jne    8004d9 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bc:	8b 00                	mov    (%eax),%eax
  8004be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c1:	83 c2 08             	add    $0x8,%edx
  8004c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c8:	89 14 24             	mov    %edx,(%esp)
  8004cb:	e8 42 fc ff ff       	call   800112 <sys_cputs>
		b->idx = 0;
  8004d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8004d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004dc:	8b 40 04             	mov    0x4(%eax),%eax
  8004df:	8d 50 01             	lea    0x1(%eax),%edx
  8004e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e5:	89 50 04             	mov    %edx,0x4(%eax)
}
  8004e8:	c9                   	leave  
  8004e9:	c3                   	ret    

008004ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004fa:	00 00 00 
	b.cnt = 0;
  8004fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800504:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800507:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050e:	8b 45 08             	mov    0x8(%ebp),%eax
  800511:	89 44 24 08          	mov    %eax,0x8(%esp)
  800515:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80051b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051f:	c7 04 24 8e 04 80 00 	movl   $0x80048e,(%esp)
  800526:	e8 bd 01 00 00       	call   8006e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80052b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800531:	89 44 24 04          	mov    %eax,0x4(%esp)
  800535:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80053b:	83 c0 08             	add    $0x8,%eax
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	e8 cc fb ff ff       	call   800112 <sys_cputs>

	return b.cnt;
  800546:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80054c:	c9                   	leave  
  80054d:	c3                   	ret    

0080054e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80054e:	55                   	push   %ebp
  80054f:	89 e5                	mov    %esp,%ebp
  800551:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800554:	8d 45 0c             	lea    0xc(%ebp),%eax
  800557:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80055a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80055d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800561:	8b 45 08             	mov    0x8(%ebp),%eax
  800564:	89 04 24             	mov    %eax,(%esp)
  800567:	e8 7e ff ff ff       	call   8004ea <vcprintf>
  80056c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80056f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800572:	c9                   	leave  
  800573:	c3                   	ret    

00800574 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	53                   	push   %ebx
  800578:	83 ec 34             	sub    $0x34,%esp
  80057b:	8b 45 10             	mov    0x10(%ebp),%eax
  80057e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800587:	8b 45 18             	mov    0x18(%ebp),%eax
  80058a:	ba 00 00 00 00       	mov    $0x0,%edx
  80058f:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800592:	77 72                	ja     800606 <printnum+0x92>
  800594:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800597:	72 05                	jb     80059e <printnum+0x2a>
  800599:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80059c:	77 68                	ja     800606 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80059e:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8005a1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005a4:	8b 45 18             	mov    0x18(%ebp),%eax
  8005a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005ba:	89 04 24             	mov    %eax,(%esp)
  8005bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005c1:	e8 da 0b 00 00       	call   8011a0 <__udivdi3>
  8005c6:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005c9:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005cd:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005d1:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005d4:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ea:	89 04 24             	mov    %eax,(%esp)
  8005ed:	e8 82 ff ff ff       	call   800574 <printnum>
  8005f2:	eb 1c                	jmp    800610 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fb:	8b 45 20             	mov    0x20(%ebp),%eax
  8005fe:	89 04 24             	mov    %eax,(%esp)
  800601:	8b 45 08             	mov    0x8(%ebp),%eax
  800604:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800606:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80060a:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80060e:	7f e4                	jg     8005f4 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800610:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800613:	bb 00 00 00 00       	mov    $0x0,%ebx
  800618:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80061b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80061e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800622:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800626:	89 04 24             	mov    %eax,(%esp)
  800629:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062d:	e8 9e 0c 00 00       	call   8012d0 <__umoddi3>
  800632:	05 68 15 80 00       	add    $0x801568,%eax
  800637:	0f b6 00             	movzbl (%eax),%eax
  80063a:	0f be c0             	movsbl %al,%eax
  80063d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800640:	89 54 24 04          	mov    %edx,0x4(%esp)
  800644:	89 04 24             	mov    %eax,(%esp)
  800647:	8b 45 08             	mov    0x8(%ebp),%eax
  80064a:	ff d0                	call   *%eax
}
  80064c:	83 c4 34             	add    $0x34,%esp
  80064f:	5b                   	pop    %ebx
  800650:	5d                   	pop    %ebp
  800651:	c3                   	ret    

00800652 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800655:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800659:	7e 14                	jle    80066f <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80065b:	8b 45 08             	mov    0x8(%ebp),%eax
  80065e:	8b 00                	mov    (%eax),%eax
  800660:	8d 48 08             	lea    0x8(%eax),%ecx
  800663:	8b 55 08             	mov    0x8(%ebp),%edx
  800666:	89 0a                	mov    %ecx,(%edx)
  800668:	8b 50 04             	mov    0x4(%eax),%edx
  80066b:	8b 00                	mov    (%eax),%eax
  80066d:	eb 30                	jmp    80069f <getuint+0x4d>
	else if (lflag)
  80066f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800673:	74 16                	je     80068b <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800675:	8b 45 08             	mov    0x8(%ebp),%eax
  800678:	8b 00                	mov    (%eax),%eax
  80067a:	8d 48 04             	lea    0x4(%eax),%ecx
  80067d:	8b 55 08             	mov    0x8(%ebp),%edx
  800680:	89 0a                	mov    %ecx,(%edx)
  800682:	8b 00                	mov    (%eax),%eax
  800684:	ba 00 00 00 00       	mov    $0x0,%edx
  800689:	eb 14                	jmp    80069f <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80068b:	8b 45 08             	mov    0x8(%ebp),%eax
  80068e:	8b 00                	mov    (%eax),%eax
  800690:	8d 48 04             	lea    0x4(%eax),%ecx
  800693:	8b 55 08             	mov    0x8(%ebp),%edx
  800696:	89 0a                	mov    %ecx,(%edx)
  800698:	8b 00                	mov    (%eax),%eax
  80069a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80069f:	5d                   	pop    %ebp
  8006a0:	c3                   	ret    

008006a1 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006a1:	55                   	push   %ebp
  8006a2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006a4:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006a8:	7e 14                	jle    8006be <getint+0x1d>
		return va_arg(*ap, long long);
  8006aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ad:	8b 00                	mov    (%eax),%eax
  8006af:	8d 48 08             	lea    0x8(%eax),%ecx
  8006b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b5:	89 0a                	mov    %ecx,(%edx)
  8006b7:	8b 50 04             	mov    0x4(%eax),%edx
  8006ba:	8b 00                	mov    (%eax),%eax
  8006bc:	eb 28                	jmp    8006e6 <getint+0x45>
	else if (lflag)
  8006be:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006c2:	74 12                	je     8006d6 <getint+0x35>
		return va_arg(*ap, long);
  8006c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c7:	8b 00                	mov    (%eax),%eax
  8006c9:	8d 48 04             	lea    0x4(%eax),%ecx
  8006cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8006cf:	89 0a                	mov    %ecx,(%edx)
  8006d1:	8b 00                	mov    (%eax),%eax
  8006d3:	99                   	cltd   
  8006d4:	eb 10                	jmp    8006e6 <getint+0x45>
	else
		return va_arg(*ap, int);
  8006d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d9:	8b 00                	mov    (%eax),%eax
  8006db:	8d 48 04             	lea    0x4(%eax),%ecx
  8006de:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e1:	89 0a                	mov    %ecx,(%edx)
  8006e3:	8b 00                	mov    (%eax),%eax
  8006e5:	99                   	cltd   
}
  8006e6:	5d                   	pop    %ebp
  8006e7:	c3                   	ret    

008006e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	56                   	push   %esi
  8006ec:	53                   	push   %ebx
  8006ed:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f0:	eb 18                	jmp    80070a <vprintfmt+0x22>
			if (ch == '\0')
  8006f2:	85 db                	test   %ebx,%ebx
  8006f4:	75 05                	jne    8006fb <vprintfmt+0x13>
				return;
  8006f6:	e9 05 04 00 00       	jmp    800b00 <vprintfmt+0x418>
			putch(ch, putdat);
  8006fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800702:	89 1c 24             	mov    %ebx,(%esp)
  800705:	8b 45 08             	mov    0x8(%ebp),%eax
  800708:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80070a:	8b 45 10             	mov    0x10(%ebp),%eax
  80070d:	8d 50 01             	lea    0x1(%eax),%edx
  800710:	89 55 10             	mov    %edx,0x10(%ebp)
  800713:	0f b6 00             	movzbl (%eax),%eax
  800716:	0f b6 d8             	movzbl %al,%ebx
  800719:	83 fb 25             	cmp    $0x25,%ebx
  80071c:	75 d4                	jne    8006f2 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80071e:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800722:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800729:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800730:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800737:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073e:	8b 45 10             	mov    0x10(%ebp),%eax
  800741:	8d 50 01             	lea    0x1(%eax),%edx
  800744:	89 55 10             	mov    %edx,0x10(%ebp)
  800747:	0f b6 00             	movzbl (%eax),%eax
  80074a:	0f b6 d8             	movzbl %al,%ebx
  80074d:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800750:	83 f8 55             	cmp    $0x55,%eax
  800753:	0f 87 76 03 00 00    	ja     800acf <vprintfmt+0x3e7>
  800759:	8b 04 85 8c 15 80 00 	mov    0x80158c(,%eax,4),%eax
  800760:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800762:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800766:	eb d6                	jmp    80073e <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800768:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80076c:	eb d0                	jmp    80073e <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80076e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800775:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800778:	89 d0                	mov    %edx,%eax
  80077a:	c1 e0 02             	shl    $0x2,%eax
  80077d:	01 d0                	add    %edx,%eax
  80077f:	01 c0                	add    %eax,%eax
  800781:	01 d8                	add    %ebx,%eax
  800783:	83 e8 30             	sub    $0x30,%eax
  800786:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800789:	8b 45 10             	mov    0x10(%ebp),%eax
  80078c:	0f b6 00             	movzbl (%eax),%eax
  80078f:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800792:	83 fb 2f             	cmp    $0x2f,%ebx
  800795:	7e 0b                	jle    8007a2 <vprintfmt+0xba>
  800797:	83 fb 39             	cmp    $0x39,%ebx
  80079a:	7f 06                	jg     8007a2 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80079c:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007a0:	eb d3                	jmp    800775 <vprintfmt+0x8d>
			goto process_precision;
  8007a2:	eb 33                	jmp    8007d7 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8d 50 04             	lea    0x4(%eax),%edx
  8007aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ad:	8b 00                	mov    (%eax),%eax
  8007af:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007b2:	eb 23                	jmp    8007d7 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007b8:	79 0c                	jns    8007c6 <vprintfmt+0xde>
				width = 0;
  8007ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007c1:	e9 78 ff ff ff       	jmp    80073e <vprintfmt+0x56>
  8007c6:	e9 73 ff ff ff       	jmp    80073e <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007cb:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007d2:	e9 67 ff ff ff       	jmp    80073e <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8007d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007db:	79 12                	jns    8007ef <vprintfmt+0x107>
				width = precision, precision = -1;
  8007dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007e3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8007ea:	e9 4f ff ff ff       	jmp    80073e <vprintfmt+0x56>
  8007ef:	e9 4a ff ff ff       	jmp    80073e <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007f4:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8007f8:	e9 41 ff ff ff       	jmp    80073e <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8d 50 04             	lea    0x4(%eax),%edx
  800803:	89 55 14             	mov    %edx,0x14(%ebp)
  800806:	8b 00                	mov    (%eax),%eax
  800808:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80080f:	89 04 24             	mov    %eax,(%esp)
  800812:	8b 45 08             	mov    0x8(%ebp),%eax
  800815:	ff d0                	call   *%eax
			break;
  800817:	e9 de 02 00 00       	jmp    800afa <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80081c:	8b 45 14             	mov    0x14(%ebp),%eax
  80081f:	8d 50 04             	lea    0x4(%eax),%edx
  800822:	89 55 14             	mov    %edx,0x14(%ebp)
  800825:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800827:	85 db                	test   %ebx,%ebx
  800829:	79 02                	jns    80082d <vprintfmt+0x145>
				err = -err;
  80082b:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80082d:	83 fb 09             	cmp    $0x9,%ebx
  800830:	7f 0b                	jg     80083d <vprintfmt+0x155>
  800832:	8b 34 9d 40 15 80 00 	mov    0x801540(,%ebx,4),%esi
  800839:	85 f6                	test   %esi,%esi
  80083b:	75 23                	jne    800860 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  80083d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800841:	c7 44 24 08 79 15 80 	movl   $0x801579,0x8(%esp)
  800848:	00 
  800849:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	89 04 24             	mov    %eax,(%esp)
  800856:	e8 ac 02 00 00       	call   800b07 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80085b:	e9 9a 02 00 00       	jmp    800afa <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800860:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800864:	c7 44 24 08 82 15 80 	movl   $0x801582,0x8(%esp)
  80086b:	00 
  80086c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	89 04 24             	mov    %eax,(%esp)
  800879:	e8 89 02 00 00       	call   800b07 <printfmt>
			break;
  80087e:	e9 77 02 00 00       	jmp    800afa <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800883:	8b 45 14             	mov    0x14(%ebp),%eax
  800886:	8d 50 04             	lea    0x4(%eax),%edx
  800889:	89 55 14             	mov    %edx,0x14(%ebp)
  80088c:	8b 30                	mov    (%eax),%esi
  80088e:	85 f6                	test   %esi,%esi
  800890:	75 05                	jne    800897 <vprintfmt+0x1af>
				p = "(null)";
  800892:	be 85 15 80 00       	mov    $0x801585,%esi
			if (width > 0 && padc != '-')
  800897:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80089b:	7e 37                	jle    8008d4 <vprintfmt+0x1ec>
  80089d:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8008a1:	74 31                	je     8008d4 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008aa:	89 34 24             	mov    %esi,(%esp)
  8008ad:	e8 72 03 00 00       	call   800c24 <strnlen>
  8008b2:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008b5:	eb 17                	jmp    8008ce <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008b7:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c2:	89 04 24             	mov    %eax,(%esp)
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ca:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008d2:	7f e3                	jg     8008b7 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008d4:	eb 38                	jmp    80090e <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8008d6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008da:	74 1f                	je     8008fb <vprintfmt+0x213>
  8008dc:	83 fb 1f             	cmp    $0x1f,%ebx
  8008df:	7e 05                	jle    8008e6 <vprintfmt+0x1fe>
  8008e1:	83 fb 7e             	cmp    $0x7e,%ebx
  8008e4:	7e 15                	jle    8008fb <vprintfmt+0x213>
					putch('?', putdat);
  8008e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ed:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	ff d0                	call   *%eax
  8008f9:	eb 0f                	jmp    80090a <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8008fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800902:	89 1c 24             	mov    %ebx,(%esp)
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80090a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80090e:	89 f0                	mov    %esi,%eax
  800910:	8d 70 01             	lea    0x1(%eax),%esi
  800913:	0f b6 00             	movzbl (%eax),%eax
  800916:	0f be d8             	movsbl %al,%ebx
  800919:	85 db                	test   %ebx,%ebx
  80091b:	74 10                	je     80092d <vprintfmt+0x245>
  80091d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800921:	78 b3                	js     8008d6 <vprintfmt+0x1ee>
  800923:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800927:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80092b:	79 a9                	jns    8008d6 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80092d:	eb 17                	jmp    800946 <vprintfmt+0x25e>
				putch(' ', putdat);
  80092f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800932:	89 44 24 04          	mov    %eax,0x4(%esp)
  800936:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800942:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800946:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80094a:	7f e3                	jg     80092f <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80094c:	e9 a9 01 00 00       	jmp    800afa <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800951:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800954:	89 44 24 04          	mov    %eax,0x4(%esp)
  800958:	8d 45 14             	lea    0x14(%ebp),%eax
  80095b:	89 04 24             	mov    %eax,(%esp)
  80095e:	e8 3e fd ff ff       	call   8006a1 <getint>
  800963:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800966:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800969:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80096c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80096f:	85 d2                	test   %edx,%edx
  800971:	79 26                	jns    800999 <vprintfmt+0x2b1>
				putch('-', putdat);
  800973:	8b 45 0c             	mov    0xc(%ebp),%eax
  800976:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097a:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	ff d0                	call   *%eax
				num = -(long long) num;
  800986:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800989:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80098c:	f7 d8                	neg    %eax
  80098e:	83 d2 00             	adc    $0x0,%edx
  800991:	f7 da                	neg    %edx
  800993:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800996:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800999:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009a0:	e9 e1 00 00 00       	jmp    800a86 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8009af:	89 04 24             	mov    %eax,(%esp)
  8009b2:	e8 9b fc ff ff       	call   800652 <getuint>
  8009b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009bd:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009c4:	e9 bd 00 00 00       	jmp    800a86 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  8009c9:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  8009d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009da:	89 04 24             	mov    %eax,(%esp)
  8009dd:	e8 70 fc ff ff       	call   800652 <getuint>
  8009e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009e5:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  8009e8:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8009ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ef:	89 54 24 18          	mov    %edx,0x18(%esp)
  8009f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009f6:	89 54 24 14          	mov    %edx,0x14(%esp)
  8009fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a04:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a08:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	89 04 24             	mov    %eax,(%esp)
  800a19:	e8 56 fb ff ff       	call   800574 <printnum>
			break;
  800a1e:	e9 d7 00 00 00       	jmp    800afa <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  800a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a31:	8b 45 08             	mov    0x8(%ebp),%eax
  800a34:	ff d0                	call   *%eax
			putch('x', putdat);
  800a36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a39:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a49:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4c:	8d 50 04             	lea    0x4(%eax),%edx
  800a4f:	89 55 14             	mov    %edx,0x14(%ebp)
  800a52:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a54:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a5e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a65:	eb 1f                	jmp    800a86 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a67:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6e:	8d 45 14             	lea    0x14(%ebp),%eax
  800a71:	89 04 24             	mov    %eax,(%esp)
  800a74:	e8 d9 fb ff ff       	call   800652 <getuint>
  800a79:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a7c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a7f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a86:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a8d:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a91:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a94:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a98:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aa2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800aaa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aad:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	89 04 24             	mov    %eax,(%esp)
  800ab7:	e8 b8 fa ff ff       	call   800574 <printnum>
			break;
  800abc:	eb 3c                	jmp    800afa <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac5:	89 1c 24             	mov    %ebx,(%esp)
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	ff d0                	call   *%eax
			break;
  800acd:	eb 2b                	jmp    800afa <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800acf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ae2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ae6:	eb 04                	jmp    800aec <vprintfmt+0x404>
  800ae8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aec:	8b 45 10             	mov    0x10(%ebp),%eax
  800aef:	83 e8 01             	sub    $0x1,%eax
  800af2:	0f b6 00             	movzbl (%eax),%eax
  800af5:	3c 25                	cmp    $0x25,%al
  800af7:	75 ef                	jne    800ae8 <vprintfmt+0x400>
				/* do nothing */;
			break;
  800af9:	90                   	nop
		}
	}
  800afa:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800afb:	e9 0a fc ff ff       	jmp    80070a <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b00:	83 c4 40             	add    $0x40,%esp
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b0d:	8d 45 14             	lea    0x14(%ebp),%eax
  800b10:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b16:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b1a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	89 04 24             	mov    %eax,(%esp)
  800b2e:	e8 b5 fb ff ff       	call   8006e8 <vprintfmt>
	va_end(ap);
}
  800b33:	c9                   	leave  
  800b34:	c3                   	ret    

00800b35 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3b:	8b 40 08             	mov    0x8(%eax),%eax
  800b3e:	8d 50 01             	lea    0x1(%eax),%edx
  800b41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b44:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4a:	8b 10                	mov    (%eax),%edx
  800b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4f:	8b 40 04             	mov    0x4(%eax),%eax
  800b52:	39 c2                	cmp    %eax,%edx
  800b54:	73 12                	jae    800b68 <sprintputch+0x33>
		*b->buf++ = ch;
  800b56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b59:	8b 00                	mov    (%eax),%eax
  800b5b:	8d 48 01             	lea    0x1(%eax),%ecx
  800b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b61:	89 0a                	mov    %ecx,(%edx)
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
  800b66:	88 10                	mov    %dl,(%eax)
}
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b79:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7f:	01 d0                	add    %edx,%eax
  800b81:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b84:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b8b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b8f:	74 06                	je     800b97 <vsnprintf+0x2d>
  800b91:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b95:	7f 07                	jg     800b9e <vsnprintf+0x34>
		return -E_INVAL;
  800b97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b9c:	eb 2a                	jmp    800bc8 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b9e:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ba5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bac:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800baf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb3:	c7 04 24 35 0b 80 00 	movl   $0x800b35,(%esp)
  800bba:	e8 29 fb ff ff       	call   8006e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bc2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bc8:	c9                   	leave  
  800bc9:	c3                   	ret    

00800bca <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bd0:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bdd:	8b 45 10             	mov    0x10(%ebp),%eax
  800be0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800beb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bee:	89 04 24             	mov    %eax,(%esp)
  800bf1:	e8 74 ff ff ff       	call   800b6a <vsnprintf>
  800bf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bfc:	c9                   	leave  
  800bfd:	c3                   	ret    

00800bfe <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c04:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c0b:	eb 08                	jmp    800c15 <strlen+0x17>
		n++;
  800c0d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c11:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c15:	8b 45 08             	mov    0x8(%ebp),%eax
  800c18:	0f b6 00             	movzbl (%eax),%eax
  800c1b:	84 c0                	test   %al,%al
  800c1d:	75 ee                	jne    800c0d <strlen+0xf>
		n++;
	return n;
  800c1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c22:	c9                   	leave  
  800c23:	c3                   	ret    

00800c24 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c2a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c31:	eb 0c                	jmp    800c3f <strnlen+0x1b>
		n++;
  800c33:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c37:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c3b:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c43:	74 0a                	je     800c4f <strnlen+0x2b>
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
  800c48:	0f b6 00             	movzbl (%eax),%eax
  800c4b:	84 c0                	test   %al,%al
  800c4d:	75 e4                	jne    800c33 <strnlen+0xf>
		n++;
	return n;
  800c4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c60:	90                   	nop
  800c61:	8b 45 08             	mov    0x8(%ebp),%eax
  800c64:	8d 50 01             	lea    0x1(%eax),%edx
  800c67:	89 55 08             	mov    %edx,0x8(%ebp)
  800c6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c70:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c73:	0f b6 12             	movzbl (%edx),%edx
  800c76:	88 10                	mov    %dl,(%eax)
  800c78:	0f b6 00             	movzbl (%eax),%eax
  800c7b:	84 c0                	test   %al,%al
  800c7d:	75 e2                	jne    800c61 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c82:	c9                   	leave  
  800c83:	c3                   	ret    

00800c84 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8d:	89 04 24             	mov    %eax,(%esp)
  800c90:	e8 69 ff ff ff       	call   800bfe <strlen>
  800c95:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c98:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9e:	01 c2                	add    %eax,%edx
  800ca0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca7:	89 14 24             	mov    %edx,(%esp)
  800caa:	e8 a5 ff ff ff       	call   800c54 <strcpy>
	return dst;
  800caf:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cb2:	c9                   	leave  
  800cb3:	c3                   	ret    

00800cb4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbd:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cc0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cc7:	eb 23                	jmp    800cec <strncpy+0x38>
		*dst++ = *src;
  800cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccc:	8d 50 01             	lea    0x1(%eax),%edx
  800ccf:	89 55 08             	mov    %edx,0x8(%ebp)
  800cd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd5:	0f b6 12             	movzbl (%edx),%edx
  800cd8:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800cda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdd:	0f b6 00             	movzbl (%eax),%eax
  800ce0:	84 c0                	test   %al,%al
  800ce2:	74 04                	je     800ce8 <strncpy+0x34>
			src++;
  800ce4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cef:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cf2:	72 d5                	jb     800cc9 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800cf4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800cf7:	c9                   	leave  
  800cf8:	c3                   	ret    

00800cf9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cff:	8b 45 08             	mov    0x8(%ebp),%eax
  800d02:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d09:	74 33                	je     800d3e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d0b:	eb 17                	jmp    800d24 <strlcpy+0x2b>
			*dst++ = *src++;
  800d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d10:	8d 50 01             	lea    0x1(%eax),%edx
  800d13:	89 55 08             	mov    %edx,0x8(%ebp)
  800d16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d19:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d1c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d1f:	0f b6 12             	movzbl (%edx),%edx
  800d22:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d24:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d28:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d2c:	74 0a                	je     800d38 <strlcpy+0x3f>
  800d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d31:	0f b6 00             	movzbl (%eax),%eax
  800d34:	84 c0                	test   %al,%al
  800d36:	75 d5                	jne    800d0d <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d41:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d44:	29 c2                	sub    %eax,%edx
  800d46:	89 d0                	mov    %edx,%eax
}
  800d48:	c9                   	leave  
  800d49:	c3                   	ret    

00800d4a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d4d:	eb 08                	jmp    800d57 <strcmp+0xd>
		p++, q++;
  800d4f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d53:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d57:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5a:	0f b6 00             	movzbl (%eax),%eax
  800d5d:	84 c0                	test   %al,%al
  800d5f:	74 10                	je     800d71 <strcmp+0x27>
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	0f b6 10             	movzbl (%eax),%edx
  800d67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6a:	0f b6 00             	movzbl (%eax),%eax
  800d6d:	38 c2                	cmp    %al,%dl
  800d6f:	74 de                	je     800d4f <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d71:	8b 45 08             	mov    0x8(%ebp),%eax
  800d74:	0f b6 00             	movzbl (%eax),%eax
  800d77:	0f b6 d0             	movzbl %al,%edx
  800d7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7d:	0f b6 00             	movzbl (%eax),%eax
  800d80:	0f b6 c0             	movzbl %al,%eax
  800d83:	29 c2                	sub    %eax,%edx
  800d85:	89 d0                	mov    %edx,%eax
}
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d8c:	eb 0c                	jmp    800d9a <strncmp+0x11>
		n--, p++, q++;
  800d8e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d92:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d96:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d9a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d9e:	74 1a                	je     800dba <strncmp+0x31>
  800da0:	8b 45 08             	mov    0x8(%ebp),%eax
  800da3:	0f b6 00             	movzbl (%eax),%eax
  800da6:	84 c0                	test   %al,%al
  800da8:	74 10                	je     800dba <strncmp+0x31>
  800daa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dad:	0f b6 10             	movzbl (%eax),%edx
  800db0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db3:	0f b6 00             	movzbl (%eax),%eax
  800db6:	38 c2                	cmp    %al,%dl
  800db8:	74 d4                	je     800d8e <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800dba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dbe:	75 07                	jne    800dc7 <strncmp+0x3e>
		return 0;
  800dc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc5:	eb 16                	jmp    800ddd <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dca:	0f b6 00             	movzbl (%eax),%eax
  800dcd:	0f b6 d0             	movzbl %al,%edx
  800dd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd3:	0f b6 00             	movzbl (%eax),%eax
  800dd6:	0f b6 c0             	movzbl %al,%eax
  800dd9:	29 c2                	sub    %eax,%edx
  800ddb:	89 d0                	mov    %edx,%eax
}
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	83 ec 04             	sub    $0x4,%esp
  800de5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de8:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800deb:	eb 14                	jmp    800e01 <strchr+0x22>
		if (*s == c)
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
  800df0:	0f b6 00             	movzbl (%eax),%eax
  800df3:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800df6:	75 05                	jne    800dfd <strchr+0x1e>
			return (char *) s;
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	eb 13                	jmp    800e10 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dfd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
  800e04:	0f b6 00             	movzbl (%eax),%eax
  800e07:	84 c0                	test   %al,%al
  800e09:	75 e2                	jne    800ded <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e10:	c9                   	leave  
  800e11:	c3                   	ret    

00800e12 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	83 ec 04             	sub    $0x4,%esp
  800e18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1b:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e1e:	eb 11                	jmp    800e31 <strfind+0x1f>
		if (*s == c)
  800e20:	8b 45 08             	mov    0x8(%ebp),%eax
  800e23:	0f b6 00             	movzbl (%eax),%eax
  800e26:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e29:	75 02                	jne    800e2d <strfind+0x1b>
			break;
  800e2b:	eb 0e                	jmp    800e3b <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e2d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e31:	8b 45 08             	mov    0x8(%ebp),%eax
  800e34:	0f b6 00             	movzbl (%eax),%eax
  800e37:	84 c0                	test   %al,%al
  800e39:	75 e5                	jne    800e20 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e3b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e3e:	c9                   	leave  
  800e3f:	c3                   	ret    

00800e40 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e44:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e48:	75 05                	jne    800e4f <memset+0xf>
		return v;
  800e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4d:	eb 5c                	jmp    800eab <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e52:	83 e0 03             	and    $0x3,%eax
  800e55:	85 c0                	test   %eax,%eax
  800e57:	75 41                	jne    800e9a <memset+0x5a>
  800e59:	8b 45 10             	mov    0x10(%ebp),%eax
  800e5c:	83 e0 03             	and    $0x3,%eax
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	75 37                	jne    800e9a <memset+0x5a>
		c &= 0xFF;
  800e63:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6d:	c1 e0 18             	shl    $0x18,%eax
  800e70:	89 c2                	mov    %eax,%edx
  800e72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e75:	c1 e0 10             	shl    $0x10,%eax
  800e78:	09 c2                	or     %eax,%edx
  800e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7d:	c1 e0 08             	shl    $0x8,%eax
  800e80:	09 d0                	or     %edx,%eax
  800e82:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e85:	8b 45 10             	mov    0x10(%ebp),%eax
  800e88:	c1 e8 02             	shr    $0x2,%eax
  800e8b:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e93:	89 d7                	mov    %edx,%edi
  800e95:	fc                   	cld    
  800e96:	f3 ab                	rep stos %eax,%es:(%edi)
  800e98:	eb 0e                	jmp    800ea8 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ea3:	89 d7                	mov    %edx,%edi
  800ea5:	fc                   	cld    
  800ea6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ea8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800eab:	5f                   	pop    %edi
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
  800eb4:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eba:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec0:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ec9:	73 6d                	jae    800f38 <memmove+0x8a>
  800ecb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ece:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ed1:	01 d0                	add    %edx,%eax
  800ed3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ed6:	76 60                	jbe    800f38 <memmove+0x8a>
		s += n;
  800ed8:	8b 45 10             	mov    0x10(%ebp),%eax
  800edb:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ede:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee1:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee7:	83 e0 03             	and    $0x3,%eax
  800eea:	85 c0                	test   %eax,%eax
  800eec:	75 2f                	jne    800f1d <memmove+0x6f>
  800eee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ef1:	83 e0 03             	and    $0x3,%eax
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	75 25                	jne    800f1d <memmove+0x6f>
  800ef8:	8b 45 10             	mov    0x10(%ebp),%eax
  800efb:	83 e0 03             	and    $0x3,%eax
  800efe:	85 c0                	test   %eax,%eax
  800f00:	75 1b                	jne    800f1d <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f02:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f05:	83 e8 04             	sub    $0x4,%eax
  800f08:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f0b:	83 ea 04             	sub    $0x4,%edx
  800f0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f11:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f14:	89 c7                	mov    %eax,%edi
  800f16:	89 d6                	mov    %edx,%esi
  800f18:	fd                   	std    
  800f19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f1b:	eb 18                	jmp    800f35 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f20:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f26:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f29:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2c:	89 d7                	mov    %edx,%edi
  800f2e:	89 de                	mov    %ebx,%esi
  800f30:	89 c1                	mov    %eax,%ecx
  800f32:	fd                   	std    
  800f33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f35:	fc                   	cld    
  800f36:	eb 45                	jmp    800f7d <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f3b:	83 e0 03             	and    $0x3,%eax
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	75 2b                	jne    800f6d <memmove+0xbf>
  800f42:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f45:	83 e0 03             	and    $0x3,%eax
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	75 21                	jne    800f6d <memmove+0xbf>
  800f4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4f:	83 e0 03             	and    $0x3,%eax
  800f52:	85 c0                	test   %eax,%eax
  800f54:	75 17                	jne    800f6d <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f56:	8b 45 10             	mov    0x10(%ebp),%eax
  800f59:	c1 e8 02             	shr    $0x2,%eax
  800f5c:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f61:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f64:	89 c7                	mov    %eax,%edi
  800f66:	89 d6                	mov    %edx,%esi
  800f68:	fc                   	cld    
  800f69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f6b:	eb 10                	jmp    800f7d <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f70:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f73:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f76:	89 c7                	mov    %eax,%edi
  800f78:	89 d6                	mov    %edx,%esi
  800f7a:	fc                   	cld    
  800f7b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f7d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f8e:	8b 45 10             	mov    0x10(%ebp),%eax
  800f91:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f98:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9f:	89 04 24             	mov    %eax,(%esp)
  800fa2:	e8 07 ff ff ff       	call   800eae <memmove>
}
  800fa7:	c9                   	leave  
  800fa8:	c3                   	ret    

00800fa9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800faf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb8:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fbb:	eb 30                	jmp    800fed <memcmp+0x44>
		if (*s1 != *s2)
  800fbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fc0:	0f b6 10             	movzbl (%eax),%edx
  800fc3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fc6:	0f b6 00             	movzbl (%eax),%eax
  800fc9:	38 c2                	cmp    %al,%dl
  800fcb:	74 18                	je     800fe5 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fcd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fd0:	0f b6 00             	movzbl (%eax),%eax
  800fd3:	0f b6 d0             	movzbl %al,%edx
  800fd6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fd9:	0f b6 00             	movzbl (%eax),%eax
  800fdc:	0f b6 c0             	movzbl %al,%eax
  800fdf:	29 c2                	sub    %eax,%edx
  800fe1:	89 d0                	mov    %edx,%eax
  800fe3:	eb 1a                	jmp    800fff <memcmp+0x56>
		s1++, s2++;
  800fe5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fe9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fed:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff0:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ff3:	89 55 10             	mov    %edx,0x10(%ebp)
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	75 c3                	jne    800fbd <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ffa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fff:	c9                   	leave  
  801000:	c3                   	ret    

00801001 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801007:	8b 45 10             	mov    0x10(%ebp),%eax
  80100a:	8b 55 08             	mov    0x8(%ebp),%edx
  80100d:	01 d0                	add    %edx,%eax
  80100f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801012:	eb 13                	jmp    801027 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801014:	8b 45 08             	mov    0x8(%ebp),%eax
  801017:	0f b6 10             	movzbl (%eax),%edx
  80101a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101d:	38 c2                	cmp    %al,%dl
  80101f:	75 02                	jne    801023 <memfind+0x22>
			break;
  801021:	eb 0c                	jmp    80102f <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801023:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801027:	8b 45 08             	mov    0x8(%ebp),%eax
  80102a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  80102d:	72 e5                	jb     801014 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  80102f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  80103a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801041:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801048:	eb 04                	jmp    80104e <strtol+0x1a>
		s++;
  80104a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80104e:	8b 45 08             	mov    0x8(%ebp),%eax
  801051:	0f b6 00             	movzbl (%eax),%eax
  801054:	3c 20                	cmp    $0x20,%al
  801056:	74 f2                	je     80104a <strtol+0x16>
  801058:	8b 45 08             	mov    0x8(%ebp),%eax
  80105b:	0f b6 00             	movzbl (%eax),%eax
  80105e:	3c 09                	cmp    $0x9,%al
  801060:	74 e8                	je     80104a <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801062:	8b 45 08             	mov    0x8(%ebp),%eax
  801065:	0f b6 00             	movzbl (%eax),%eax
  801068:	3c 2b                	cmp    $0x2b,%al
  80106a:	75 06                	jne    801072 <strtol+0x3e>
		s++;
  80106c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801070:	eb 15                	jmp    801087 <strtol+0x53>
	else if (*s == '-')
  801072:	8b 45 08             	mov    0x8(%ebp),%eax
  801075:	0f b6 00             	movzbl (%eax),%eax
  801078:	3c 2d                	cmp    $0x2d,%al
  80107a:	75 0b                	jne    801087 <strtol+0x53>
		s++, neg = 1;
  80107c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801080:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801087:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80108b:	74 06                	je     801093 <strtol+0x5f>
  80108d:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801091:	75 24                	jne    8010b7 <strtol+0x83>
  801093:	8b 45 08             	mov    0x8(%ebp),%eax
  801096:	0f b6 00             	movzbl (%eax),%eax
  801099:	3c 30                	cmp    $0x30,%al
  80109b:	75 1a                	jne    8010b7 <strtol+0x83>
  80109d:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a0:	83 c0 01             	add    $0x1,%eax
  8010a3:	0f b6 00             	movzbl (%eax),%eax
  8010a6:	3c 78                	cmp    $0x78,%al
  8010a8:	75 0d                	jne    8010b7 <strtol+0x83>
		s += 2, base = 16;
  8010aa:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010ae:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010b5:	eb 2a                	jmp    8010e1 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010bb:	75 17                	jne    8010d4 <strtol+0xa0>
  8010bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c0:	0f b6 00             	movzbl (%eax),%eax
  8010c3:	3c 30                	cmp    $0x30,%al
  8010c5:	75 0d                	jne    8010d4 <strtol+0xa0>
		s++, base = 8;
  8010c7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010cb:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010d2:	eb 0d                	jmp    8010e1 <strtol+0xad>
	else if (base == 0)
  8010d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010d8:	75 07                	jne    8010e1 <strtol+0xad>
		base = 10;
  8010da:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e4:	0f b6 00             	movzbl (%eax),%eax
  8010e7:	3c 2f                	cmp    $0x2f,%al
  8010e9:	7e 1b                	jle    801106 <strtol+0xd2>
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ee:	0f b6 00             	movzbl (%eax),%eax
  8010f1:	3c 39                	cmp    $0x39,%al
  8010f3:	7f 11                	jg     801106 <strtol+0xd2>
			dig = *s - '0';
  8010f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f8:	0f b6 00             	movzbl (%eax),%eax
  8010fb:	0f be c0             	movsbl %al,%eax
  8010fe:	83 e8 30             	sub    $0x30,%eax
  801101:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801104:	eb 48                	jmp    80114e <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801106:	8b 45 08             	mov    0x8(%ebp),%eax
  801109:	0f b6 00             	movzbl (%eax),%eax
  80110c:	3c 60                	cmp    $0x60,%al
  80110e:	7e 1b                	jle    80112b <strtol+0xf7>
  801110:	8b 45 08             	mov    0x8(%ebp),%eax
  801113:	0f b6 00             	movzbl (%eax),%eax
  801116:	3c 7a                	cmp    $0x7a,%al
  801118:	7f 11                	jg     80112b <strtol+0xf7>
			dig = *s - 'a' + 10;
  80111a:	8b 45 08             	mov    0x8(%ebp),%eax
  80111d:	0f b6 00             	movzbl (%eax),%eax
  801120:	0f be c0             	movsbl %al,%eax
  801123:	83 e8 57             	sub    $0x57,%eax
  801126:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801129:	eb 23                	jmp    80114e <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  80112b:	8b 45 08             	mov    0x8(%ebp),%eax
  80112e:	0f b6 00             	movzbl (%eax),%eax
  801131:	3c 40                	cmp    $0x40,%al
  801133:	7e 3d                	jle    801172 <strtol+0x13e>
  801135:	8b 45 08             	mov    0x8(%ebp),%eax
  801138:	0f b6 00             	movzbl (%eax),%eax
  80113b:	3c 5a                	cmp    $0x5a,%al
  80113d:	7f 33                	jg     801172 <strtol+0x13e>
			dig = *s - 'A' + 10;
  80113f:	8b 45 08             	mov    0x8(%ebp),%eax
  801142:	0f b6 00             	movzbl (%eax),%eax
  801145:	0f be c0             	movsbl %al,%eax
  801148:	83 e8 37             	sub    $0x37,%eax
  80114b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  80114e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801151:	3b 45 10             	cmp    0x10(%ebp),%eax
  801154:	7c 02                	jl     801158 <strtol+0x124>
			break;
  801156:	eb 1a                	jmp    801172 <strtol+0x13e>
		s++, val = (val * base) + dig;
  801158:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80115c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80115f:	0f af 45 10          	imul   0x10(%ebp),%eax
  801163:	89 c2                	mov    %eax,%edx
  801165:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801168:	01 d0                	add    %edx,%eax
  80116a:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  80116d:	e9 6f ff ff ff       	jmp    8010e1 <strtol+0xad>

	if (endptr)
  801172:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801176:	74 08                	je     801180 <strtol+0x14c>
		*endptr = (char *) s;
  801178:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117b:	8b 55 08             	mov    0x8(%ebp),%edx
  80117e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801180:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801184:	74 07                	je     80118d <strtol+0x159>
  801186:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801189:	f7 d8                	neg    %eax
  80118b:	eb 03                	jmp    801190 <strtol+0x15c>
  80118d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801190:	c9                   	leave  
  801191:	c3                   	ret    
  801192:	66 90                	xchg   %ax,%ax
  801194:	66 90                	xchg   %ax,%ax
  801196:	66 90                	xchg   %ax,%ax
  801198:	66 90                	xchg   %ax,%ax
  80119a:	66 90                	xchg   %ax,%ax
  80119c:	66 90                	xchg   %ax,%ax
  80119e:	66 90                	xchg   %ax,%ax

008011a0 <__udivdi3>:
  8011a0:	55                   	push   %ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011aa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011ae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011b2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011bc:	89 ea                	mov    %ebp,%edx
  8011be:	89 0c 24             	mov    %ecx,(%esp)
  8011c1:	75 2d                	jne    8011f0 <__udivdi3+0x50>
  8011c3:	39 e9                	cmp    %ebp,%ecx
  8011c5:	77 61                	ja     801228 <__udivdi3+0x88>
  8011c7:	85 c9                	test   %ecx,%ecx
  8011c9:	89 ce                	mov    %ecx,%esi
  8011cb:	75 0b                	jne    8011d8 <__udivdi3+0x38>
  8011cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d2:	31 d2                	xor    %edx,%edx
  8011d4:	f7 f1                	div    %ecx
  8011d6:	89 c6                	mov    %eax,%esi
  8011d8:	31 d2                	xor    %edx,%edx
  8011da:	89 e8                	mov    %ebp,%eax
  8011dc:	f7 f6                	div    %esi
  8011de:	89 c5                	mov    %eax,%ebp
  8011e0:	89 f8                	mov    %edi,%eax
  8011e2:	f7 f6                	div    %esi
  8011e4:	89 ea                	mov    %ebp,%edx
  8011e6:	83 c4 0c             	add    $0xc,%esp
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    
  8011ed:	8d 76 00             	lea    0x0(%esi),%esi
  8011f0:	39 e8                	cmp    %ebp,%eax
  8011f2:	77 24                	ja     801218 <__udivdi3+0x78>
  8011f4:	0f bd e8             	bsr    %eax,%ebp
  8011f7:	83 f5 1f             	xor    $0x1f,%ebp
  8011fa:	75 3c                	jne    801238 <__udivdi3+0x98>
  8011fc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801200:	39 34 24             	cmp    %esi,(%esp)
  801203:	0f 86 9f 00 00 00    	jbe    8012a8 <__udivdi3+0x108>
  801209:	39 d0                	cmp    %edx,%eax
  80120b:	0f 82 97 00 00 00    	jb     8012a8 <__udivdi3+0x108>
  801211:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801218:	31 d2                	xor    %edx,%edx
  80121a:	31 c0                	xor    %eax,%eax
  80121c:	83 c4 0c             	add    $0xc,%esp
  80121f:	5e                   	pop    %esi
  801220:	5f                   	pop    %edi
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    
  801223:	90                   	nop
  801224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801228:	89 f8                	mov    %edi,%eax
  80122a:	f7 f1                	div    %ecx
  80122c:	31 d2                	xor    %edx,%edx
  80122e:	83 c4 0c             	add    $0xc,%esp
  801231:	5e                   	pop    %esi
  801232:	5f                   	pop    %edi
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    
  801235:	8d 76 00             	lea    0x0(%esi),%esi
  801238:	89 e9                	mov    %ebp,%ecx
  80123a:	8b 3c 24             	mov    (%esp),%edi
  80123d:	d3 e0                	shl    %cl,%eax
  80123f:	89 c6                	mov    %eax,%esi
  801241:	b8 20 00 00 00       	mov    $0x20,%eax
  801246:	29 e8                	sub    %ebp,%eax
  801248:	89 c1                	mov    %eax,%ecx
  80124a:	d3 ef                	shr    %cl,%edi
  80124c:	89 e9                	mov    %ebp,%ecx
  80124e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801252:	8b 3c 24             	mov    (%esp),%edi
  801255:	09 74 24 08          	or     %esi,0x8(%esp)
  801259:	89 d6                	mov    %edx,%esi
  80125b:	d3 e7                	shl    %cl,%edi
  80125d:	89 c1                	mov    %eax,%ecx
  80125f:	89 3c 24             	mov    %edi,(%esp)
  801262:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801266:	d3 ee                	shr    %cl,%esi
  801268:	89 e9                	mov    %ebp,%ecx
  80126a:	d3 e2                	shl    %cl,%edx
  80126c:	89 c1                	mov    %eax,%ecx
  80126e:	d3 ef                	shr    %cl,%edi
  801270:	09 d7                	or     %edx,%edi
  801272:	89 f2                	mov    %esi,%edx
  801274:	89 f8                	mov    %edi,%eax
  801276:	f7 74 24 08          	divl   0x8(%esp)
  80127a:	89 d6                	mov    %edx,%esi
  80127c:	89 c7                	mov    %eax,%edi
  80127e:	f7 24 24             	mull   (%esp)
  801281:	39 d6                	cmp    %edx,%esi
  801283:	89 14 24             	mov    %edx,(%esp)
  801286:	72 30                	jb     8012b8 <__udivdi3+0x118>
  801288:	8b 54 24 04          	mov    0x4(%esp),%edx
  80128c:	89 e9                	mov    %ebp,%ecx
  80128e:	d3 e2                	shl    %cl,%edx
  801290:	39 c2                	cmp    %eax,%edx
  801292:	73 05                	jae    801299 <__udivdi3+0xf9>
  801294:	3b 34 24             	cmp    (%esp),%esi
  801297:	74 1f                	je     8012b8 <__udivdi3+0x118>
  801299:	89 f8                	mov    %edi,%eax
  80129b:	31 d2                	xor    %edx,%edx
  80129d:	e9 7a ff ff ff       	jmp    80121c <__udivdi3+0x7c>
  8012a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a8:	31 d2                	xor    %edx,%edx
  8012aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8012af:	e9 68 ff ff ff       	jmp    80121c <__udivdi3+0x7c>
  8012b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012bb:	31 d2                	xor    %edx,%edx
  8012bd:	83 c4 0c             	add    $0xc,%esp
  8012c0:	5e                   	pop    %esi
  8012c1:	5f                   	pop    %edi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    
  8012c4:	66 90                	xchg   %ax,%ax
  8012c6:	66 90                	xchg   %ax,%ax
  8012c8:	66 90                	xchg   %ax,%ax
  8012ca:	66 90                	xchg   %ax,%ax
  8012cc:	66 90                	xchg   %ax,%ax
  8012ce:	66 90                	xchg   %ax,%ax

008012d0 <__umoddi3>:
  8012d0:	55                   	push   %ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	83 ec 14             	sub    $0x14,%esp
  8012d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012de:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8012e2:	89 c7                	mov    %eax,%edi
  8012e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8012ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012f0:	89 34 24             	mov    %esi,(%esp)
  8012f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ff:	75 17                	jne    801318 <__umoddi3+0x48>
  801301:	39 fe                	cmp    %edi,%esi
  801303:	76 4b                	jbe    801350 <__umoddi3+0x80>
  801305:	89 c8                	mov    %ecx,%eax
  801307:	89 fa                	mov    %edi,%edx
  801309:	f7 f6                	div    %esi
  80130b:	89 d0                	mov    %edx,%eax
  80130d:	31 d2                	xor    %edx,%edx
  80130f:	83 c4 14             	add    $0x14,%esp
  801312:	5e                   	pop    %esi
  801313:	5f                   	pop    %edi
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    
  801316:	66 90                	xchg   %ax,%ax
  801318:	39 f8                	cmp    %edi,%eax
  80131a:	77 54                	ja     801370 <__umoddi3+0xa0>
  80131c:	0f bd e8             	bsr    %eax,%ebp
  80131f:	83 f5 1f             	xor    $0x1f,%ebp
  801322:	75 5c                	jne    801380 <__umoddi3+0xb0>
  801324:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801328:	39 3c 24             	cmp    %edi,(%esp)
  80132b:	0f 87 e7 00 00 00    	ja     801418 <__umoddi3+0x148>
  801331:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801335:	29 f1                	sub    %esi,%ecx
  801337:	19 c7                	sbb    %eax,%edi
  801339:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80133d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801341:	8b 44 24 08          	mov    0x8(%esp),%eax
  801345:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801349:	83 c4 14             	add    $0x14,%esp
  80134c:	5e                   	pop    %esi
  80134d:	5f                   	pop    %edi
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    
  801350:	85 f6                	test   %esi,%esi
  801352:	89 f5                	mov    %esi,%ebp
  801354:	75 0b                	jne    801361 <__umoddi3+0x91>
  801356:	b8 01 00 00 00       	mov    $0x1,%eax
  80135b:	31 d2                	xor    %edx,%edx
  80135d:	f7 f6                	div    %esi
  80135f:	89 c5                	mov    %eax,%ebp
  801361:	8b 44 24 04          	mov    0x4(%esp),%eax
  801365:	31 d2                	xor    %edx,%edx
  801367:	f7 f5                	div    %ebp
  801369:	89 c8                	mov    %ecx,%eax
  80136b:	f7 f5                	div    %ebp
  80136d:	eb 9c                	jmp    80130b <__umoddi3+0x3b>
  80136f:	90                   	nop
  801370:	89 c8                	mov    %ecx,%eax
  801372:	89 fa                	mov    %edi,%edx
  801374:	83 c4 14             	add    $0x14,%esp
  801377:	5e                   	pop    %esi
  801378:	5f                   	pop    %edi
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    
  80137b:	90                   	nop
  80137c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801380:	8b 04 24             	mov    (%esp),%eax
  801383:	be 20 00 00 00       	mov    $0x20,%esi
  801388:	89 e9                	mov    %ebp,%ecx
  80138a:	29 ee                	sub    %ebp,%esi
  80138c:	d3 e2                	shl    %cl,%edx
  80138e:	89 f1                	mov    %esi,%ecx
  801390:	d3 e8                	shr    %cl,%eax
  801392:	89 e9                	mov    %ebp,%ecx
  801394:	89 44 24 04          	mov    %eax,0x4(%esp)
  801398:	8b 04 24             	mov    (%esp),%eax
  80139b:	09 54 24 04          	or     %edx,0x4(%esp)
  80139f:	89 fa                	mov    %edi,%edx
  8013a1:	d3 e0                	shl    %cl,%eax
  8013a3:	89 f1                	mov    %esi,%ecx
  8013a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013ad:	d3 ea                	shr    %cl,%edx
  8013af:	89 e9                	mov    %ebp,%ecx
  8013b1:	d3 e7                	shl    %cl,%edi
  8013b3:	89 f1                	mov    %esi,%ecx
  8013b5:	d3 e8                	shr    %cl,%eax
  8013b7:	89 e9                	mov    %ebp,%ecx
  8013b9:	09 f8                	or     %edi,%eax
  8013bb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013bf:	f7 74 24 04          	divl   0x4(%esp)
  8013c3:	d3 e7                	shl    %cl,%edi
  8013c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013c9:	89 d7                	mov    %edx,%edi
  8013cb:	f7 64 24 08          	mull   0x8(%esp)
  8013cf:	39 d7                	cmp    %edx,%edi
  8013d1:	89 c1                	mov    %eax,%ecx
  8013d3:	89 14 24             	mov    %edx,(%esp)
  8013d6:	72 2c                	jb     801404 <__umoddi3+0x134>
  8013d8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8013dc:	72 22                	jb     801400 <__umoddi3+0x130>
  8013de:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013e2:	29 c8                	sub    %ecx,%eax
  8013e4:	19 d7                	sbb    %edx,%edi
  8013e6:	89 e9                	mov    %ebp,%ecx
  8013e8:	89 fa                	mov    %edi,%edx
  8013ea:	d3 e8                	shr    %cl,%eax
  8013ec:	89 f1                	mov    %esi,%ecx
  8013ee:	d3 e2                	shl    %cl,%edx
  8013f0:	89 e9                	mov    %ebp,%ecx
  8013f2:	d3 ef                	shr    %cl,%edi
  8013f4:	09 d0                	or     %edx,%eax
  8013f6:	89 fa                	mov    %edi,%edx
  8013f8:	83 c4 14             	add    $0x14,%esp
  8013fb:	5e                   	pop    %esi
  8013fc:	5f                   	pop    %edi
  8013fd:	5d                   	pop    %ebp
  8013fe:	c3                   	ret    
  8013ff:	90                   	nop
  801400:	39 d7                	cmp    %edx,%edi
  801402:	75 da                	jne    8013de <__umoddi3+0x10e>
  801404:	8b 14 24             	mov    (%esp),%edx
  801407:	89 c1                	mov    %eax,%ecx
  801409:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80140d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801411:	eb cb                	jmp    8013de <__umoddi3+0x10e>
  801413:	90                   	nop
  801414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801418:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80141c:	0f 82 0f ff ff ff    	jb     801331 <__umoddi3+0x61>
  801422:	e9 1a ff ff ff       	jmp    801341 <__umoddi3+0x71>
