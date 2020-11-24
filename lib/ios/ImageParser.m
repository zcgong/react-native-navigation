#import "ImageParser.h"
#import "NullImage.h"
#import <React/RCTConvert.h>
#import <React/RCTImageSource.h>

@implementation ImageParser

+ (Image *)parse:(NSDictionary *)json key:(NSString *)key {
    id data = json[key];
    if (!data) {
        return [NullImage new];
    }

    UIImage *image;

    if ([data isKindOfClass:[NSDictionary class]] &&
        [data[@"system"] isKindOfClass:[NSString class]]) {
        if (@available(iOS 13.0, *)) {
            image = [UIImage systemImageNamed:data[@"system"]];
        }
        if (!image) {
            image = [RCTConvert UIImage:data[@"fallback"]];
        }
    } else {
        RCTImageSource *imageSource = [RCTConvert RCTImageSource:json[key]];
        NSURL* URL = imageSource.request.URL;
        NSString *scheme = URL.scheme.lowercaseString;
        if ([scheme isEqualToString:@"https"]) {
            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:URL]];
            CGFloat scale = imageSource.scale;
            if (!scale && imageSource.size.width) {
                // If no scale provided, set scale to image width / source width
                scale = CGImageGetWidth(image.CGImage) / imageSource.size.width;
            }
            
            if (scale) {
                image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
            }
        } else {
            image = [RCTConvert UIImage:data];
        }
    }

    return [[Image alloc] initWithValue:image];
}

@end
