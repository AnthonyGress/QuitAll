@interface SBDisplayItem: NSObject
	@property (nonatomic,copy,readonly) NSString * bundleIdentifier;               //@synthesize bundleIdentifier=_bundleIdentifier - In the implementation block
@end

@interface SBApplication : NSObject
	@property (nonatomic,readonly) NSString * bundleIdentifier;
@end

@interface SBMediaController : NSObject
	@property (nonatomic, weak,readonly) SBApplication * nowPlayingApplication;
	+(id)sharedInstance;
@end

//interfaces
@interface SBMainSwitcherViewController: UIViewController
	+ (id)sharedInstance;
	-(id)recentAppLayouts;
	-(void)_rebuildAppListCache;
	-(void)_destroyAppListCache;
	-(void)_removeCardForDisplayIdentifier:(id)arg1 ;
	-(void)_deleteAppLayout:(id)arg1 forReason:(long long)arg2;
@end

@interface SBAppLayout:NSObject
	@property (nonatomic,copy) NSDictionary * rolesToLayoutItemsMap;
@end

@interface SBFluidSwitcherItemContainer : UIView
	-(void)quitAll:(bool)shouldSkipNowPlaying;
@end

%hook SBFluidSwitcherItemContainer

	- (void)scrollViewWillEndDragging: (UIScrollView *)arg1 withVelocity: (CGPoint)arg2 targetContentOffset: (CGPoint*)arg3
	{
		%orig;

		if (arg1.contentOffset.y <= -140)
		{
			UIAlertController * alert = [UIAlertController
									alertControllerWithTitle:@"QuitAll"
									message:@"What would you like to do?"
									preferredStyle:UIAlertControllerStyleActionSheet];

			UIAlertAction* killAllButton = [UIAlertAction
		                              actionWithTitle:@"Kill All Apps!"
		                              style:UIAlertActionStyleDestructive
		                              handler:^(UIAlertAction * action) {
																				[self quitAll:NO];
								}];

			UIAlertAction* killAllExceptButton = [UIAlertAction
		                              actionWithTitle:@"Kill All Except Music!"
		                              style:UIAlertActionStyleDestructive
		                              handler:^(UIAlertAction * action) {
																				[self quitAll:YES];
								}];


				UIAlertAction* cancelButton = [UIAlertAction
								actionWithTitle:@"Cancel"
								style:UIAlertActionStyleCancel
								handler:^(UIAlertAction * action) {
								}];

			  [alert addAction:killAllButton];
				[alert addAction:killAllExceptButton];
				[alert addAction:cancelButton];

				[[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
		}

	}

	%new
	-(void)quitAll:(bool)shouldSkipNowPlaying
	{
		//remove the apps
		SBMainSwitcherViewController *mainSwitcher = [%c(SBMainSwitcherViewController) sharedInstance];
		NSArray *items = [mainSwitcher recentAppLayouts];

		NSString *nowPlayingID = [[[%c(SBMediaController) sharedInstance] nowPlayingApplication] bundleIdentifier];

		for(SBAppLayout *item in items)
		{
			NSString *bundleID = [[[item rolesToLayoutItemsMap] objectForKey: @1] bundleIdentifier];

			if (shouldSkipNowPlaying && [bundleID isEqualToString: nowPlayingID])
				continue;
			else
				[mainSwitcher _deleteAppLayout:item forReason: 1];
		}

		dispatch_async(dispatch_get_main_queue(), ^{
				UINotificationFeedbackGenerator* _hapticFeedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
				[_hapticFeedbackGenerator prepare];
				[_hapticFeedbackGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
				_hapticFeedbackGenerator = nil;
		});
	}

%end
