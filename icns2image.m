/*
    icns2image - Mac OS X command line program to convert Apple icns files to images

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

static const char optstring[] = "vht:r:";

static struct option long_options[] = {
    {"version",     no_argument,        0,  'v'},
    {"help",        no_argument,        0,  'h'},
    {"type",        required_argument,  0,  't'},
    {0,             0,                  0,    0}
};

static NSUInteger ImageTypeForSuffix(NSString *suffix);
static void PrintHelp(void);

int main(int argc, const char * argv[]) { @autoreleasepool {
    
    NSString *typeStr = nil;
    NSUInteger representation = 0;
    
    int optch;
    int long_index = 0;
    
    // parse getopt
    while ((optch = getopt_long(argc, (char *const *)argv, optstring, long_options, &long_index)) != -1) {
        switch (optch) {
            
            case 'r':
            {
                NSString *repStr = @(optarg);
                representation = [repStr intValue];
            }
                break;
                
            case 't':
                typeStr = @(optarg);
                break;
            
            // print version
            case 'v':
                PrintProgramVersion();
                break;
                
            // print help
            case 'h':
            default:
            {
                PrintHelp();
                exit(EXIT_SUCCESS);
            }
                break;
        }
    }
    
    NSMutableArray *args = ReadRemainingArgs(argc, argv);
    if ([args count] < 2) {
        PrintHelp();
        return EX_USAGE;
    }

    NSString *srcPath = [args[0] stringByExpandingTildeInPath];
    NSString *destPath = [args[1] stringByExpandingTildeInPath];
    
    // make sure source file exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:srcPath]) {
        NSPrintErr(@"File '%@' does not exist\n", srcPath);
        return EXIT_FAILURE;
    }
    
    // make sure destination path is writable
    if ([[NSFileManager defaultManager] fileExistsAtPath:destPath] &&
        ![[NSFileManager defaultManager] isWritableFileAtPath:destPath]) {
        NSPrintErr(@"Cannot write to path '%@'\n", destPath);
        return EX_CANTCREAT;
    }
    
    // read icon from source file
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:srcPath];
    NSArray *reps = [img representations];
    if (img == nil || [reps count] == 0) {
        NSPrintErr(@"Error reading icon from file\n");
        return EXIT_FAILURE;
    }
    
    NSBitmapImageRep *wantedRep;
    NSBitmapImageRep *largestRep;
    
    // Find the representation we want - default to largest
    for (NSImageRep *rep in reps) {
        if (![rep isKindOfClass:[NSBitmapImageRep class]]) {
            continue;
        }
        NSBitmapImageRep *brep = (NSBitmapImageRep *)rep;
        if ([brep pixelsWide] > [largestRep pixelsWide]) {
            largestRep = brep;
        }
        if (representation && [brep pixelsWide] == representation) {
            wantedRep = brep;
        }
    }
    
    if (representation && wantedRep == nil) {
        NSPrintErr(@"Representation '%dx%d' not found in file, using largest representation (%dx%d) instead.",
                   representation, representation, [largestRep pixelsWide], [largestRep pixelsHigh]);
    }
    if (wantedRep == nil) {
        wantedRep = largestRep;
    }
    
    // determine image output format
    NSUInteger imgType = NSTIFFFileType;
    if (typeStr) {
        imgType = ImageTypeForSuffix(typeStr);
        if (!imgType) {
            NSPrintErr(@"Invalid image type: %@", typeStr);
        }
    }
    if (!imgType) {
        NSString *suffix = [destPath lastPathComponent];
        imgType = ImageTypeForSuffix(typeStr);
        if (!imgType) {
            NSPrintErr(@"Unable to determine image type from suffix '%@', falling back to TIFF", suffix);
            imgType = NSTIFFFileType;
        }
    }
    
    NSDictionary *prop = @{ NSImageCompressionFactor : @(1.0f) };
    NSData *data = [wantedRep representationUsingType:imgType properties:prop];
    if (data == nil) {
        NSPrintErr(@"Error creating image data for type %d", imgType);
        return EX_DATAERR;
    }

    if ([data writeToFile:destPath atomically:YES] == NO) {
        NSPrintErr(@"Error writing image to destination");
        return EX_IOERR;
    }
    
    return EXIT_SUCCESS;
}}

static NSUInteger ImageTypeForSuffix(NSString *suffix) {
    
    NSDictionary *map = @{  @"jpg" : @(NSJPEGFileType),
                            @"jpeg": @(NSJPEGFileType),
                            @"png":  @(NSPNGFileType),
                            @"gif":  @(NSGIFFileType),
                            @"tiff": @(NSTIFFFileType),
                            @"bmp":  @(NSBMPFileType)    };
    
    NSString *s = [suffix lowercaseString];
    NSNumber *imgTypeNum = map[s];
    if (!imgTypeNum) {
        return 0;
    }
    
    return [imgTypeNum unsignedIntegerValue];
}

static void PrintHelp(void) {
    NSPrintErr(@"usage: icns2image src dest\n");
}
