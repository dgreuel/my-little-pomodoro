on run argv
	tell application "System Events"
		if exists process "Skype" then
			tell application "Skype"
				send command "SET USERSTATUS DND" script name "My Little Pomodoro"
				-- send command "SET PROFILE MOOD_TEXT %@" script name "My Little Pomodoro"
			end tell
		end if
	end tell
end run