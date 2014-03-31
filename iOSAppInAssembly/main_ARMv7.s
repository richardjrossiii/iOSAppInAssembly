// main_ARMv7.s
// This is the entry point of the application, in ARMv7 assembly.

// Firstly, we will setup all strings that will be used for the first part of this app.
// Then, we will setup an auto-release pool to manage our dangling objects,
// And finally, we will jump right into UIApplicationMain.

// Create a raw C string to hold the data for the App Delegate
.section __TEXT,__cstring
s_delegateClassNameCStr:
    .asciz "AppDelegate"

//
// Entry point of the application.
//
// Parameters:
//   None.
//
// Results:
//   r0: error code to return to OS.
//
// 
.section __TEXT,__text,regular,pure_instructions
.global _main
.align 4
_main:
    // Note: This was taken from the official ARMv7 calling conventions document:
    // https://developer.apple.com/library/ios/documentation/Xcode/Conceptual/iPhoneOSABIReference/Articles/ARMv7FunctionCallingConventions.html#//apple_ref/doc/uid/TP40009022-SW5
    // I will assume that it is the correct way to start and finish functions throughout the project.
    push     {r4-r7, lr}           // save LR, R7, R4-R6
    add      r7, sp, #12           // adjust R7 to point to saved R7
    push     {r8, r10, r11}        // save remaining GPRs (R8, R10, R11)
    vstmdb   sp!, {d8-d15}         // save VFP/Advanced SIMD registers D8

    // Setup the autorelease pool. This is done using the (non-documented) function objc_autoreleasePoolPush.
    //
    // It takes no parameters.
    //
    // It returns no results.
    bl _objc_autoreleasePoolPush

    // Setup our app delegate's class. This is done using our function AppDelegate_Setup.
    //
    // It takes no parameters.
    //
    // It returns no results.
    bl AppDelegate_Setup

    // Setup our custom view's class. This is done using our function View_Setup.
    //
    // It takes no parameters.
    //
    // It returns no results.
    bl View_Setup

    // Next, we need to actually start up the visual application. This is done in 2 steps.
    //
    // 1: Create a Objective-C string from a C-String for our App Delegate's name.
    // 2: Start the visual application.

    // Turn our C string into a NSString, using our function util_getCFString.
    //
    // Parameter 1 (r0) is the string we wish to convert.
    //
    // The newly created string object is stored in r0 after calling the function.
    mov r0, s_delegateClassNameCStr
    bl util_getCFString

    // The next step is to start the visual application. This is done using the function UIApplicationMain.
    //
    // Parameter 1 (r0) is the argument count passed to main. For the purposes of this demo, it is irrelevant.
    // Parameter 2 (r1) is the argument list passed to main. For the purposes of this demo, it is irrelevant.
    // Parameter 3 (r2) is the name of the principle class. This would be a subclass of UIApplication if we had one.
    // Parameter 4 (r3) is the name of the delegate class. This is our AppDelegate string.
    //
    // The result code of the application is stored in r0 after calling the function.
    mov r3, r0
    mov r2, #0
    mov r1, #0
    mov r0, #0
    bl _UIApplicationMain

    // Finally, we must clean up our auto-release pool. This is done using the function objc_autoreleasePoolPop.
    //
    // It takes no parameters.
    //
    // It returns no usable results. However, it clobbers r0, so we save and re-load that variable around it.
    push {r0}
    bl _objc_autoreleasePoolPop
    pop {r0}

    vldmia   sp!, {d8-d15}         // restore VFP/Advanced SIMD registers
    pop      {r8, r10, r11}        // restore R8-R11
    pop      {r4-r7, pc}           // restore R4-R6, saved R7, return to saved LR