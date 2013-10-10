//
// © 2008 Eugene Solodovnykov
// http://idevblog.info/mobileprovision-files-structure-and-reading/ (dead link)
//
// Abstracted from https://gist.github.com/jessearmand/711794 in 2013 by David Welch

#import <Foundation/Foundation.h>

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
	if (argc < 3) {
        printf("Usage: mpParse -f <fileName> [-o <option>]\n");
        return 1001;
	}
    
	//get arguments
	NSUserDefaults *arguments = [NSUserDefaults standardUserDefaults];
	NSString *fileName = [arguments stringForKey:@"f"];
	NSString *propertyName = [arguments stringForKey:@"o"];
	if (!fileName) {
	    fileName = [arguments stringForKey:@"-file"];
	    if (!fileName) {
	        return 1001;
	    }
	}
	if (!propertyName) {
	    propertyName = [arguments stringForKey:@"-option"];
	    if	(!propertyName) {
	        propertyName = @"type";
	    }
	}
	
	//get plist XML
	NSString *fileString = [[NSString alloc] initWithContentsOfFile:fileName];
	NSScanner *scanner = [[NSScanner alloc] initWithString:fileString];
	[fileString release];
	if ([scanner scanUpToString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>" intoString:NULL]) {
	    NSString *plistString;
	    if ([scanner scanUpToString:@"</plist>" intoString:&plistString]) {
	        [scanner release];
            NSDictionary *plist = [[plistString stringByAppendingString:@"</plist>"] propertyList];
			
            // get profile type
            // possible types:
            //		ad-hoc
            //		appstore
            //		debug
            if ([propertyName isEqualToString:@"type"]) {
                if ([plist valueForKeyPath:@"ProvisionedDevices"]) {
                    if ([[plist valueForKeyPath:@"Entitlements.get-task-allow"] boolValue]) {
                        printf("debug\n");
                    } else {
                        printf("ad-hoc\n");
                    }
                } else {
                    printf("appstore\n");
				}
			} else
			    // get the UUID of the profile
			    if ([propertyName isEqualToString:@"uuid"]) {
			        printf("%s\n", [[plist valueForKeyPath:@"UUID"] cStringUsingEncoding:NSUTF8StringEncoding]);
				} else
				    // get the supported devices list
				    if ([propertyName isEqualToString:@"devices"]) {
				        NSArray *devices = [plist valueForKeyPath:@"ProvisionedDevices"];
                        if (devices) {
                            for (NSString *deviceId in devices) {
                                printf("%s\n", [deviceId cStringUsingEncoding:NSUTF8StringEncoding]);
                            }
				        }
                    }
		} else {
			[scanner release];
			return 1002;
		}
	} else {
		[scanner release];
		return 1002;
	}
    
	[pool drain];
	return 0;
}