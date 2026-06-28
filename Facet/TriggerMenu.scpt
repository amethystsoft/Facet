on run
    tell application "System Events"
        tell process "Xcode"
            -- Force Xcode window focus
            set frontmost to true
            perform action "AXRaise" of window 1
            delay 0.2 -- CRUCIAL: Gives the macOS window server time to focus

            -- Target the exact menu chain
            click menu item "Apply Replace" of menu 1 of menu item "Facet-Xcode" of menu "Editor" of menu bar 1
        end tell
    end tell
end run
