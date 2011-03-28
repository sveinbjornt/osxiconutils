/*
    seticon - command line program to set icon of Mac OS X files
    Copyright (C) 2003-2005 Sveinbjorn Thordarson <sveinbjornt@simnet.is>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*/

/*
	0.3 - * code cleanup, use image feature
	0.2 - * sysexits.h constants used as exit values
	0.1 - * Initial release
*/

#import <Cocoa/Cocoa.h>
#import "IconFamily.h"

#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <sys/stat.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <sysexits.h>

#define		PROGRAM_STRING  	"seticon"
#define		VERSION_STRING		"0.3"
#define		AUTHOR_STRING 		"Sveinbjorn Thordarson"
#define		OPT_STRING			"vhdi" 

static void PrintVersion (void);
static void PrintHelp (void);

int main (int argc, const char * argv[]) 
{
    NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc] init];
	NSApplication		*app = [NSApplication sharedApplication];

	int					rc, optch;
	char				*src;
    static char			optstring[] = OPT_STRING;

	BOOL				sourceIsIcns = NO;
	BOOL				sourceIsImage = NO;

    while ( (optch = getopt(argc, (char * const *)argv, optstring)) != -1)
    {
        switch(optch)
        {
            case 'v':
                PrintVersion();
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
	
	if (sourceIsIcns && sourceIsImage)
	{
		fprintf(stderr, "%s: Both -i and -d parameters specified.\nSource cannot both be icns and image", PROGRAM_STRING);
        PrintHelp();
        return EX_USAGE;
	}

	//check if a correct number of arguments was submitted
    if (argc < 3)
    {
        fprintf(stderr, "%s: Too few arguments.\n", PROGRAM_STRING);
        PrintHelp();
		return EX_USAGE;
    }
	
	(char *)src = (char *)argv[optind];

	//get the icon
	IconFamily *icon;
	NSString *srcPath = [NSString stringWithCString: src];
	
	if (sourceIsIcns)
	{
		icon = [IconFamily iconFamilyWithContentsOfFile: srcPath];
		if (icon == NULL)
		{
			fprintf(stderr, "Failed to read icns file '%s'.\n", src);
			return EXIT_FAILURE;
		}
	}
	else if (sourceIsImage)
	{
		NSImage *image = [[NSImage alloc] initWithContentsOfFile: srcPath];
		if (image == NULL)
		{
			fprintf(stderr, "Failed to read image file '%s'.\n", src);
			return EXIT_FAILURE;
		}
		
		icon = [IconFamily iconFamilyWithThumbnailsOfImage: image];
		if (icon == NULL)
		{
			fprintf(stderr, "Failed to generate icon from image.\n", src);
			return EXIT_FAILURE;
		}
		
		[image release];
	}
	else
	{
		icon = [IconFamily iconFamilyWithIconOfFile: srcPath];
		if (icon == NULL)
		{
			fprintf(stderr, "Failed to get icon of file '%s'.\n", src);
			return EXIT_FAILURE;
		}
	}
	
	//all remaining arguments should be files
	// these get their icon set to the icon we just retrieved
    for (; optind < argc; ++optind)
	{
		BOOL isDir;
		NSString *dstPath = [NSString stringWithCString: (char *)argv[optind]];
		
		if ([[NSFileManager defaultManager] fileExistsAtPath: dstPath isDirectory: &isDir] && isDir)
			[icon setAsCustomIconForDirectory: dstPath];
		else
			[icon setAsCustomIconForFile: dstPath];
	}
	
    [pool drain];
    return EX_OK;
}

#pragma mark -

////////////////////////////////////////
// Print version and author to stdout
////////////////////////////////////////

static void PrintVersion (void)
{
    printf("%s v. %s\n", PROGRAM_STRING, VERSION_STRING);
}

////////////////////////////////////////
// Print help string to stdout
////////////////////////////////////////

static void PrintHelp (void)
{
    printf("usage: %s [-vhdi] [source] [file ...]\n", PROGRAM_STRING);
}

