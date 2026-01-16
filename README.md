# Deflector 🛡️

**Deflector** is a lightweight, sandbox-free macOS menu bar utility that reclaims the `Cmd+Space` and `F4 (Spotlight)` keys, allowing you to seamlessly trigger third-party launchers like **Raycast** or Alfred instead of Apple's Spotlight.

## 🛑 The Problem: Why is this needed?
Modern MacBooks come with a dedicated **Spotlight Key (F4)**. Unlike standard function keys, macOS "hard-codes" this key at the driver level.
* **You cannot natively rebind it:** System Settings does not allow you to change the F4 key to launch other apps.
* **Hardware Lock:** The key sends a special HID usage ID (`0x221`) that macOS consumes before most standard apps can even see it.
* **The "Ghosting" Glitch:** Even if you disable the native `Cmd+Space` shortcut, third-party launchers often fail to "toggle" closed because they detect you are still holding the Command key down.

## 🚀 The Solution: Deflector 2.0
Deflector acts as a "man-in-the-middle" between your keyboard and macOS. Version 2.0 introduces a **Hybrid Engine** to bypass these restrictions without crashing:

1.  **Hardware Intercept (F4):** Uses a low-level driver remapping (`hidutil`) to physically convert the restricted F4 signal into a standard `F19` key that Raycast can understand.
2.  **Software Intercept (Cmd+Space):** Uses Carbon APIs to catch `Cmd+Space` before the system does.
3.  **Micro-Sequencing:** Solves the "Ghosting" glitch by virtually lifting the Command key 20ms before firing the trigger. This ensures your launcher opens and closes reliably every time.

## ✨ Features
* **Zero Latency:** Native OS integration means Raycast opens instantly.
* **No Background Daemons:** Runs silently in the menu bar with negligible CPU/RAM footprint.
* **Shortcuts Support:** Includes a custom URL scheme (`deflector://toggle`) to enable/disable the shield via Apple Shortcuts.
* **Sandbox Free:** Entirely self-contained architecture eliminates the `(os/kern) failure (0x5)` crashes found in previous versions.

## 🛠️ Installation & Setup

1. **Download:** Get the latest release from the [Releases Page](../../releases).
2. **Run:** Drag `Deflector.app` to your Applications folder and open it.
3. **Grant Permissions:** The app requires Accessibility permissions to intercept keystrokes. A window will automatically open to guide you.
4. **Disable Native Spotlight:**
   * Go to `System Settings` > `Keyboard` > `Keyboard Shortcuts` > `Spotlight`.
   * **Uncheck** "Show Spotlight search".
5. **Configure Raycast (or Alfred):**
   * Open Raycast Settings (`Cmd + ,`).
   * Click the "Raycast Hotkey" recorder.
   * Press `Cmd+Space` (Deflector will intercept this and output `F19`).

---

## 🏗️ Building from Source (For Non-Developers)
If you prefer to build the app yourself rather than downloading it, follow these steps. You do **not** need to know how to code.

### Prerequisites
* A Mac running macOS Sonoma or later.
* **Xcode** (Download for free from the Mac App Store).

### Step 1: Open the Project
1. Download this repository (Click **Code** > **Download ZIP**) and unzip it.
2. Double-click `Deflector.xcodeproj` to open it in Xcode.

### Step 2: Sign the App
To run an app on your Mac, it must be "signed" with your Apple ID.
1. In Xcode, click the blue **Deflector** icon on the top-left sidebar.
2. Click **Deflector** under the "Targets" list in the center.
3. Click the **Signing & Capabilities** tab at the top.
4. Under the **Team** dropdown, select **"Add an Account..."**.
5. Enter your Apple ID credentials (this is free; you don't need a paid developer account).
6. Once added, select your **Personal Team** from the dropdown.

### Step 3: Build & Export
1. Ensure the destination (top center of the window) is set to **"My Mac"**.
2. Go to the menu bar: **Product** > **Archive**.
3. Wait for the build to finish. A window called "Organizer" will pop up.
4. Click the blue **Distribute App** button on the right.
5. Select **Custom** (or Copy App) > **Next**.
6. Select **Copy App** > **Next**.
7. Choose where to save it (e.g., Desktop) and click **Export**.

You now have a fully functional `Deflector.app` built from source!

---

## 🧠 Technical Details
When Deflector is active, pressing `Cmd+Space` triggers a micro-sequence:
1. Virtually releases the `Command` key.
2. Waits 20ms (Debounce).
3. Presses `F19`.
4. Waits 20ms.
5. Releases `F19`.

Simultaneously, the physical `F4` key is remapped at the HID driver level to `F19`.

## 🛑 Uninstallation
To completely remove the app and restore your keys to Apple's defaults:
1. Click the Deflector menu bar icon and **Uncheck** "Enable Deflector" (this restores the F4 key).
2. Quit the app.
3. Delete `Deflector.app`.
