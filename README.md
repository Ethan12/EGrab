# EGrab
Simple Screenshot app for Mac, written in Swift with a little help of a CocoaPod called MASShortcut


#Installation
1. Put upload.php onto your webserver
2. Insert personal AuthKey into array in upload.php file 
```php
$authKeys = array("Name" => "Key", "Name2" => "Key2");
```
3. Run XCode workspace file not XCode project file!
4. Change bundle identifier, version ID if you like but not necessary, Run Project
5. Open Preferences and change Upload URL to link of the upload.php file
6. Change the post url to where the program will append the file name to the link of your directory of images
7. Set your Auth Key and create a keyboard shorcut.
8. You should now be successfully up and running -> If you would like to run on your Mac Independently just Archive and export the application.

©Ethan McMullan 2016. All rights reserved.