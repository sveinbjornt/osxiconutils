/*
    geticon - command line program to get the icon of a Mac OS X file and save as image

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

static int GenerateFileFromIcon (char *src, char *dst, int kind);
static int GetFileKindFromString (char *str);
static char* CutSuffix (char *name);
static char* GetFileNameFromPath (char *name);
static void PrintHelp (void);

#define OPT_STRING           "vho:t:"

//file kinds
#define kInvalidKindErr -1
#define kIcnsFileKind    0
#define kJpegFileKind    1
#define kBmpFileKind     2
#define kPngFileKind     3
#define kGifFileKind     4
#define kTiffFileKind    5

int iconRepKind = kThumbnail32BitData;

int main(int argc, const char * argv[]) { @autoreleasepool {
    
    NSApplication *app = [NSApplication sharedApplication]; // establish connection to window server
    int rc, optch, result, kind = kIcnsFileKind;
    char *src = NULL, *dst = NULL;
    int alloced = TRUE;
    static char optstring[] = OPT_STRING;

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
            case 'o':
                dst = optarg;
                alloced = FALSE;
                break;
            case 't':
                kind = GetFileKindFromString(optarg);
                if (kind == kInvalidKindErr) {
                    fprintf(stderr, "%s: %s: Invalid file kind\n", PROGRAM_STRING, optarg);
                    return EX_USAGE;
                }
                break;
            default: // '?'
                rc = 1;
                PrintHelp();
                return EX_OK;
        }
    }

    src = (char *)argv[optind];

    //check if a correct number of arguments was submitted
    if (argc < 2 || src == NULL) {
        fprintf(stderr, "%s: Too few arguments.\n", PROGRAM_STRING);
        PrintHelp();
        return EX_USAGE;
    }

    //make destination icon file path current working directory with filename plus icns suffix
    if (dst == NULL) {
        dst = malloc(2048);
        strcpy(dst, src);
        strcpy(dst, (char *)GetFileNameFromPath(dst));
        dst = CutSuffix(dst);
    }

    result = GenerateFileFromIcon(src, dst, kind);

    if (alloced == TRUE) {
        free(dst);
    }

    return result;
}}

#pragma mark -

static int GetFileKindFromString (char *str) {
    if (!strcmp(str, (char *)"jpeg"))
        return 1;
    if (!strcmp(str, (char *)"bmp"))
        return 2;
    if (!strcmp(str, (char *)"png"))
        return 3;
    if (!strcmp(str, (char *)"gif"))
        return 4;
    if (!strcmp(str, (char *)"tiff"))
        return 5;
    if (!strcmp(str, (char *)"icns"))
        return 0;

    return kInvalidKindErr;
}

static int GenerateFileFromIcon(char *src, char *dst, int kind) {
    
    NSString *srcStr = [NSString stringWithCString: src encoding: [NSString defaultCStringEncoding]];
    NSString *dstStr = [NSString stringWithCString: dst encoding: [NSString defaultCStringEncoding]];
    NSData *data;
    NSDictionary *dict = @{NSImageCompressionFactor: @1.0f};
    
    //make sure source file we grab icon from exists
    if (![[NSFileManager defaultManager] fileExistsAtPath: srcStr]) {
        fprintf(stderr, "%s: %s: No such file or directory\n", PROGRAM_STRING, src);
        return EX_NOINPUT;
    }
    
    IconFamily  *icon = [IconFamily iconFamilyWithIconOfFile: srcStr];
    
    switch (kind) {
        case kIcnsFileKind:
        {
            if (![dstStr hasSuffix: @".icns"])
                dstStr = [dstStr stringByAppendingString:@".icns"];
            [icon writeToFile: dstStr];
        }
        break;
            
        case kJpegFileKind:
        {
            if (![dstStr hasSuffix: @".jpg"])
                dstStr = [dstStr stringByAppendingString:@".jpg"];
            data = [[icon bitmapImageRepWithAlphaForIconFamilyElement: iconRepKind] representationUsingType:NSJPEGFileType properties:dict];
        }
        break;
            
        case kBmpFileKind:
        {
            if (![dstStr hasSuffix: @".bmp"])
                dstStr = [dstStr stringByAppendingString:@".bmp"];
            data = [[icon bitmapImageRepWithAlphaForIconFamilyElement: iconRepKind] representationUsingType:NSBMPFileType properties:dict];
        }
        break;
            
        case kPngFileKind:
        {
            if (![dstStr hasSuffix: @".png"])
                dstStr = [dstStr stringByAppendingString:@".png"];
            data = [[icon bitmapImageRepWithAlphaForIconFamilyElement: iconRepKind] representationUsingType:NSPNGFileType properties:dict];
        }
        break;
        
        case kGifFileKind:
        {
            if (![dstStr hasSuffix: @".gif"])
                dstStr = [dstStr stringByAppendingString:@".gif"];
            data = [[icon bitmapImageRepWithAlphaForIconFamilyElement: iconRepKind] representationUsingType:NSGIFFileType properties:dict];
        }
        break;
            
        case kTiffFileKind:
        {
            if (![dstStr hasSuffix: @".tiff"])
                dstStr = [dstStr stringByAppendingString:@".tiff"];
            data = [[icon bitmapImageRepWithAlphaForIconFamilyElement: iconRepKind] representationUsingType:NSTIFFFileType properties:dict];
        }
        break;
    }
            
    if (data != nil) {
        [data writeToFile: dstStr atomically:YES];
    }
    
    //see if file was created
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath: dstStr isDirectory: &isDir] && !isDir) {
        fprintf(stderr, "%s: %s: File could not be created\n", PROGRAM_STRING, dst);
        return EX_CANTCREAT;
    }
    
    return EX_OK;
}

////////////////////////////////////////
// Cuts suffix from a file name
///////////////////////////////////////
static char* CutSuffix(char *name) {
    short i, len, suffixMaxLength = 11;
    
    len = strlen(name);
    
    for (i = 1; i < suffixMaxLength+2; i++)
    {
        if (name[len-i] == '.')
        {
            name[len-i] = 0;
            return name;
        }
    }
    return name;
}

static char* GetFileNameFromPath(char *name) {
    short i, len;
    
    len = strlen(name);
    
    for (i = len; i > 0; i--)
    {
        if (name[i] == '/')
            return((char *)&name[i+1]);
    }
    return name;
}


#pragma mark -

static void PrintHelp(void) {
    printf("usage: %s [-vh] [-t [icns|png|gif|tiff|jpeg]] [-o outputfile] file\n", PROGRAM_STRING);
}
