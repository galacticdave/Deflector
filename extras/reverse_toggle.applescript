-- REVERSE TOGGLE (F19 -> Cmd+Space)
-- Use this if your Launcher is bound to Cmd+Space (Classic Priority).
-- This script simulates pressing "Cmd+Space" so the hardware key behaves like the classic shortcut.

tell application "System Events"
	keystroke space using {command down}
end tell