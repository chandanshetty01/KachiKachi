//
//  KKMailComposerManager.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

typedef void(^completionBlkWithInteger)(NSInteger index);

@interface KKMailComposerManager : NSObject <MFMailComposeViewControllerDelegate>
{
    
}

- (void)displayMailComposerSheet:(UIViewController*)inController
                    toRecipients:(NSArray*)toRecipients
                    ccRecipients:(NSArray*)ccRecipients
                  attachmentData:(NSData*)attachmentData
              attachmentMimeType:(NSString*)attachmentMimeType
              attachmentFileName:(NSString*)attachmentFileName
                       emailBody:(NSString*)emailBody
                    emailSubject:(NSString*)emailSubject
                      completion:(completionBlkWithInteger)completionBlk;
+ (KKMailComposerManager*) sharedManager;

@end
