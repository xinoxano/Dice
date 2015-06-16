//
//  HoneRegisteredParameter.m
//  HOneExample
//
//  Created by Jaanus Kase on 31.12.13.
//
//

#import "HNERegisteredCallback.h"
#import "HNEDocumentParameter.h"
#import "HNE+Private.h"
#import "HNEParameterStore.h"



@interface HNERegisteredCallback ()

@property (weak, nonatomic) HNE *hone;

@end



@implementation HNERegisteredCallback

- (instancetype)initWithHone:(HNE *)hone
{
	if (self = [super init]) {
		_hone = hone;
	}
	return self;
}

- (void)dealloc
{
	// For testing deallocation
}

- (void)runWithParameter:(HNEDocumentParameter *)parameter
{
	// Make sure that the data types match…
	if (self.valueDataType != parameter.dataType) { return; }

	// Don’t do anything if we don’t have a block or observer to run…
	if (!self.callbackBlock) { return; }
	if (!self.observer) { return; }
	
	void (^executor)(void) = nil;
		
	id currentValue = [self.hone.parameterStore parameterNativeValueForIdentifier:parameter.name inClass:self.objectClass];
	
	switch (self.valueDataType) {
	
		// For integer and float, we need to cast the block back to the correct signature…
		// I was otherwise getting strange behavior
		case HNETypeFloat: {
			void (^floatBlock)(id, CGFloat) = (void (^)(id, CGFloat))self.callbackBlock;
			executor = ^{ floatBlock(self.observer, [currentValue floatValue]); };
			break;
		}
			
		case HNETypeInt: {
			void (^integerBlock)(id, NSInteger) = (void (^)(id, NSInteger))self.callbackBlock;
			executor = ^{ integerBlock(self.observer, [currentValue integerValue]); };
			break;
		}
			
		case HNETypeBool: {
			void (^boolBlock)(id, BOOL) = (void (^)(id, BOOL))self.callbackBlock;
			executor = ^{ boolBlock(self.observer, [currentValue boolValue]); };
			break;
		}
			
		// For rich object types, no need to cast, just run the block

		case HNETypeString:
		case HNETypeColor:
		case HNETypeFont: {
			executor = ^{ self.callbackBlock(self.observer, currentValue); };
			break;
		}
	}

	if (!executor) { return; }
	
	if ([NSThread isMainThread]) {
		executor();
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
			executor();
		});
	}

}

@end
