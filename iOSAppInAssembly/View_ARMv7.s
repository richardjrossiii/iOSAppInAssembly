// View_ARMv7.s
// This is the file that will contain the class for our view.

// Setup all strings that will be used in this file.
.section __TEXT,__cstring
View_ParentClassName:
    .asciz "UIView"

.section __TEXT,__cstring
View_ClassName:
    .asciz "View"

.section __TEXT,__cstring
View_MethodName:
    .asciz "drawRect:"

.section __TEXT,__cstring
View_MethodEncoding:
    .asciz "v@:{CGRect={CGPoint=ff}{CGSize=ff}}"
    
.section __TEXT,__cstring
View_DrawString:
    .asciz "Hello, Assembly!"

// Global variables for storing the class
.section __DATA,regular
.align 4
View_Class:
    .long 0

.section __DATA,regular
.align 4
View_FillRect:
    .float 0
    .float 0
    .float 1000
    .float 1000

.section __DATA,regular
.align 4
View_FillColor:
    .float 1, 1, 0, 1 // RGBA

.section __DATA,regular
.align 4
View_TextPosition:
    .float 100
    .float 100

.section __DATA,regular
.align 4
View_TextMatrix:
    .float 1 // a
    .float 0 // b
    .float 0 // c
    .float -1 // d
    .float 0 // tx
    .float 0 // ty

.section __DATA,regular
.align 4
View_FontName:
    .asciz "Helvetica"

.section __DATA,regular
.align 4
View_FontSize:
    .float 20

.section __DATA,regular
.align 4
View_DrawColor:
    .float 1, 0, 0, 1 // RGBA

.section __DATA,regular
.align 4
View_DrawStringLength:
    .int 16

//
// The setup method for the view class.
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
// r7: Frame (stack) pointer.
// r8: Temporary value.
// r9: Scratch register.
// r10-r11: Temporary values.
//
// Stack Used:
//
// 4 bytes, offset 0: Parameter passing.
//
.section __TEXT,__text,regular,pure_instructions
.global View_Setup
.align 4
View_Setup:
    push     {r4-r7, lr}           // save LR, R7, R4-R6
    add      r7, sp, #12           // adjust R7 to point to saved R7
    push     {r8, r10, r11}        // save remaining GPRs (R8, R10, R11)
    vstmdb   sp!, {d8-d15}         // save VFP/Advanced SIMD registers D8

    // Our goal here is to create a view class. We'll use the following steps to accomplish this:
    //
    // 1: Fetch the superclass of our new class.                            (In this case, UIView)
    // 2: Create our new class.
    // 3: Save it to our global variable in case we need to use it again.   (In this case, View_Class)
    // 4: Setup the -drawRect: method of our class.
    //

    // Parameter 1 (r0) will be the name of the superclass.
    // The superclass will then be stored in r0 after calling the function.
    mov r0, View_ParentClassName
    bl _objc_getClass

    // Parameter 1 (r0) will be the superclass, which is already in the r0 register.
    // Parameter 2 (r1) will be the new class's name.
    // Parameter 3 (r2) will be the extra byte count of this class, in this case 0.
    // The new class will then be stored in the r0 register after calling the function.
    mov r1, View_ClassName
    mov r2, #0
    bl _objc_allocateClassPair

    // Now that we have our class, it's time to store it to our global variable,
    // and our r4 register for use inside this function..
    mov r1, View_Class
    str r0, [r1]
    mov r4, r0

    // The next step to attach the method to our class. We'll do this in two steps:
    //
    // 1: Fetch the unique selector for the method we're implementing.
    // 2: Add the method to the class we've created.

    // To fetch the selector, we will use the function sel_getUid.
    //
    // Parameter 1 (r0) will be the name of the selector to get.
    //
    // The result of this function will then be stored in the r0 register.
    mov r0, View_MethodName
    bl _sel_getUid

    // To actually add the method to the class, we'll use the function class_addMethod.
    //
    // Parameter 1 (r0) will be the class    (which is currently in r4).
    // Parameter 2 (r1) will be the selector (which is currently in r0).
    // Parameter 3 (r2) will be the address of the implementation.
    // Parameter 4 (r3) will be the encoding of this method.
    //
    // The success of this function will then be stored in the r0 register upon completion.
    mov r1, r0
    mov r0, r4
    mov r2, View_DrawRect
    mov r3, View_MethodEncoding
    bl _class_addMethod

    // If we've gotten this far, our class is ready to go, we just need to actually hook it into the runtime.
    // This is done using the function objc_registerClassPair.
    //
    // Parameter 1 (r0) will be the class, which is currently in the r4 register.
    //
    // This function has no results.
    mov r0, r4
    bl _objc_registerClassPair

    // Now, everything else should be done automatically!
    // Our drawRect will be called, and we shouldn't have to touch the runtime again!

    vldmia   sp!, {d8-d15}         // restore VFP/Advanced SIMD registers
    pop      {r8, r10, r11}        // restore R8-R11
    pop      {r4-r7, pc}           // restore R4-R6, saved R7, return to saved LR

