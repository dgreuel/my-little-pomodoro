tell application "System Events"
	if exists process "iChat" then
		tell application "iChat"
			set status to available
			delay 0.1
			set status message to ""
		end tell
	end if
end tell