#import <Preferences/Preferences.h>
#import <Preferences/PSSpecifier.h>

#define TweakpreferencePath @"/User/Library/Preferences/com.pw5a29.actualbattery.plist"
#define updateNofitication @"com.pw5a29.actualbattery.settingschanged"

@interface ActualprefsListController: PSListController {
}
@end


@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(id)arg1;

@optional
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1;
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 inTableView:(id)arg2;
@end

@interface ActualprefsCustomCell : UITableViewCell <PreferencesTableCustomView> {
    UILabel *label;
    UILabel *underLabel;
}
@end

@implementation ActualprefsCustomCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    if (self) {
        int width = [[UIScreen mainScreen] bounds].size.width;
        CGRect labelFrame = CGRectMake(0, -15, width, 60);
        CGRect underLabelFrame = CGRectMake(0, 20, width, 60);
        
        label = [[UILabel alloc] initWithFrame:labelFrame];
        [label setNumberOfLines:1];
        label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:44];
        [label setText:@"Actual Battery"];
        [label setBackgroundColor:[UIColor clearColor]];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        
        underLabel = [[UILabel alloc] initWithFrame:underLabelFrame];
        [underLabel setNumberOfLines:1];
        underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        [underLabel setText:@"by pw5a29 (Philip Wong)"];
        [underLabel setBackgroundColor:[UIColor clearColor]];
        underLabel.textColor = [UIColor grayColor];
        underLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:label];
        [self addSubview:underLabel];
        
    }
    return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
    CGFloat prefHeight = 75.0;
    return prefHeight;
}
@end

@implementation ActualprefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Actualprefs" target:self] retain];
	}
	return _specifiers;
}
-(id) readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *TweakSettings = [NSDictionary dictionaryWithContentsOfFile:TweakpreferencePath];
    if (!TweakSettings[specifier.properties[@"key"]]) {
        return specifier.properties[@"default"];
    }
    return TweakSettings[specifier.properties[@"key"]];
}

-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:TweakpreferencePath]];
    [defaults setObject:value forKey:specifier.properties[@"key"]];
    [defaults writeToFile:TweakpreferencePath atomically:YES];
    CFStringRef toPost = (CFStringRef)updateNofitication;
    if(toPost) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
}

- (void)respring:(id)sender {
    system("killall backboardd && killall SpringBoard");
}
- (void)PhilipTwitter:(id)sender {
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *tweetbot = [NSURL URLWithString:@"tweetbot:///user_profile/pw5a29"];
    if ([app canOpenURL:tweetbot]) {
        [app openURL:tweetbot];
    }
    
    else {
        NSURL *twitterapp = [NSURL URLWithString:@"twitter:///user?screen_name=pw5a29"];
        if ([app canOpenURL:twitterapp]) {
            [app openURL:twitterapp];
        }
        
        else {
            NSURL *twitterweb = [NSURL URLWithString:@"http://twitter.com/pw5a29"];
            [app openURL:twitterweb];
        }
    }
}
@end

// vim:ft=objc
