//
//  NotificationService.swift
//  ImageNotification
//
//  Created by MACOS on 22/03/21.
//

import UserNotifications


class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
            self.contentHandler = contentHandler
            bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
            
            if let bestAttemptContent = bestAttemptContent {
                       // Modify the notification content here...
                       bestAttemptContent.title = "\(bestAttemptContent.title)"
                print(bestAttemptContent.title)
                print(bestAttemptContent.attachments)

                       var urlString:String? = nil
                if let urlImageString = request.content.userInfo["fcm_options"] as? Dictionary<String, String> {
                           urlString = urlImageString["image"]
                       }
                       
                       if urlString != nil, let fileUrl = URL(string: urlString!) {
                           print("fileUrl: \(fileUrl)")
                           
                           guard let imageData = NSData(contentsOf: fileUrl) else {
                               contentHandler(bestAttemptContent)
                               return
                           }
                           guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "image.jpg", data: imageData, options: nil) else {
                               print("error in UNNotificationAttachment.saveImageToDisk()")
                               contentHandler(bestAttemptContent)
                               return
                           }
                           
                           bestAttemptContent.attachments = [ attachment ]
                       }
                       
                       contentHandler(bestAttemptContent)
                   }
        }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

@available(iOSApplicationExtension 10.0, *)
extension UNNotificationAttachment {
    
    static func saveImageToDisk(fileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL?.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL!, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL!, options: options)
            print("success image attact")
            return attachment
        } catch let error {
            print("error \(error)")
        }
        
        return nil
    }
}
