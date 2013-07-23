tell application "System Events"
	if exists process "Adium" then
		tell application "Adium"
			go available
		end tell
	end if
end tell