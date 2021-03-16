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
-(void)showMBProgressHUD:(NSString *)labelText {
	// Make new MBProgressHUD and add it to the screen
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
	hud.mode = MBProgressHUDModeCustomView;
	hud.userInteractionEnabled = NO;
	hud.label.text = labelText;
	[hud hideAnimated:YES afterDelay:0.7f];
}


%new
-(void)handlePictureTab:(UITapGestureRecognizer *)tapGesture {
	// Get the ivar for the image source and get the ivar for the NSURLRequest, which contains the link for the profile picture
	RCTImageSource* imageSource = MSHookIvar<RCTImageSource *>(self, "_source");
	NSURLRequest* request = MSHookIvar<NSURLRequest *>(imageSource, "_request");
	
	// Add the profile picture link to our clipboard/pasteboard // absoluteString to make a NSString instead of NSURL
	UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = request.URL.absoluteString;

	// Call the method that shows our MBProgressHUD
	[self showMBProgressHUD:@"Copied link!"];
}





%new
-(void)handlePictureLongPress:(UILongPressGestureRecognizer *)holdGesture {
	if (holdGesture.state == UIGestureRecognizerStateEnded) {
		// Get the ivar for the image source and get the ivar for the NSURLRequest, which contains the link for the profile picture
		RCTImageSource* imageSource = MSHookIvar<RCTImageSource *>(self, "_source");
		NSURLRequest* request = MSHookIvar<NSURLRequest *>(imageSource, "_request");
		NSString* fullQualityLink = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"?size=128" withString:@"?size=2048"];

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        	// get image data
			NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:fullQualityLink]];
			if (imgData == nil) {
				// Call the method that shows our MBProgressHUD
				[self showMBProgressHUD:@"Error!"];
				return;
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				
				// https://stackoverflow.com/a/40373739 This answer helped me with the saving images to photo album
				// Save the image to the photo library by the imgData
				[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{

					PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
					[[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:imgData options:options];

				} completionHandler:^(BOOL success, NSError * _Nullable error) {
					dispatch_async(dispatch_get_main_queue(), ^{
						if (success) {
							[self showMBProgressHUD:@"Downloaded successfully!"];
						} 
						else {
							[self showMBProgressHUD:@"Error!"];
						}
					});
				}];
			});
    	});
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
-(void)showMBProgressHUD:(NSString *)labelText {
	// Make new MBProgressHUD and add it to the screen
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
	hud.mode = MBProgressHUDModeCustomView;
	hud.userInteractionEnabled = NO;
	hud.label.text = labelText;
	[hud hideAnimated:YES afterDelay:0.7f];
}


%new
-(void)handlePictureTab:(UITapGestureRecognizer *)tapGesture {
	// Get the absolute string of the inherited property sd_imageURL which contains the avatar url
	NSString* profilePictureLink = self.sd_imageURL.absoluteString;

	// Add the profile picture link to our clipboard/pasteboard
	UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = profilePictureLink;

	// Call the method that shows our MBProgressHUD
	[self showMBProgressHUD:@"Copied link!"];
}



%end