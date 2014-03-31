// AppDelegate_ARMv7.s
// This is the file that will contain the class for our application's delegate.

// Setup all strings that will be used in this file.
.section __TEXT,__cstring
AppDelegate_ParentClassName:
    .asciz "NSObject"

.section __TEXT,__cstring
AppDelegate_ClassName:
    .asciz "AppDelegate"

.section __TEXT,__cstring
AppDelegate_IvarName:
    .asciz "window"

.section __TEXT,__cstring
AppDelegate_IvarEncoding:
    .asciz "@"

.section __TEXT,__cstring
AppDelegate_MethodName:
    .asciz "application:didFinishLaunchingWithOptions:"

.section __TEXT,__cstring
AppDelegate_MethodEncoding:
    .asciz "c@:@@"

.section __TEXT,__cstring
AppDelegate_ScreenClassName:
    .asciz "UIScreen"

.section __TEXT,__cstring
AppDelegate_ScreenSingletonMethodName:
    .asciz "mainScreen"

.section __TEXT,__cstring
AppDelegate_ScreenSizePropertyName:
    .asciz "bounds"

.section __TEXT,__cstring
AppDelegate_WindowClassName:
    .asciz "UIWindow"

.section __TEXT,__cstring
AppDelegate_WindowAllocateMethodName:
    .asciz "alloc"

.section __TEXT,__cstring
AppDelegate_WindowInitMethodName:
    .asciz "initWithFrame:"

.section __TEXT,__cstring
AppDelegate_ViewControllerClassName:
    .asciz "UIViewController"

.section __TEXT,__cstring
AppDelegate_ViewControllerAllocateMethodName:
    .asciz "alloc"

.section __TEXT,__cstring
AppDelegate_ViewControllerInitMethodName:
    .asciz "init"

.section __TEXT,__cstring
AppDelegate_ViewControllerAttachViewMethodName:
    .asciz "setView:"

.section __TEXT,__cstring
AppDelegate_ViewControllerAttachMethodName:
    .asciz "setRootViewController:"

.section __TEXT,__cstring
AppDelegate_ViewClassName:
    .asciz "View"

.section __TEXT,__cstring
AppDelegate_ViewAllocateMethodName:
    .asciz "alloc"

.section __TEXT,__cstring
AppDelegate_ViewInitMethodName:
    .asciz "initWithFrame:"

.section __TEXT,__cstring
AppDelegate_WindowMakeVisibleMethodName:
    .asciz "makeKeyAndVisible"


// Global variable for holding the class.
.section __DATA,regular
.align 4
AppDelegate_Class:
    .long 0

// Global variable for holding the window
.section __DATA,regular
.align 4
AppDelegate_Window:
    .long 0

.section __DATA,regular
.align 4
AppDelegate_ScreenSize:
    .float 0, 0, 0, 0 // x, y, width, height

