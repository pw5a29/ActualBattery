#include <IOKit/IOKitLib.h>
#include <IOKit/ps/IOPowerSources.h>
#include <IOKit/ps/IOPSKeys.h>
#include <IOKit/pwr_mgt/IOPM.h>
#define exampleTweakPreferencePath @"/User/Library/Preferences/com.pw5a29.actualbattery.plist"

static int Enabled = 1;

@interface SBUIController
-(int)displayBatteryCapacityAsPercentage;
+(id)sharedInstance;
@end

@interface PLBatteryPropertiesEntry// : PLEntry
+(instancetype) batteryPropertiesEntry;
@property(readonly, nonatomic) BOOL draining;
@property(readonly, nonatomic) BOOL isPluggedIn;
@property(readonly, nonatomic) NSString *chargingState;
@property(readonly, nonatomic) int batteryTemp;
@property(readonly, nonatomic) NSNumber *connectedStatus;
@property(readonly, nonatomic) NSNumber *adapterInfo;
@property(readonly, nonatomic) int chargingCurrent;
@property(readonly, nonatomic) BOOL fullyCharged;
@property(readonly, nonatomic) BOOL isCharging;
@property(readonly, nonatomic) int cycleCount;
@property(readonly, nonatomic) int designCapacity;
@property(readonly, nonatomic) double rawMaxCapacity;
@property(readonly, nonatomic) double maxCapacity;
@property(readonly, nonatomic) double rawCurrentCapacity;
@property(readonly, nonatomic) double currentCapacity;
@property(readonly, nonatomic) int current;
@property(readonly, nonatomic) int voltage;
@property(readonly, nonatomic) BOOL isCritical;
@property(readonly, nonatomic) double rawCapacity;
@property(readonly, nonatomic) double capacity;
- (void)dealloc;
- (id)humanReadableChargingStateFromIORegistryEntryDictionary:(id)arg1;
- (id)initEntryWithIORegistryEntry:(unsigned int)arg1;
- (id)init;
@end

static void loadPreferences() {
NSMutableDictionary *TweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:exampleTweakPreferencePath];

NSNumber *EnabledOptionKey = TweakSettings[@"Enabled"];
Enabled = EnabledOptionKey ? [EnabledOptionKey intValue] : 1;
}

%ctor {
CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPreferences, CFSTR("com.pw5a29.actualbattery.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
loadPreferences();
}

%hook SBUIController
-(int)displayBatteryCapacityAsPercentage
{
if (Enabled == 1)
    {
    if (%c(PLBatteryPropertiesEntry))
        {
        CGFloat rawCurrent = ((PLBatteryPropertiesEntry*)[%c(PLBatteryPropertiesEntry)  batteryPropertiesEntry]).rawCurrentCapacity;
        CGFloat rawMax = ((PLBatteryPropertiesEntry*)[%c(PLBatteryPropertiesEntry)  batteryPropertiesEntry]).rawMaxCapacity;
        CGFloat rawActual = floor((rawCurrent / rawMax) * 100);
        if (rawActual > 100)
        rawActual = 100;
        else if (rawActual < 0)
        rawActual = 0;
        return rawActual;
        }
    else
        {
        CGFloat rawCurrentCapacity = -100;
        CGFloat rawMaxCapacity = -100;
        io_service_t powerSource = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPMPowerSource"));

        CFNumberRef rawCurrentCapacityNum = (CFNumberRef)IORegistryEntryCreateCFProperty(powerSource, CFSTR("AppleRawCurrentCapacity"), kCFAllocatorDefault, 0);
        CFNumberGetValue(rawCurrentCapacityNum, kCFNumberCGFloatType, &rawCurrentCapacity);
        CFRelease(rawCurrentCapacityNum);

        CFNumberRef rawMaxCapacityNum = (CFNumberRef)IORegistryEntryCreateCFProperty(powerSource, CFSTR("AppleRawMaxCapacity"), kCFAllocatorDefault, 0);
        CFNumberGetValue(rawMaxCapacityNum, kCFNumberCGFloatType, &rawMaxCapacity);
        CFRelease(rawMaxCapacityNum);

        CGFloat rawActual = floor((rawCurrentCapacity / rawMaxCapacity) * 100);
        if (rawActual > 100)
        rawActual = 100;
        else if (rawActual < 0)
        rawActual = 0;
        if (rawCurrentCapacity == -100 || rawMaxCapacity == -100)
        rawActual = NAN;
        return rawActual;
        }
    }
if (Enabled == 2)
{
if (%c(PLBatteryPropertiesEntry))
    {
        CGFloat rawCurrent = ((PLBatteryPropertiesEntry*)[%c(PLBatteryPropertiesEntry)      batteryPropertiesEntry]).rawCurrentCapacity;
        CGFloat Max = ((PLBatteryPropertiesEntry*)[%c(PLBatteryPropertiesEntry) batteryPropertiesEntry]).maxCapacity;
        CGFloat rawActual = floor((rawCurrent / Max) * 100);
        if (rawActual < 0)
        rawActual = 0;
        return rawActual;
    }
    else
    {
        CGFloat rawCurrentCapacity = -100;
        CGFloat designCapacity = -100;
        io_service_t powerSource = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPMPowerSource"));

        CFNumberRef rawCurrentCapacityNum = (CFNumberRef)IORegistryEntryCreateCFProperty(powerSource, CFSTR("AppleRawCurrentCapacity"), kCFAllocatorDefault, 0);
        CFNumberGetValue(rawCurrentCapacityNum, kCFNumberCGFloatType, &rawCurrentCapacity);
        CFRelease(rawCurrentCapacityNum);

        CFNumberRef designCapacityNum = (CFNumberRef)IORegistryEntryCreateCFProperty(powerSource, CFSTR(kIOPMPSDesignCapacityKey), kCFAllocatorDefault, 0);
        CFNumberGetValue(designCapacityNum, kCFNumberCGFloatType, &designCapacity);
        CFRelease(designCapacityNum);

        CGFloat rawActual = floor((rawCurrentCapacity / designCapacity) * 100);
        if (rawActual < 0)
        rawActual = 0;
        if (rawCurrentCapacity == -100 || designCapacity == -100)
        rawActual = NAN;
        return rawActual;
    }
}

if (Enabled == 3)
    {
        return %orig;
    }
else
    {
        return %orig;
    }
}
%end