//
//  StatusMenuController.swift
//  EGrab
//
//  Created by Ethan McMullan on 06/07/2016.
//  Copyright © 2016 Ethan McMullan. All rights reserved.
//

import Cocoa
import MASShortcut

let DEFAULT_UPLOADURL = ""
let DEFAULT_PRURL = ""
let DEFAULT_AUTHKEY = ""

let MASCustomShortcutKeys = "customShortcut"
let MASCustomShortcutEnabledKeys = "customShortcutEnabled"
let MASHardcodedShortcutEnabledKeys = "hardcodedShortcutEnabled"

class StatusMenuController: NSObject, PreferencesWindowDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    
    var preferencesWindow: PreferencesWindow!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        icon?.template = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.registerDefaults([
            MASHardcodedShortcutEnabledKeys: true,
            MASCustomShortcutEnabledKeys: true
            ])
        
        MASShortcutBinder.sharedBinder().bindShortcutWithDefaultsKey(
            MASCustomShortcutKeys,
            toAction: { () -> Void in
                
                self.takeScreenshot("")
                
            }
        )
        
    }
    
    func preferencesDidUpdate() {
        print("Preferences Updated")
    }
    
    @IBAction func preferencesClicked(sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func quitClicked(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func takeScreenshot(sender: AnyObject) {
        let userName = NSUserName()
        let workingDirectory = "/Users/\(userName)/"
        let fileName = randomAlphaNumericString(8) + ".png"
        let path = workingDirectory + fileName
        _ = bash("screencapture", arguments: ["-s", path])
        uploadToServer(path, name: fileName)
    }
    
    func uploadToServer(path:String, name:String){
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let authK = defaults.stringForKey("authKey") ?? DEFAULT_AUTHKEY
        
        let uploadURL = defaults.stringForKey("uploadURL") ?? DEFAULT_UPLOADURL
        
        let postURL = NSURL(string: uploadURL)
        
        let request = NSMutableURLRequest(URL:postURL!);
        request.HTTPMethod = "POST";
        
        print("Upload File URL:" + uploadURL)
        print("Auth Key:" + authK)
        
        let parameters  = [
            "fileName" : "\(name)",
            "AuthKey" : "\(authK)"
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let idata: NSData? = NSData(contentsOfFile: path)
        
        if(idata?.length > 1){
            
            request.HTTPBody = createBodyWithParameters(parameters, filePathKey: "file", imageDataKey: idata!, boundary: boundary, filename: name)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
           
            //print out response object
            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("****** response data = \(responseString!)")
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary {
                    //print(json)
                    self.handleCompletion(json)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        task.resume()
        }else{
            print("User esc or unexplained error")
        }
    }
    
    func handleCompletion(json : NSDictionary)
    {
        let status = json["Status"]!
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let prURL = defaults.stringForKey("prURL") ?? DEFAULT_PRURL
        
        let imgURL = prURL + (json["File"]! as! String)
        
        let userName = NSUserName()
        let workingDirectory = "/Users/\(userName)/"
        
        let imgPath = workingDirectory + (json["File"]! as! String)
        
        let notification = NSUserNotification.init();
        notification.title = "EGrab"
        
        let nfc = NSUserNotificationCenter.defaultUserNotificationCenter()
        
        if(status as! String == "OK")
        {
            
            print(json["File"]!)
        
            let pb = NSPasteboard.generalPasteboard()
            pb.clearContents()
            pb.setString(imgURL, forType: NSStringPboardType)
            
            let img = NSImage(contentsOfFile: imgPath)
            
            
            notification.contentImage = img
            notification.informativeText = imgURL
            notification.soundName = NSUserNotificationDefaultSoundName
            
            nfc.deliverNotification(notification)
            
            
            removeImageAtPath(imgPath)
            
        }else{
            
            notification.informativeText = "Error - please try again"
            notification.soundName = NSUserNotificationDefaultSoundName
            
            nfc.deliverNotification(notification)
            
            removeImageAtPath(imgPath)
        }
        
    }
    
    func removeImageAtPath(path : String)
    {
        if(NSFileManager.defaultManager().fileExistsAtPath(path))
        {
            do{
                try NSFileManager.defaultManager().removeItemAtPath(path)
                print("File Removed")
            }catch{
                print("Error in removing file")
            }
        }
    }

    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String, filename: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let mimetype = "image/png"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"; authkey=\"\(DEFAULT_AUTHKEY)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    
    
}



extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}


    func shell(launchPath: String, arguments: [String]) -> String
    {
        let task = NSTask()
        task.launchPath = launchPath
        task.arguments = arguments
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: NSUTF8StringEncoding)!
        if output.characters.count > 0 {
            return output.substringToIndex(output.endIndex.advancedBy(-1))
            
        }
        return output
    }
    
    func bash(command: String, arguments: [String]) -> String {
        let whichPathForCommand = shell("/bin/sh", arguments: [ "-l", "-c", "which \(command)" ])
        return shell(whichPathForCommand, arguments: arguments)
    }
    
    func randomAlphaNumericString(length: Int) -> String {
        
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