//
// The setup method for the app delegate class.
//
// Parameters:
//   none.
//
// Results:
//   none.
//
// Registers used:
//
// r0-r3: Arguments
// r4: Class Pointer.
// r5-r6: Temporary values.
// r7: Frame (stack) pointer
// r8: Temporary value
// r9: Scratch register
// r10-r11: Temporary values.
//
// Stack Used:
//
// 4 bytes, offset 0: Parameter passing.
//
.section __TEXT,__text,regular,pure_instructions
.global AppDelegate_Setup
.align 4
AppDelegate_Setup:
    push     {r4-r7, lr}           // save LR, R7, R4-R6
    add      r7, sp, #12           // adjust R7 to point to saved R7
    push     {r8, r10, r11}        // save remaining GPRs (R8, R10, R11)
    vstmdb   sp!, {d8-d15}         // save VFP/Advanced SIMD registers D8
    sub      sp, sp, #4            // Allocate stack storage

    // Before we can do anything else, we must first create a class to use as the application delegate. The basic process for this is as follows:
    //
    // 1: Fetch the superclass of the desired new class.                        (In this case, UIResponder)
    // 4: Create the new class.
    // 5: Save it out to a global varaible so that it can easily be re-used.    (In this case, AppDelegate_Class)
    // 6: Setup any protocols that this class will conform to.                  (In this case, none)
    // 7: Setup any ivars that this class will use.                             (In this case, one, called window)
    // 8: Setup any methods that this class will implement.                     (In this case, the -application:didFinishLaunchingWithOptions: method)
    // 9: Register the class with the runtime.
    //

    // Parameter 1 (r0) will be the name of the superclass.
    // The superclass will then be stored in r0 after calling the function.
    mov r0, AppDelegate_ParentClassName
    bl _objc_getClass

    // Parameter 1 (r0) will be the superclass, which is already in register r0.
    // Parameter 2 (r1) will be the new class's name.
    // Parameter 3 (r2) will be the extra byte count of this class, in this case 0.
    // The new class will then be stored in r0 after calling the function.
    mov r1, AppDelegate_ClassName
    mov r2, #0
    bl _objc_allocateClassPair

    // We now have a perfectly working class inside register r0.
    // Now, we save it out to the global value, and our register used throughout the function.
    mov r1, AppDelegate_Class
    str r0, [r1]
    mov r4, r0

    // Next, we need to add the iVar to the class we have. This can be done with a single method call.
    //
    // Parameter 1 (r0) will be the class
    // Parameter 2 (r1) will be the ivar's name
    // Parameter 3 (r2) will be the size of the argument, which is the size of a pointer. On ARMv7, this is 4 bytes.
    // Parameter 4 (r3) will be the offset of the argument, in this case it will be 0.
    // Parameter 5 (Stack) will be the encoding of the argument
    //
    // The success of this function will then be stored in r0 after calling the function.
    mov r0, r4
    mov r1, AppDelegate_IvarName
    mov r2, #4
    mov r3, #0
    mov r5, AppDelegate_IvarEncoding
    str r5, [sp]
    bl _class_addIvar

    // Our next step is to register the method used for launching the app. We can do this in two steps.
    //
    // 1: Fetch the unique selector for the method we are implementing.         (In this case, the -application:didFinishLaunchingWithOptions: method)
    // 2: Add the method to the class we have created.

    // To fetch the selector, we will use the function sel_getUid.
    //
    // Parameter 1 (r0) will be the name of the selector to get.
    //
    // The result of this function will then be stored in the r0 register.
    mov r0, AppDelegate_MethodName
    bl _sel_getUid

    // To add the method to the class, we will use the function class_addMethod.
    //
    // Parameter 1 (r0) will be the class.
    // Parameter 2 (r1) will be the selector (which is currently in r0).
    // Parameter 3 (r2) will be the address of the implementation.
    // Parameter 4 (r3) will be the encoding of the method.
    //
    // The success of this function will then be stored in r0 after calling the function.
    mov r1, r0
    mov r0, r4
    mov r2, AppDelegate_DidFinishLaunchingWithOptions
    mov r3, AppDelegate_MethodEncoding
    bl _class_addMethod

    // At this point, our class is fully set-up, and all that is left to do is register the class with the runtime.
    // This is done using the function objc_reigsterClassPair.
    //
    // Parameter 1 (r0) will be the class.
    //
    // This function has no results.
    mov r0, r4
    bl _objc_registerClassPair

    // We did it! Now the class should be all ready to go with the runtime, and our delegate's launching method will be called shortly.
    add      sp, sp, #4            // Deallocate stack storage.
    vldmia   sp!, {d8-d15}         // restore VFP/Advanced SIMD registers
    pop      {r8, r10, r11}        // restore R8-R11
    pop      {r4-r7, pc}           // restore R4-R6, saved R7, return to saved LR

