on do_script (localPathToRawFile, localPathToWorkspace, sermonFileName, sermonTitle, sermonPreacher, sermonBook, sermonCount)
    repeat while logicRunning()
        display dialog "Please close all projects and quit Logic Pro to continue" with icon 2
    end repeat
    tell application "System Events"
        tell application "Logic Pro" to launch
        tell application "Logic Pro" to activate
        try
            click menu item "New..." of menu 1 of menu bar item "File" of menu bar 1 of process "Logic Pro"
        end try
        delay 0.5
        click button named "Cancel" of window named "Save" of process "Logic Pro"
        tell application "Logic Pro" to activate
        delay 0.2
        try
            click button "OK" of the front window of process "Logic Pro"
        end try
        click menu item "Import Audio File..." of menu 1 of menu bar item "File" of menu bar 1 of process "Logic Pro"
        keystroke "G" using {command down}
        set value of text field of sheet of window named "Open File" of process "Logic Pro" to (localPathToRawFile as string)
        click button "Go" of sheet 1 of window named "Open File" of process "Logic Pro"
        click button "Open" of window named "Open File" of process "Logic Pro"
    end tell
    
    tell application "Sermon Upload" to activate
    display dialog "Edit Your Sermon and Come Back When You're Done!" buttons {"Cancel", "Upload"} default button "Upload"
    
    tell application "System Events"
        repeat while (value of checkbox 1 of group 1 of window 1 of process "Logic Pro" as string) is "01"
            set skip to display dialog "Disable master fader dimmer to continue." buttons {"Ok"} default button "Ok" with icon 1
        end repeat
        click menu item "Bounce..." of menu 1 of menu bar item "File" of menu bar 1 of process "Logic Pro"
        tell application "Logic Pro" to activate
        keystroke "G" using {command down}
        set value of text field of sheet of front window of process "Logic Pro" to (localPathToWorkspace as string)
        click button "Go" of sheet 1 of the front window of process "Logic Pro"
        delay 0.1
        set value of text field 1 of the front window of process "Logic Pro" to (sermonFileName as string)
        set rowCount to count rows of table 1 of scroll area 1 of group 1 of window 1 of process "Logic Pro"
        set x to 1
        repeat while x ≤ rowCount
            if value of checkbox 1 of row x of table 1 of scroll area 1 of group 1 of window 1 of process "Logic Pro" is equal to 1 then
                click checkbox 1 of row x of table 1 of scroll area 1 of group 1 of window 1 of process "Logic Pro"
            end if
            set x to (x + 1)
        end repeat
        click checkbox 1 of row 2 of table 1 of scroll area 1 of group 1 of window 1 of process "Logic Pro"
        click pop up button 1 of group 1 of window 1 of process "Logic Pro"
        click menu item "Off" of menu 1 of pop up button 1 of group 1 of window 1 of process "Logic Pro"
        keystroke tab
        keystroke tab
        keystroke tab
        keystroke tab
        keystroke tab
        keystroke tab
        keystroke tab
        keystroke tab
        key code 125
        if value of checkbox "Write ID3 tags" of group 1 of group 1 of window 1 of process "Logic Pro" is 0 then
            click checkbox "Write ID3 tags" of group 1 of group 1 of window 1 of process "Logic Pro"
        end if
        click button 1 of group 1 of group 1 of window 1 of process "Logic Pro"
        set value of text field 2 of row 1 of table 1 of scroll area 1 of front window of process "Logic Pro" to (sermonTitle as string)
        set value of text field 2 of row 2 of table 1 of scroll area 1 of front window of process "Logic Pro" to (sermonPreacher as string)
        set value of text field 2 of row 3 of table 1 of scroll area 1 of front window of process "Logic Pro" to (sermonBook as string)
        set value of text field 2 of row 4 of table 1 of scroll area 1 of front window of process "Logic Pro" to (sermonCount as string)
        set value of text field 2 of row 14 of table 1 of scroll area 1 of front window of process "Logic Pro" to "Bible Teaching"
        click button "OK" of the front window of process "Logic Pro"
        click button "Bounce" of the front window of process "Logic Pro"
    end tell
    
    repeat while logicRunning() is true
        delay 1
        try
            tell application "System Events"
                click menu item "Quit Logic Pro" of menu 1 of menu bar item "Logic Pro" of menu bar 1 of process "Logic Pro"
                click button 2 of the front window of process "Logic Pro"
            end tell
        end try
    end repeat
    
    try
        tell application "Sermon Upload" to activate
    end try
    
    return (sermonFileName & ".mp3")
end do_script

on logicRunning()
    tell application "System Events"
        set x to exists process "Logic Pro"
        return x
    end tell
end logicRunning