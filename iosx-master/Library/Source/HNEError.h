//
//  HNEError.h
//  Hone
//
//  Created by Jaanus Kase on 13.06.14.
//
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *const HNEErrorDomain;

typedef NS_ENUM(NSInteger, HNEErrorCode) {
	// Trying to create an object with duplicate name/alias
	HNEErrorCodeApplicationObjectExists,
	
	// Trying to create a parameter with duplicate name/alias
	HNEErrorCodeApplicationObjectParameterExists,
	
	HNEErrorCodeApplicationParameterValueOverrideExists,
	HNEErrorCodeApplicationThemeExists,
	HNEErrorCodeNameCannotBeEmpty,
	HNEErrorCodeInvalidDocumentFormatVersion,
	HNEErrorCodeDocumentMustBeFileURL,
	
	/// Cannot retrieve the document from cloud. Examine the error message for details.
	HNEErrorCodeCloudNetworkError,
	
	/// The project exists on the cloud, but no manifest has been uploaded for it.
	HNEErrorCodeCloudManifestNotPresent,
	
	/// Error codes for invalid parameter values
	HNEErrorCodeInvalidSerializedParameterValue,
	
	/// Attempting to start Hone multiple times
	HNEErrorCodeInvalidStartRequest,
	
	/// Invalid or missing parameters when starting
	HNEErrorCodeInvalidStartParameters,
    
    /// Many Hone operations are only allowed in design/development mode. If you attempt them in production mode, you’ll receive this error.
    HNEErrorCodeOperationNotAllowedInProductionMode
};
