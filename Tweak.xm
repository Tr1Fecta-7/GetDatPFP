#import "Tweak.h"


%hook DCDFastImageView

-(instancetype)init {
	if ((self = %orig)) {
		// Setup our UITapGestureRecognizer to recognize 2 taps, without blocking any other touches on the profile picture
		UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePictureTab:)];
		tapGesture.delegate = (id<UIGestureRecognizerDelegate>)self;
		tapGesture.numberOfTapsRequired = 2;
		tapGesture.cancelsTouchesInView = NO;
		[self addGestureRecognizer:tapGesture];
	}

	return self;
}


%new
-(void)handlePictureTab:(UITapGestureRecognizer *)tapGesture {
	// Get the ivar for the image source and get the ivar for the NSURLRequest, which contains the link for the profile picture
	RCTImageSource* imageSource = MSHookIvar<RCTImageSource *>(self, "_source");
	NSURLRequest* request = MSHookIvar<NSURLRequest *>(imageSource, "_request");
	
	// Add the profile picture link to our clipboard/pasteboard // absoluteString to make a NSString instead of NSURL
	UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = request.URL.absoluteString;

	// Make new MBProgressHUD and add it to the screen
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
	hud.mode = MBProgressHUDModeCustomView;
	hud.label.text = @"Copied link!";
	[hud hideAnimated:YES afterDelay:1.2f];
}

%end



%hook DCDAvatarView

-(id)initWithSize:(CGSize)size {
	if ((self = %orig)) {
		// Setup our UITapGestureRecognizer to recognize 2 taps, without blocking any other touches on the profile picture
		UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePictureTab:)];
		tapGesture.delegate = (id<UIGestureRecognizerDelegate>)self;
		tapGesture.numberOfTapsRequired = 2;
		tapGesture.cancelsTouchesInView = YES;
		[self addGestureRecognizer:tapGesture];
	}
	return self;
}

%new
-(void)handlePictureTab:(UITapGestureRecognizer *)tapGesture {
	// Get the absolute string of the inherited property sd_imageURL which contains the avatar url
	NSString* profilePictureLink = self.sd_imageURL.absoluteString;

	// Add the profile picture link to our clipboard/pasteboard
	UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = profilePictureLink;

	/// Make new MBProgressHUD and add it to the screen
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
	hud.mode = MBProgressHUDModeCustomView;
	hud.label.text = @"Copied link!";
	[hud hideAnimated:YES afterDelay:1.2f];
}


%end