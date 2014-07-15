//
//  KKMailComposerManager.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKMailComposerManager.h"

@implementation KKMailComposerManager

+ (id) sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark - Compose Mail/SMS

// -------------------------------------------------------------------------------
//	displayMailComposerSheet
//  Displays an email composition interface inside the application.
//  Populates all the Mail fields.
// -------------------------------------------------------------------------------
- (void)displayMailComposerSheet:(UIViewController*)inController
                    toRecipients:(NSArray*)toRecipients
                    ccRecipients:(NSArray*)ccRecipients
                  attachmentData:(NSData*)attachmentData
              attachmentMimeType:(NSString*)attachmentMimeType
              attachmentFileName:(NSString*)attachmentFileName
                       emailBody:(NSString*)emailBody
                    emailSubject:(NSString*)emailSubject
{
    if ([MFMailComposeViewController canSendMail])
        // The device can send email.
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        [picker setSubject:emailSubject];
        
        // Set up recipients
        if(toRecipients)
            [picker setToRecipients:toRecipients];
        if(ccRecipients)
            [picker setCcRecipients:ccRecipients];
        
        if(attachmentData)
            [picker addAttachmentData:attachmentData mimeType:attachmentMimeType fileName:attachmentFileName];
        // Fill out the email body text
        [picker setMessageBody:emailBody isHTML:NO];
        
        [inController presentViewController:picker animated:YES completion:NULL];
    }
}

#pragma mark - Delegate Methods

// -------------------------------------------------------------------------------
//	mailComposeController:didFinishWithResult:
//  Dismisses the email composition interface when users tap Cancel or Send.
//  Proceeds to update the message field with the result of the operation.
// -------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Result: Mail sending canceled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Result: Mail saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Result: Mail sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Result: Mail sending failed");
			break;
		default:
			NSLog(@"Result: Mail not sent");
			break;
	}
    
	[controller dismissViewControllerAnimated:YES completion:NULL];
}


@end
