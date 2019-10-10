#import "MBProgressHUD.h"

@interface DCDFastImageView : UIView

-(id)init;

@end

@interface RCTImageSource : NSObject 
@end


@interface DCDAvatarView : UIImageView

@property NSURL* sd_imageURL;

-(id)initWithSize:(CGSize)size;

@end