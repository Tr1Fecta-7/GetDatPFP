#import "MBProgressHUD.h"
#import <Photos/Photos.h>

@interface DCDFastImageView : UIView

-(id)init;

// %new
-(void)showMBProgressHUD:(NSString *)labelText;

@end

@interface RCTImageSource : NSObject 
@end


@interface DCDAvatarView : UIImageView

@property NSURL* sd_imageURL;

-(id)initWithSize:(CGSize)size;

// %new
-(void)showMBProgressHUD:(NSString *)labelText;

@end