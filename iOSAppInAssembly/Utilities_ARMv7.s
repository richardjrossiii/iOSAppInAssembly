// Utilities_ARMv7.s
// This file contains a collection of utilities used throughout the application.


// Helper function to convert C-string to Objective-C string.
//
// Parameters:
//  r0: input pointer
// Results:
//  r0: result pointer
.section __TEXT,__text,regular,pure_instructions
.global util_getCFString
.align 4
util_getCFString:
    push     {r4-r7, lr}           // save LR, R7, R4-R6
    add      r7, sp, #12           // adjust R7 to point to saved R7
    push     {r8, r10, r11}        // save remaining GPRs (R8, R10, R11)
    vstmdb   sp!, {d8-d15}         // save VFP/Advanced SIMD registers D8

    // To convert our string, we are calling the function CFStringCreateWithCString.
    //
    // Parameter 1 (r0) is the allocator.
    // Parameter 2 (r1) is the string.
    // Parameter 3 (r2) is the encoding.
    //
    // Its resulting string will be stored in the r0 register.
    mov r1, r0
    mov r0, #0
    mov r2, #1536
    bl _CFStringCreateWithCString

    vldmia   sp!, {d8-d15}         // restore VFP/Advanced SIMD registers
    pop      {r8, r10, r11}        // restore R8-R11
    pop      {r4-r7, pc}           // restore R4-R6, saved R7, return to saved LR
