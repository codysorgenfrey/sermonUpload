on do_script(localPathToRawFile, localPathToWorkspace, sermonFileName, sermonTitle, sermonPreacher, sermonBook, sermonCount)
    repeat while audacityRunning()
        display dialog "Please close all projects and quit Audacity to continue" with icon 2
    end repeat
    tell application "System Events"
        tell application "Audacity" to launch
        tell application "Audacity" to activate
        click menu item "Audio..." of menu 1 of menu item "Import" of menu 1 of menu bar item "File" of menu bar 1 of process "Audacity"
        keystroke "G" using {command down}
        set value of text field 1 of sheet 1 of window 1 of process "Audacity" to (localPathToRawFile as string)
        click button "Go" of sheet 1 of window 1 of process "Audacity"
        click button "Open" of window 1 of process "Audacity"
    end tell
    
    display dialog "Edit Your Sermon and Come Back When You're Done!" buttons {"Cancel", "Upload"} default button "Upload"
    
    tell application "System Events"
        tell application "Audacity" to activate
        click menu item "Export..." of menu 1 of menu bar item "File" of menu bar 1 of process "Audacity"
        delay 0.1
        keystroke "G" using {command down}
        set value of text field 1 of sheet 1 of sheet 1 of front window of process "Audacity" to (localPathToWorkSpace as string)
        click button "Go" of sheet 1 of sheet 1 of the front window of process "Audacity"
        delay 0.1
        set value of text field 1 of sheet 1 of the front window of process "Audacity" to (sermonFileName as string)
        click pop up button 1 of group 1 of group 1 of sheet 1 of window 1 of process "Audacity"
        click menu item "MP3 Files" of menu 1 of pop up button 1 of group 1 of group 1 of sheet 1 of window 1 of process "Audacity"
        click button "Save" of sheet 1 of window 1 of process "Audacity"
        keystroke (ASCII character 29)
		keystroke (sermonPreacher as string)
		keystroke return
		keystroke (ASCII character 8)
		delay 0.5
		keystroke "a" using command down
		keystroke (sermonTitle as string)
		keystroke return
		keystroke (ASCII character 8)
		delay 0.5
		keystroke "a" using command down
		keystroke (sermonBook as string)
		keystroke return
		keystroke (ASCII character 8)
		delay 0.5
		keystroke "a" using command down
		keystroke (sermonCount as string)
		keystroke return
		keystroke (ASCII character 8)
		delay 0.5
		keystroke "a" using command down
		keystroke ((year of (current date)) as string)
		keystroke return
		keystroke (ASCII character 31)
		keystroke (ASCII character 31)
		keystroke (ASCII character 8)
		delay 0.5
		keystroke "a" using command down
		keystroke "Sermon Upload/Audacity"
		keystroke return
		keystroke (ASCII character 30)
		keystroke (ASCII character 30)
		keystroke (ASCII character 30)
		keystroke (ASCII character 8)
		delay 0.5
		keystroke "a" using command down
		keystroke "Bible Teaching"
		keystroke return
        click button "OK" of window 1 of process "Audacity"
    end tell
    
    repeat while audacityRunning() is true
        delay 1
        try
            tell application "System Events"
                click menu item "Quit Audacity" of menu 1 of menu bar item "Audacity" of menu bar 1 of process "Audacity"
                click button "No" of the front window of process "Audacity"
            end tell
        end try
    end repeat
    
    try
        tell application "Sermon Upload" to activate
    end try
    
    return "mp3"
end do_script

on audacityRunning()
    tell application "System Events"
        set x to exists process "Audacity"
        return x
    end tell
end audacityRunning