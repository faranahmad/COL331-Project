#ifndef JOS_KERN_USERPROG_H
#define JOS_KERN_USERPROG_H

#ifndef JOS_KERNEL
# error "This is a JOS kernel header; user programs should not #include it"
#endif

int User_Factorial(int argc, char** argv);
// int User_Fibonacci(int argc, char** argv);
// int User_Date(int argc, char** argv);
// int User_Echo(int argc, char** argv);
// int User_Cal(int argc, char** argv);

#endif