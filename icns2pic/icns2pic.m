/*
 icns2pic - command line program that converts icns files to images
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

static void print_usage (void);
static void writeImageFromIcon (IconFamily *icon, NSString *destPath);

int main (int argc, const char * argv[])
{
    NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc] init];
	NSApplication		*app = [NSApplication sharedApplication]; // establish connection to window server
	
	if (argc < 3)
	{
		print_usage();
		return 1;
	}

	// get nsstrings from arguments
	NSString *srcPath = [[NSString stringWithCString: argv[1]] stringByExpandingTildeInPath];
	NSString *destPath = [[NSString stringWithCString: argv[2]] stringByExpandingTildeInPath];
	
	// make sure source file exists
	if (![[NSFileManager defaultManager] fileExistsAtPath: srcPath])
	{
		fprintf(stderr, "File '%s' does not exist\n", argv[1]);
		return EXIT_FAILURE;
	}
	
	// get nsimage from source file
	IconFamily *icon = [[IconFamily alloc] initWithContentsOfFile: srcPath];
	if (icon == NULL)
	{
		fprintf(stderr, "Error reading icon file\n");
		return EXIT_FAILURE;
	}
	
	// write icon
	writeImageFromIcon(icon, destPath);
	
	[icon release];
	[pool drain];
    return EXIT_SUCCESS;
}

static void writeImageFromIcon (IconFamily *icon, NSString *destPath)
{	
	NSData				*data;
	NSDictionary		*dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
	NSBitmapImageRep	*imgRep = [icon bitmapImageRepWithAlphaForIconFamilyElement: kThumbnail32BitData];
	
	if (imgRep == NULL)
	{
		fprintf(stderr, "Failed to get image representation from icon\n");
		exit(EXIT_FAILURE);
	}
	
	// use suffix to determine what kind of data to write out
	if ([destPath hasSuffix: @"jpg"] || [destPath hasSuffix: @"jpeg"])
		data = [imgRep representationUsingType: NSJPEGFileType properties:dict];
	else if ([destPath hasSuffix: @"gif"])
		data = [imgRep representationUsingType: NSGIFFileType properties:dict];
	else if ([destPath hasSuffix: @"png"])
		data = [imgRep representationUsingType: NSPNGFileType properties:dict];
	else if ([destPath hasSuffix: @"tiff"] || [destPath hasSuffix: @"tif"])
		data = [imgRep representationUsingType: NSTIFFFileType properties:dict];
	else if ([destPath hasSuffix: @"bmp"])
		data = [imgRep representationUsingType: NSBMPFileType properties:dict];
	else
	{
		// with no suffix, we append .tiff to destination filename and write out TIFF data
		fprintf(stdout, "No image kind specified via suffix.  Assuming tiff.\n");
		data = [imgRep representationUsingType: NSTIFFFileType properties:dict];
		destPath = [destPath stringByAppendingString: @".tiff"];
	}
	[data writeToFile: destPath atomically:YES];
	
	// make sure icon was created
	if (![[NSFileManager defaultManager] fileExistsAtPath: destPath])
	{
		fprintf(stderr, "Failed to create image at '%s'\n", [destPath cString]);
		exit(EXIT_FAILURE);
	}
	
}

static void print_usage ()
{
	fprintf(stdout, "Usage:  icns2pic src dest\n");
}









