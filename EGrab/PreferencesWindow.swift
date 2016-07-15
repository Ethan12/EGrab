//
//  PreferencesWindow.swift
//  EGrab
//
//  Created by Ethan McMullan on 06/07/2016.
//  Copyright © 2016 Ethan McMullan. All rights reserved.
//

import Cocoa
import MASShortcut


let MASCustomShortcutKey = "customShortcut"
let MASCustomShortcutEnabledKey = "customShortcutEnabled"
let MASHardcodedShortcutEnabledKey = "hardcodedShortcutEnabled"

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

var MASObservingContext = UnsafeMutablePointer<Void>.alloc(1)

class PreferencesWindow: NSWindowController, NSWindowDelegate {
    
    var delegate: PreferencesWindowDelegate?
    
    @IBOutlet var shortcutView: MASShortcutView!
    @IBOutlet weak var authKeyField: NSTextField!
    @IBOutlet weak var uploadTextField: NSTextField!
    @IBOutlet var postTextField: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        self.window?.delegate = self
        NSApp.activateIgnoringOtherApps(true)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let uploadURL = defaults.stringForKey("uploadURL") ?? DEFAULT_UPLOADURL
        uploadTextField.stringValue = uploadURL
        
        let authK = defaults.stringForKey("authKey") ?? DEFAULT_AUTHKEY
        authKeyField.stringValue = authK
        
        let prURL = defaults.stringForKey("prURL") ?? DEFAULT_PRURL
        postTextField.stringValue = prURL
        
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
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    
    func windowWillClose(notification: NSNotification) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(authKeyField.stringValue, forKey: "authKey")
        defaults.setValue(uploadTextField.stringValue, forKey: "uploadURL")
        defaults.setValue(postTextField.stringValue, forKey: "prURL")
        delegate?.preferencesDidUpdate()
    }
}
