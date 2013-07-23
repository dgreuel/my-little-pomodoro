on run argv
	tell application "System Events"
		if exists process "Adium" then
			tell application "Adium"
				go away with message item 1 of argv
			end tell
		end if
	end tell
end run