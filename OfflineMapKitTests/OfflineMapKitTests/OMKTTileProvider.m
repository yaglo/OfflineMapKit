//
//  OMKTTileProvider.m
//  OfflineMapKitTests
//
//  Created by Stanislav Yaglo on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OMKTTileProvider.h"

#import <CommonCrypto/CommonDigest.h>

@interface NSString (MD5)
- (NSString *) MD5Hash;
@end

@implementation NSString (MD5)
- (NSString *) MD5Hash {
	CC_MD5_CTX md5; CC_MD5_Init (&md5); CC_MD5_Update (&md5, [self UTF8String], [self length]);
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final (digest, &md5);
	NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   digest[0],  digest[1], digest[2],  digest[3],digest[4],  digest[5],digest[6],  digest[7],
                   digest[8],  digest[9], digest[10], digest[11], digest[12], digest[13], digest[14], digest[15]];
	return s;
	
}

@end


@implementation OMKTTileProvider
{
    NSString *documentsDirectory;
}

- (id)init
{
    self = [super init];
    if (self) {
        documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }
    return self;
}

- (UIImage *)mapView:(OMKMapView *)mapView imageForTileWithKey:(OMKTileKey *)tileKey
{
    NSString *contentScaleString = ([[UIScreen mainScreen] scale] > 1) ? @"@2x" : @"";
    NSString *tileURLString = [NSString stringWithFormat:@"http://md-tile.cloudmade.com/8ee2a50541944fb9bcedded5165f09d9/1%@/256/%d/%d/%d.png", contentScaleString, tileKey.zoomLevel, tileKey.x, tileKey.y];

    NSString *localPath = [documentsDirectory stringByAppendingPathComponent:[tileURLString MD5Hash]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        return [UIImage imageWithData:[NSData dataWithContentsOfFile:localPath]];
    }

    NSURL *tileURL = [NSURL URLWithString:tileURLString];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:tileURL]];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:localPath atomically:YES];
    return image;
}

@end
