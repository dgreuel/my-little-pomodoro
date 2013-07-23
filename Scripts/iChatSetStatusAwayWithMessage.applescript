on run argv
	tell application "System Events"
		if exists process "iChat" then
			tell application "iChat"
				set status to away
				delay 0.1
				set status message to item 1 of argv
			end tell
		end if
	end tell
end run