//
// The method used for drawing the view.
//
// Parameters:
//   r0: View object.
//   r1: Selector passed (-drawRect:)
//   r2-r4,[stack-stack, offset 4]: Dirty rect.
//
// Results:
//   none.
//
// Registers used:
//
// r0-r3: Arguments
// r4: CGContext Pointer.
// r5-6: Temporary values.
// r7: Frame (stack) pointer.
// r8: Temporary value.
// r9: Scratch register.
// r10-r11: Temporary values.
//
// Stack Used:
//
// 4 bytes, offset 0: Parameter passing.
//
.section __TEXT,__text,regular,pure_instructions
.align 4
View_DrawRect:
    push     {r4-r7, lr}           // save LR, R7, R4-R6
    add      r7, sp, #12           // adjust R7 to point to saved R7
    push     {r8, r10, r11}        // save remaining GPRs (R8, R10, R11)
    vstmdb   sp!, {d8-d15}         // save VFP/Advanced SIMD registers D8

    sub      sp, sp, #12           // Allocate stack storage

    // Our goal in this method is to simply draw something to the screen.
    // We will use the QuartzCore functions for this, but we'll make things
    // a little bit more interesting by drawing something other than a rectangle.

    // First, let's fetch the current context with UIGraphcisGetCurrentContext().
    //
    // It takes no praremters.
    //
    // The context will be placed in the r0 register upon returning, and we will then store it in the r4 register.
    bl _UIGraphicsGetCurrentContext
    mov r4, r0

    // Now, we'll clear the screen, using CGContextSetFillColor.
    //
    // Parameter 1 (r0) will be the context, which is currently in the r0 register.
    // Parameter 2 (r1) will be the pointer to the first element in our color array.
    //
    // This method returns no results
    mov r1, View_FillColor
    bl _CGContextSetFillColor

    // To actually fill the screen, we must now use CGContextFillRect.
    //
    // Parameter 1 (r0) will be the context, which is currently in the r4 register.
    // Parameter 2 (r1) will be the x element of the rect to fill.
    // Parameter 3 (r2) will be the y element of the rect to fill.
    // Parameter 4 (r3) will be the width element of the rect to fill.
    // Parameter 5 (Stack, offset 0) will be the height element of the rect to fill.
    //
    // This method returns no results.
    mov r0, r4

    // CGRect loading
    mov r9, View_FillRect
    ldr r1, [r9]
    ldr r2, [r9, #4]
    ldr r3, [r9, #8]
    ldr r9, [r9, #12]
    str r9, [sp]

    bl _CGContextFillRect

    // Now, we'll set the font. We'll do this with CGContextSelectFont
    //
    // Parameter 1 (r0) will be the context, which is currently in the r4 register
    // Parameter 2 (r1) will be the font name, which is Helvetica.
    // Parameter 3 (r2) will be the font size as a float
    // Parameter 4 (r3) will be the encoding of the text, which we will set at MacRoman, 1
    //
    // This method returns no results.
    mov r0, r4
    mov r1, View_FontName
    mov r9, View_FontSize
    ldr r2, [r9]
    mov r3, #1

    bl _CGContextSelectFont

    // Before we can draw this text, we need to set the text color. This will be done using CGContextSetFillColor.
    //
    // Parameter 1 (r0) will be the context, which is currently in register r4.
    // Parameter 2 (r1) will be the pointer to the first element in our color array.
    //
    // This method returns no results.
    mov r0, r4
    mov r1, View_DrawColor
    bl _CGContextSetFillColor

    // Now, at this point there is an issue - CGContext draws everything upside down,
    // and we need to scale it to flip it the right-side up. This is done using CGContextSetTextMatrix.
    //
    // Parameter 1 (r0) will be the context.
    // Parameter 2 (r1) will be the first element in the matrix.
    // Parameter 3 (r2) will be the second element in the matrix.
    // Parameter 4 (r3) will be the third element in the matrix.
    // Parameter 5 (Stack, offset 0) will be the fourth element in the matrix.
    // Parameter 6 (Stack, offset 4) will be the fifth element in the matrix.
    // Parameter 7 (Stack, offset 8) will be the sixth element in the matrix.
    //
    // This method returns no results.
    mov r0, r4
    mov r9, View_TextMatrix
    ldr r1, [r9]        // 1
    ldr r2, [r9, #4]    // 2
    ldr r3, [r9, #8]    // 3

    ldr r5, [r9, #12]
    str r5, [sp]        // 4

    ldr r5, [r9, #16]
    str r5, [sp, #4]    // 5

    ldr r5, [r9, #20]
    str r5, [sp, #8]    // 6

    bl _CGContextSetTextMatrix
    
    // Next, we'll set the text position. We'll do this with CGContextSetTextPosition
    //
    // Parameter 1 (r0) will be the context, which is currently in the r4 register
    // Parameter 2 (r1) will be the x position to set
    // Parameter 3 (r2) will be the y position to set
    //
    // This method returns no results.
    mov r0, r4

    mov r9, View_TextPosition
    ldr r1, [r9]
    ldr r2, [r9, #4]
    bl _CGContextSetTextPosition

    // If we did this correctly, now we should be able to draw the text to the screen!
    // This will be done with CGContextShowText
    //
    // Parameter 1 (r0) will be the context, which is currently in register r4.
    // Parameter 2 (r1) will be the pointer to the string.
    // Parameter 3 (r2) will be the length of the string.
    //
    // This method returns no results.
    mov r0, r4
    mov r1, View_DrawString
    mov r2, View_DrawStringLength
    ldr r2, [r2]
    bl _CGContextShowText

    // That's it! Now we simply return to the calling function, and we have successfully created an iOS app in ARM assembler.
    add      sp, sp, #12           // Deallocate stack storage.
    
    vldmia   sp!, {d8-d15}         // restore VFP/Advanced SIMD registers
    pop      {r8, r10, r11}        // restore R8-R11
    pop      {r4-r7, pc}           // restore R4-R6, saved R7, return to saved LR
