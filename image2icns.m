/*
    image2icns - Mac OS X command line program to convert images to Apple icns files

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

int main (int argc, const char * argv[]) { @autoreleasepool {

    if (argc < 3) {
        NSPrintErr(@"usage: image2icns src dest\n");
        return EX_USAGE;
    }

    NSString *srcPath = [@(argv[1]) stringByExpandingTildeInPath];
    NSString *destPath = [@(argv[2]) stringByExpandingTildeInPath];

    // make sure source file exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:srcPath]) {
        NSPrintErr(@"File '%@' does not exist\n", srcPath);
        return EXIT_FAILURE;
    }

    // get image from source file
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:srcPath];
    if (img == nil) {
        NSPrintErr(@"Could not read image from file '%@'\n", srcPath);
        return EXIT_FAILURE;
    }

    // create icon from image
    IconFamily *iconFam = [[IconFamily alloc] initWithThumbnailsOfImage:img];
    if (iconFam == nil)  {
        NSPrintErr(@"Error generating icon data from image\n");
        return EXIT_FAILURE;
    }
    
    // make sure destination path is writable
    if ((![[NSFileManager defaultManager] isWritableFileAtPath:destPath])) {
        NSPrintErr(@"Cannot write to path '%@'\n", destPath);
        return EXIT_FAILURE;
    }
    
    BOOL res = [iconFam writeToFile:destPath];

    // make sure we were successful
    if (res == NO || ![[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        NSPrintErr(@"Failed to create icon at path '%@'\n", destPath);
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}}

