/*
    seticon - command line program to set the icon of one or more Mac OS X files

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
#include <sysexits.h>

#define OPT_STRING            "vhdi" 

static void PrintHelp (void);

int main (int argc, const char * argv[]) { @autoreleasepool {

    NSApplication *app = [NSApplication sharedApplication]; // establish connection to window server
    int rc, optch;
    char *src;
    static char optstring[] = OPT_STRING;

    BOOL sourceIsIcns = NO;
    BOOL sourceIsImage = NO;

    while ((optch = getopt(argc, (char * const *)argv, optstring)) != -1) {
        switch(optch) {
            case 'v':
                PrintProgramVersion();
                return EX_OK;
                break;
            case 'h':
                PrintHelp();
                return EX_OK;
                break;
            case 'd':
                sourceIsIcns = 1;
                break;
            case 'i':
                sourceIsImage = 1;
                break;
            default: // '?'
                rc = 1;
                PrintHelp();
                return EX_USAGE;
        }
    }

    if (sourceIsIcns && sourceIsImage) {
        fprintf(stderr, "%s: Both -i and -d parameters specified.\nSource cannot both be icns and image", PROGRAM_STRING);
        PrintHelp();
        return EX_USAGE;
    }

    //check if a correct number of arguments was submitted
    if (argc < 3) {
        fprintf(stderr, "%s: Too few arguments.\n", PROGRAM_STRING);
        PrintHelp();
        return EX_USAGE;
    }

    src = (char *)argv[optind];

    //get the icon
    IconFamily *icon;
    NSString *srcPath = [NSString stringWithCString: src encoding: [NSString defaultCStringEncoding]];

    if (sourceIsIcns) {
        icon = [IconFamily iconFamilyWithContentsOfFile: srcPath];
        if (icon == nil) {
            fprintf(stderr, "Failed to read icns file '%s'.\n", src);
            return EXIT_FAILURE;
        }
    }
    else if (sourceIsImage) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile: srcPath];
        if (image == nil) {
            fprintf(stderr, "Failed to read image file '%s'.\n", src);
            return EXIT_FAILURE;
        }
        
        icon = [IconFamily iconFamilyWithThumbnailsOfImage: image];
        if (icon == nil) {
            fprintf(stderr, "Failed to generate icon from image.\n");
            return EXIT_FAILURE;
        }
        
    }
    else {
        icon = [IconFamily iconFamilyWithIconOfFile: srcPath];
        if (icon == nil) {
            fprintf(stderr, "Failed to get icon of file '%s'.\n", src);
            return EXIT_FAILURE;
        }
    }

    //all remaining arguments should be files
    // these get their icon set to the icon we just retrieved
    for (; optind < argc; ++optind) {
        BOOL isDir;
        NSString *dstPath = [NSString stringWithCString: (char *)argv[optind] encoding: [NSString defaultCStringEncoding]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath: dstPath isDirectory: &isDir] && isDir) {
            [icon setAsCustomIconForDirectory: dstPath];
        } else {
            [icon setAsCustomIconForFile: dstPath];
        }
    }
    
    return EX_OK;
}}

#pragma mark -

static void PrintVersion (void) {
    printf("%s v. %s\n", PROGRAM_STRING, VERSION_STRING);
}

static void PrintHelp (void) {
    printf("usage: %s [-vhdi] [source] [file ...]\n", PROGRAM_STRING);
}