//
// This method should be called when the application finishes launching.
//
// Parameters:
//   r0: self (id)
//   r1: _cmd (SEL)
//   r2: application (UIApplication *)
//   r3: options (NSDictionary *)
//
// Results:
//   r0: success (BOOL)
//
// Registers used:
//
// r0-r3: Arguments
// r4: Window Pointer.
// r5: View Controller Pointer.
// r6: View Pointer.
// r7: Frame (stack) pointer
// r8,r10,r11: Temporary values.
// r9: Scratch register
//
// Stack Used: 12 bytes total.
//
// 4 bytes, offset 8: self.
// 4 bytes, offset 4: extra parameter.
// 4 bytes, offset 0: extra parameter.
//
.section __TEXT,__text,regular,pure_instructions
.align 4
AppDelegate_DidFinishLaunchingWithOptions:
    push     {r4-r7, lr}           // save LR, R7, R4-R6
    add      r7, sp, #12           // adjust R7 to point to saved R7
    push     {r8, r10, r11}        // save remaining GPRs (R8, R10, R11)
    vstmdb   sp!, {d8-d15}         // save VFP/Advanced SIMD registers D8
    sub      sp, sp, #12           // Allocate stack space.

    // Save self off to the stack.
    str r0, [sp, #8]

    //
    // Our goal here is to create a window, view controller, and view to show on the screen.
    // This will be done with the following steps:
    //
    // 1: Fetch the size of the screen, using the UIScreen singleton.
    // 2: Create an instance of type UIWindow, and store it in self's window variable.
    // 3: Create a View Controller, and set that as the window's root controller.
    // 4: Create an instance of our view class, and add it to the view controller's heirarchy.
    // 5: Make the window the key window on the screen.
    //

    // Our first step is to get the size of the screen.
    // This poses quite the problem, because the 'bounds' property of the screen returns a struct.
    // Thus, we must use objc_msgSend_stret instead of the usual objc_msgSend.
    //
    // However, first we must get the singleton instance.
    //
    // Parameter 1 (r0) will be the name of the class to fetch.
    //
    // The found class will then be placed in the r0 register upon return. We will store it in the r8 register for now.
    mov r0, AppDelegate_ScreenClassName
    bl _objc_getClass
    mov r8, r0

    // The next step is to prepare the selector for use with objc_msgSend.
    // This will be done via sel_getUid
    //
    // Parameter 1 (r0) will be the name of the selector to fetch.
    //
    // The results of this function will be stored in the r0 register upon return.
    mov r0, AppDelegate_ScreenSingletonMethodName
    bl _sel_getUid

    // Now, we take the selector, and our target object, and use objc_msgSend to fetch the singleton.
    //
    // Parameter 1 (r0) will be the target of the message, in this case the UIScreen class, which we stored in the r8 register.
    // Parameter 2 (r1) will be the message to pass, in this case, '-mainScreen', which is currently in the r0 register.
    //
    // The results of this function (the singleton) will be placed in the r0 register upon return. We will then store it into the r8 register, as we no longer need the class there.
    mov r1, r0
    mov r0, r8
    bl _objc_msgSend
    mov r8, r0

    // Now that we have our singleton, the next step is to call the bounds method. We have to be careful with this, because of the struct return, but for the most part it is the same as any other method call.
    //
    // Before we can do that, if you haven't guessed by now, we need to convert our string into a selector.
    mov r0, AppDelegate_ScreenSizePropertyName
    bl _sel_getUid

    // Since we now have our blessed SEL, it is time to do the objc_msgSend_stret call.
    //
    // Parameter 1 (r0) will be the address of the struct in memory, which we store in AppDelegate_ScreenSize.
    // Parameter 2 (r1) will be the target of this message, which is our singleton, stored in the r8 register.
    // Parameter 3 (r2) will be the message to pass, which we just got from sel_getUid, and is in the r0 register.

    // Always return YES (1) to the calling function.
    mov r2, r0
    mov r1, r8
    mov r0, AppDelegate_ScreenSize
    bl _objc_msgSend_stret

    // Now that we have the screen size, it is time for us to create our window.
    // To create our window, we will need to fetch the class first, however.
    //
    // Parameter 1 (r0) will be the name of the class to fetch.
    //
    // The results of this function will be placed in the r0 register upon return. However, we will store it in the r8 register for now.
    mov r0, AppDelegate_WindowClassName
    bl _objc_getClass
    mov r8, r0

    // Next, we need to fetch the sel wthat we will use to allocate our window, using the sel_getUid function.
    //
    // Parameter 1 (r0) will be the name of the selector to fetch.
    //
    // The resutls of this function will be stored in the r0 register upon return.
    mov r0, AppDelegate_WindowAllocateMethodName
    bl _sel_getUid

    // Our next move is to actually allocate our class, using the objc_msgSend function.
    //
    // Parameter 1 (r0) will be the target of this message, in this case the class which is currently stored in r8.
    // Parameter 2 (r1) will be the message to pass to the target, which is currently in r0.
    //
    // The results of this function will be stored in the r0 register upon return, and we will move it into the r4 register.
    mov r1, r0
    mov r0, r8
    bl _objc_msgSend
    mov r4, r0

    // Now that we have our window, it's time to initialize it, but first we need to get our selector.
    //
    // Parameter 1 (r0) will be the name of the selector to fetch.
    //
    // The results of this function will be stored in the r0 register upon return.
    mov r0, AppDelegate_WindowInitMethodName
    bl _sel_getUid

    // To fully initialize the window, we need to pass our struct to the function.
    // This can simply be done by pushing the entire contents of the struct onto the stack. We will use objc_msgSend for this.
    //
    // Parameter 1 (r0) will be the target of this message, which is currently in r4.
    // Parameter 2 (r1) will be the message to send, which is currently in r0.
    // Parameter 3 (r2) will be the x element of the CGRect.
    // Parameter 4 (r3) will be the y element of the CGRect.
    // Parameter 5 (Stack, offset 0) will be the width element of the CGRect.
    // Parameter 6 (Stack, offset 4) will be the height element of the CGRect.
    //
    // The results of this function will be placed in the r0 register upon return. We will then retain it, and put it in our global variable.
    mov r1, r0
    mov r0, r4

    // CGRect Passing
    mov r8, AppDelegate_ScreenSize
    ldr r2, [r8]        // load x element
    ldr r3, [r8, #4]    // load y element
    ldr r10, [r8, #8]   // load width element
    str r10, [sp]       // store width to stack
    ldr r10, [r8, #12]  // load height element
    str r10, [sp, #4]   // store height to stack

    bl _objc_msgSend
    bl _objc_retain

    mov r1, AppDelegate_Window
    str r0, [r1]

    // Our window is now fully initialized. We need to then save it to self, which is currently on the stack.
    // The offset of the variable should be 4 bytes, as there is the sole 'isa' field that is store alongside our variable as well.
    ldr r0, [sp, #8]
    ldr r0, [r0]
    str r4, [r0, #4]

    // Now that we have set the ivar properly, it is time to allocate our view controller.
    // To do this, we will need to fetch the class and selector that we will use.
    // Obviously, we will start with objc_getClass.
    //
    // Parameter 1 (r0) will be the name of the class to fetch.
    //
    // The results of this function will be placed in the r0 register,
    // but we will move it to the r8 register for now.
    mov r0, AppDelegate_ViewControllerClassName
    bl _objc_getClass
    mov r8, r0

    // Before we can allocate our class, we need to fetch our selector (surprise surprise).
    //
    // Parameter 1 (r0) will be the name of the selector to fetch.
    //
    // The results of this function will be placed in the r0 register.
    mov r0, AppDelegate_ViewControllerAllocateMethodName
    bl _sel_getUid

    // Now we can finally allocate our class. Just like we've done before, we will use objc_msgSend for this.
    //
    // Parameter 1 (r0) will be the target of the message, which is in the r8 register.
    // Parameter 2 (r1) will be the message to pass, which is currently in the r0 register.
    //
    // The results of this function will be placed in the r0 register. We will store it in the r8 register for now.
    mov r1, r0
    mov r0, r8
    bl _objc_msgSend
    mov r8, r0

    // Next up is to get our selector for initializing the class.
    //
    // Parameter 1 (r0) will be the name of the selector to fetch.
    //
    // The results of this function will be placed in the r0 register.
    mov r0, AppDelegate_ViewControllerInitMethodName
    bl _sel_getUid

    // Finally, we can initialize our view controller. There's nothing really special about this, as we don't need to pass any fancy arguments to the method.
    //
    // Parameter 1 (r0) will be the target of the message, which is currently stored in the r8 register.
    // Parameter 2 (r1) will be the message to pass, which is currently stored in the r0 register.
    //
    // The results of this function will be placed in the r0 register, which we will then move to the r5 register.
    mov r1, r0
    mov r0, r8
    bl _objc_msgSend
    mov r5, r0

    // Now that we (finally) have our view controller. We should attach it to our window.
    //
    // Firstly, we should get our next selector through sel_getUid. You should know the drill by now.
    //
    // Parameter 1 (r0) will be the name of the selector to fetch.
    //
    // The results of this function will be placed in the r0 register.
    mov r0, AppDelegate_ViewControllerAttachMethodName
    bl _sel_getUid

    //
    // Next, we attach the view controller through the window via our best friend, objc_msgSend.
    //
    // Parameter 1 (r0) will be the target of the method, which is our window in the r4 register.
    // Parameter 2 (r1) will be the message to send, which is in the r0 register.
    // Parameter 3 (r2) will be the new view controller to attach, which is in the r5 register.
    //
    // This method has no results.
    mov r1, r0
    mov r0, r4
    mov r2, r5
    bl _objc_msgSend

    // Creating the view will be done in several steps:
    //
    // 1: Fetch our view class
    // 2: Allocate a new instance of our view class
    // 3: Set our new view instance as the view controller's view

    // It's time for us to get the view's class object. This will be done with objc_getClass
    //
    // Parameter 1 (r0) will be the name of the class to fetch.
    //
    // The found class will then be placed in the r0 register upon return. We will store it in the r8 register for now.
    mov r0, AppDelegate_ViewClassName
    bl _objc_getClass
    mov r8, r0

    // Next we need to get the selector for allocating our new view, using sel_getUid.
    //
    // Parameter 1 (r0) will be the name of the selector to fetch.
    //
    // The results of this function will be placed in the r0 register.
    mov r0, AppDelegate_ViewAllocateMethodName
    bl _sel_getUid

    // Now, we can allocate our class, using objc_msgSend.
    //
    // Parameter 1 (r0) will be the class to allocate an instance of, which is our class in the r8 register.
    // Parameter 2 (r1) will be the message to send, in this case the selector which is in the r0 register.
    //
    // The created instance will then be stored in the r0 function after completion, we will however store it in the r6 register.
    mov r1, r0
    mov r0, r8
    bl _objc_msgSend
    mov r6, r0

    // Next up is to initialize our class, once again done using our two favorite methods in the world, sel_getUid and objc_msgSend.
    //
    // Parameter 1 (r0) will be the name of the selector to fetch.
    //
    // The results of this function will be placed in the r0 register.
    mov r0, AppDelegate_ViewInitMethodName
    bl _sel_getUid

    // Now we fcan actually pass the message, using objc_msgSend
    //
    // Parameter 1 (r0) will be the object to pass the method to, in this case our view in the r6 register.
    // Parameter 2 (r1) will be the message to pass, which is currently in the r0 register.
    // Parameter 3 (r2) will be the x element of the CGRect.
    // Parameter 4 (r3) will be the y element of the CGRect.
    // Parameter 5 (Stack, offset 0) will be the width element of the CGRect.
    // Parameter 6 (Stack, offset 4) will be the height element of the CGRect.
    mov r1, r0
    mov r0, r6

    // CGRect Passing
    mov r8, AppDelegate_ScreenSize
    ldr r2, [r8]        // load x element
    ldr r3, [r8, #4]    // load y element
    ldr r10, [r8, #8]   // load width element
    str r10, [sp]       // store width to stack
    ldr r10, [r8, #12]  // load height element
    str r10, [sp, #4]   // store height to stack

    bl _objc_msgSend

    // We're just about done, there's only one thing really left to go, and that's attaching the view to our view controller.
    // Before we can do that, we must first fetch our selector.
    //
    // Parameter 1 (r0) will be the name of the selector to fetch.
    //
    // The results of this function will be placed in the r0 register.
    mov r0, AppDelegate_ViewControllerAttachViewMethodName
    bl _sel_getUid

    // Next, we can send the message to our view controller, using objc_msgSend
    //
    // Parameter 1 (r0) will be the target of this message, which is our view controller in register r5.
    // Parameter 2 (r1) will be the message to pass, which is currently in r0.
    // Parameter 3 (r2) will be the view to set, which is currently in the r6 register.
    //
    // This method returns no results.
    mov r1, r0
    mov r0, r5
    mov r2, r6
    bl _objc_msgSend

    // Now, make the window visible on-screen! To do this, we use (you guessed it!) sel_getUid and objc_msgSend.
    //
    // Parameter 1 (r0) will be the name of the selector to fetch.
    //
    // The results of this function will be placed in the r0 register.
    mov r0, AppDelegate_WindowMakeVisibleMethodName
    bl _sel_getUid

    //
    // Next up is to simply pass the message along with objc_msgSend.
    //
    // Parameter 1 (r0) will be the target of the message, which is our window in the r4 register.
    // Parameter 2 (r1) will be the message we're sending, which is currently in the r0 register.
    //
    // This method has no results.
    mov r1, r0
    mov r0, r4
    bl _objc_msgSend

    // WE DID IT! If done properly, we should now have stuff happening on the screen!
    // Next, we just release the various objects we have allocated.
    // Over the course of the method, we allocated the following objects:
    //      Window (r4)
    //      View Controller (r5)
    //      View (r6)
    mov r0, r4
    bl _objc_release

    mov r0, r5
    bl _objc_release

    mov r0, r6
    bl _objc_release

    // Always return YES to the caller.
    mov r0, #1

    add      sp, sp, #12           // Deallocate stack space.
    vldmia   sp!, {d8-d15}         // restore VFP/Advanced SIMD registers
    pop      {r8, r10, r11}        // restore R8-R11
    pop      {r4-r7, pc}           // restore R4-R6, saved R7, return to saved LR