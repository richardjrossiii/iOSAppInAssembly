## An iOS App In Assembly

It's just what it sounds like. Hand written, delicately debugged, well-commented, ARMv7 assembly. Work on this started before ARM64 devices were a thing, so support for them may come in the future.

### Goals

Rather simple, make an app that compiles, runs, and draws somthing on the screen, using only hand written assembly. The only times I used the assembly output of clang was to determine the proper `.section`s for things, to let lldb be able to debug my functions.

The basic structure of this app is based on my [iOS App In Pure C](https://github.com/richardjrossiii/CBasediOSApp), with a 'main' file which contains all the set-up code, and two supporting files, for each of the classes (AppDelegate, and View).

The drawing code is all done using CoreGraphics, and displays the string 'Hello, Assembly!' in red on the screen. Here's a screenshot of the app running on my iPhone 5S:

![](http://i.imgur.com/mulfx8nl.png)

### Notes

If running the app with any accessiblity features enabled (switch control, guided access, etc.) the app crashes when the runtime tries to see if my App Delegate responds to the selector `accessibilityInitialize`, and I'm not entirely sure why. This may be fixed in the future.

### Resources

 - [Apple's iOS ABI Reference](https://developer.apple.com/library/ios/documentation/Xcode/Conceptual/iPhoneOSABIReference/Introduction/Introduction.html#//apple_ref/doc/uid/TP40009020-SW1)
 - [The ARM ABI Reference](http://infocenter.arm.com/help/topic/com.arm.doc.subset.swdev.abi/index.html)
 - [The ARM Developer Suite Assembler Guide](http://infocenter.arm.com/help/topic/com.arm.doc.dui0068b/index.html)

And, as always, the mighty power of Google.

###License

Copyright 2014 Richard J. Ross III.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.