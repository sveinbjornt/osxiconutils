/*
 pic2icns - command line program that converts images to icns files
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

#import <Cocoa/Cocoa.h>
#import "IconFamily.h"

static void print_usage ();
static void writeIcon (NSImage *img, NSString *path);

int main (int argc, const char * argv[])
{
    NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc] init];
	NSApplication		*app = [NSApplication sharedApplication]; // establish connection to window server
	NSFileManager		*fm = [NSFileManager defaultManager];
	
	if (argc < 3)
	{
			print_usage();
			return 1;
	}
    
	// get nsstrings from arguments
	NSString *srcPath = [[NSString stringWithCString: argv[1]] stringByExpandingTildeInPath];
	NSString *destPath = [[NSString stringWithCString: argv[2]] stringByExpandingTildeInPath];
	
	// make sure source file exists
	if (![fm fileExistsAtPath: srcPath])
	{
		fprintf(stderr, "File %s does not exist\n", argv[1]);
		return EXIT_FAILURE;
	}
	
	// get nsimage from source file
	NSImage *img = [[NSImage alloc] initWithContentsOfFile: srcPath];
	if (img == NULL)
	{
		fprintf(stderr, "Error reading image file\n");
		return EXIT_FAILURE;
	}
	
	// write icon
	writeIcon(img, destPath);
	
	// make sure icon was created
	if (![fm fileExistsAtPath: destPath])
	{
		fprintf(stderr, "Failed to create icon\n", argv[1]);
		return EXIT_FAILURE;
	}
	
	[pool drain];
    return EXIT_SUCCESS;
}

void print_usage ()
{
	fprintf(stdout, "Usage:  pic2icns src dest\n");
}

						 
void writeIcon (NSImage *img, NSString *path)
{
		IconFamily *iconFam = [[IconFamily alloc] initWithThumbnailsOfImage: img];
		if (iconFam == NULL) 
		{ 
			fprintf(stderr, "Error generating icon from image\n");
			exit(EXIT_FAILURE); 
		}
		[iconFam writeToFile: path];
		[iconFam release];
}
