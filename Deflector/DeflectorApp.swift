//
//  DeflectorApp.swift
//  Deflector
//
//  Created by David J. on 1/16/26.
//


import SwiftUI
import ServiceManagement
import Carbon

// MARK: - Deflector 2.0 (Gold Master)
@main
struct DeflectorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings { PermissionView() }
        .commands { CommandGroup(replacing: .newItem) { } }
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var statusItem: NSStatusItem!
    var isRemappingEnabled: Bool = true
    
    // Engine A: Cmd+Space Interceptor (Software)
    let hotkeyService = CarbonHotkeyService()
    // Engine B: F4/Spotlight Key Remapper (Hardware)
    let remapService = RemapService()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Load User Preferences
        isRemappingEnabled = UserDefaults.standard.object(forKey: "RemapEnabled") as? Bool ?? true
        
        setupMenuBar()
        
        // 2. Setup URL Handler (deflector://toggle)
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleGetURLEvent), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
        // 3. Start Engines
        DispatchQueue.main.async {
            if !PermissionsManager.isTrusted() {
                PermissionsManager.showWindow()
            } else {
                if self.isRemappingEnabled { self.engageShields() }
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        remapService.disengage()
    }
    
    // MARK: - Logic Control
    func engageShields() {
        hotkeyService.registerHotkey()
        remapService.engage()
    }
    
    func disengageShields() {
        hotkeyService.unregisterHotkey()
        remapService.disengage()
    }
    
    @objc func toggleRemapping() {
        isRemappingEnabled.toggle()
        UserDefaults.standard.set(isRemappingEnabled, forKey: "RemapEnabled")
        
        if isRemappingEnabled { engageShields() } else { disengageShields() }
        
        updateStatusIcon()
        statusItem.menu?.update() 
    }
    
    @objc func handleGetURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        guard let url = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
              let host = URL(string: url)?.host else { return }
        
        if host == "toggle" { toggleRemapping() }
    }

    // MARK: - UI Setup
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusIcon()
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        
        // Status Header
        let statusTitle = isRemappingEnabled ? "Shield: Active" : "Shield: Paused"
        let header = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        header.attributedTitle = NSAttributedString(string: statusTitle, attributes: [.font: NSFont.boldSystemFont(ofSize: 13)])
        menu.addItem(header)
        
        menu.addItem(NSMenuItem.separator())
        
        // Controls
        let toggleItem = NSMenuItem(title: "Enable Deflector", action: #selector(toggleRemapping), keyEquivalent: "e")
        toggleItem.state = isRemappingEnabled ? .on : .off
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Permissions...", action: #selector(openPermissions), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
    }
    
    func updateStatusIcon() {
        if let button = statusItem.button {
            let symbol = isRemappingEnabled ? "shield.fill" : "shield.slash"
            button.image = NSImage(systemSymbolName: symbol, accessibilityDescription: "Deflector")
        }
    }
    
    @objc func openPermissions() { PermissionsManager.showWindow() }
    @objc func quitApp() { NSApplication.shared.terminate(nil) }
}

// MARK: - Engine A: Carbon Hotkey (Optimized for Toggle)
class CarbonHotkeyService {
    var hotKeyRef: EventHotKeyRef?
    var eventHandler: EventHandlerRef?
    
    func registerHotkey() {
        if hotKeyRef != nil { return }
        let hotKeyID = EventHotKeyID(signature: 1234, id: 1)
        RegisterEventHotKey(UInt32(kVK_Space), UInt32(cmdKey), hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { (handler, event, userData) -> OSStatus in
            let service = Unmanaged<CarbonHotkeyService>.fromOpaque(userData!).takeUnretainedValue()
            service.trigger()
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)
        print("Deflector: Cmd+Space Listener Active")
    }
    
    func unregisterHotkey() {
        if let ref = hotKeyRef { UnregisterEventHotKey(ref); hotKeyRef = nil }
        if let handler = eventHandler { RemoveEventHandler(handler); eventHandler = nil }
        print("Deflector: Cmd+Space Listener PAUSED")
    }
    
    func trigger() {
        simulateF19Sequence()
    }
    
    // The "Magic" Timing Sequence
    func simulateF19Sequence() {
        let src = CGEventSource(stateID: .hidSystemState)
        let f19Code: CGKeyCode = 80
        let cmdCode: CGKeyCode = 55
        
        // 1. Release Command
        let cmdUp = CGEvent(keyboardEventSource: src, virtualKey: cmdCode, keyDown: false)
        cmdUp?.post(tap: .cghidEventTap)
        
        // 2. WAIT 20ms (Crucial for Toggle logic)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            
            // 3. Press F19
            let down = CGEvent(keyboardEventSource: src, virtualKey: f19Code, keyDown: true)
            down?.post(tap: .cghidEventTap)
            
            // 4. WAIT 20ms (Clean press duration)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                
                // 5. Release F19
                let up = CGEvent(keyboardEventSource: src, virtualKey: f19Code, keyDown: false)
                up?.post(tap: .cghidEventTap)
            }
        }
    }
}

// MARK: - Engine B: Remap Service (Hardware Fix)
class RemapService {
    let mapArgs = ["property", "--set", "{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\":0xC00000221,\"HIDKeyboardModifierMappingDst\":0x70000006E}]}"]
    let clearArgs = ["property", "--set", "{\"UserKeyMapping\":[]}"]
    
    func engage() { run(mapArgs) }
    func disengage() { run(clearArgs) }
    
    private func run(_ args: [String]) {
        let task = Process()
        task.launchPath = "/usr/bin/hidutil"
        task.arguments = args
        // Pipe output to avoid stalls, but we don't need to print it
        task.standardOutput = Pipe()
        task.standardError = Pipe()
        do { try task.run() } catch { print("HIDUTIL ERROR: \(error)") }
    }
}

// MARK: - Permissions
struct PermissionsManager {
    static func isTrusted() -> Bool { AXIsProcessTrusted() }
    static func showWindow() {
        let window = NSWindow(contentRect: NSRect(x:0,y:0,width:400,height:320), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.center(); window.contentView = NSHostingView(rootView: PermissionView()); window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct PermissionView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.righthalf.filled").font(.system(size: 64)).foregroundColor(.blue)
            Text("Permissions Needed").font(.title)
            Button("Open Settings") {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
        }.frame(width: 400, height: 320)
    }
}
