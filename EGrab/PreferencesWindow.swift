//
//  PreferencesWindow.swift
//  EGrab
//
//  Created by Ethan McMullan on 06/07/2016.
//  Copyright © 2016 Ethan McMullan. All rights reserved.
//

import Cocoa
import AppKit
import MASShortcut
import Carbon


let MASCustomShortcutKey = "customShortcut"
let MASCustomShortcutEnabledKey = "customShortcutEnabled"
let MASHardcodedShortcutEnabledKey = "hardcodedShortcutEnabled"

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {
    
    var delegate: PreferencesWindowDelegate?
    
    @IBOutlet var authKeyField: NSTextField!
    @IBOutlet var uploadTextField: NSTextField!
    @IBOutlet var shortcutView: MASShortcutView!
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
        
        print("opened")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let uploadURL = defaults.stringForKey("uploadURL") ?? DEFAULT_UPLOADURL
        uploadTextField.stringValue = uploadURL
        
        let authK = defaults.stringForKey("authKey") ?? DEFAULT_AUTHKEY
        authKeyField.stringValue = authK
        
        defaults.registerDefaults([
            MASHardcodedShortcutEnabledKey: true,
            MASCustomShortcutEnabledKey: true
            ])
        
        shortcutView.associatedUserDefaultsKey = MASCustomShortcutKey
    
        
        shortcutView.shortcutValueChange = { (sender) in
            
            let callback: (() -> Void)!
            
            callback = {
            }
            
            
            MASShortcutMonitor.sharedMonitor().registerShortcut(self.shortcutView.shortcutValue, withAction: callback)
        }
        
        MASShortcutMonitor.sharedMonitor().registerShortcut(self.shortcutView.shortcutValue, withAction: {
        })
        
        
    }
    
    func windowWillClose(notification: NSNotification) {
        print("CALLED")
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(authKeyField.stringValue, forKey: "authKey")
        defaults.setValue(uploadTextField.stringValue, forKey: "uploadURL")
        delegate?.preferencesDidUpdate()
    }
    
}
