//
//  AppDelegate.swift
//  EGrab
//
//  Created by Ethan McMullan on 06/07/2016.
//  Copyright © 2016 Ethan McMullan. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        
        let url = notification.informativeText
        
        let pb = NSPasteboard.generalPasteboard()
        pb.clearContents()
        pb.setString(url!, forType: NSStringPboardType)
        
        NSUserNotificationCenter.defaultUserNotificationCenter().removeDeliveredNotification(notification)
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

