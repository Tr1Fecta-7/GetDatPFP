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


		UILongPressGestureRecognizer* holdGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePictureLongPress:)];
		holdGesture.minimumPressDuration = 0.8;
		[self addGestureRecognizer:holdGesture];
	}

	return self;
}


%new
-(void)downloadImage:(NSString *)profilePicURL {
	NSLog(@"TWEAK TAP222: WORK3");
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // get image data, then init a UIImage
        NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:profilePicURL]];
		NSLog(@"TWEAK TAP222: WORK3");
        if (imgData == nil) {
			// Make new MBProgressHUD and add it to the screen
			MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
			hud.mode = MBProgressHUDModeCustomView;
			hud.label.text = @"Error!";
			[hud hideAnimated:YES afterDelay:1.2f];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // create image
            UIImage *img = [UIImage imageNamed:@"profilePic"];
            img = [UIImage imageWithData:imgData];
            // save image to photos, no callback
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);

			// Make new MBProgressHUD and add it to the screen
			MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
			hud.mode = MBProgressHUDModeCustomView;
			hud.label.text = @"Downloaded successfully!";
			[hud hideAnimated:YES afterDelay:1.2f];
        });
    });
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





%new
-(void)handlePictureLongPress:(UILongPressGestureRecognizer *)holdGesture {
	NSLog(@"TWEAK TAP222: WORK");
	if (holdGesture.state == UIGestureRecognizerStateEnded) {
		// Get the ivar for the image source and get the ivar for the NSURLRequest, which contains the link for the profile picture
		RCTImageSource* imageSource = MSHookIvar<RCTImageSource *>(self, "_source");
		NSURLRequest* request = MSHookIvar<NSURLRequest *>(imageSource, "_request");
		NSLog(@"TWEAK TAP222: WORK2");
		[self downloadImage:request.URL.absoluteString];
	}
	
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