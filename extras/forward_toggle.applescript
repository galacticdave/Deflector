-- FORWARD TOGGLE (Cmd+Space -> F19)
-- Use this if your Launcher is bound to F19 (Hardware Priority).
-- This script simulates pressing "F19" so the Cmd+Space shortcut behaves like the hardware key.

tell application "System Events"
	key code 80 -- F19
end tell