/*
    geticon - command line program to get the icon of a Mac file and save it as an image

    Copyright (c) 2003-2017, Sveinbjorn Thordarson <sveinbjornt@gmail.com>
    All rights reserved.

    Redistribution and use in source and binary forms, with or without modification,
    are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this
    list of conditions and the following disclaimer in the documentation and/or other
    materials provided with the distribution.

    3. Neither the name of the copyright holder nor the names of its contributors may
    be used to endorse or promote products derived from this software without specific
    prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
    IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
    INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
    NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/

#import <Cocoa/Cocoa.h>
#import "CLI.h"
#import "IconFamily.h"
#import <sysexits.h>

int main(int argc, const char * argv[]) { @autoreleasepool {
    
    //NSApplication *app = [NSApplication sharedApplication]; // establish connection to window server
    
    NSMutableArray *args = ReadRemainingArgs(argc, argv);
    
    // check if we have the correct number of arguments
    if ([args count] != 2) {
        NSPrintErr(@"usage: geticon src out.icns");
        return EX_USAGE;
    }

    NSString *srcFile = args[0];
    NSString *outFile = args[1];
    
    IconFamily *iconFamily = [IconFamily iconFamilyWithIconOfFile:srcFile];
    BOOL success = [iconFamily writeToFile:outFile];
    
    if (!success || ![[NSFileManager defaultManager] fileExistsAtPath:outFile]) {
        NSPrintErr(@"Failed to create icns file at path '%@'", outFile);
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}}
