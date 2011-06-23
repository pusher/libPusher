
#import <Foundation/Foundation.h>


@interface NSString (Hashing)
- (NSString *)MD5Hash;
@end

NSString *md5(NSString *str);