# 🛡️ Deflector

**Deflect the dedicated macOS Search key to a useful frequency.**

Deflector is a lightweight, native utility for Apple Silicon Macs. It uses macOS's built-in `hidutil` to remap the dedicated **Search / Magnifying Glass** key (Usage Page: Consumer, ID: `0x221`) to **F19**.

This allows you to bind the key to launchers like **Raycast**, **Alfred**, or **BetterTouchTool** while keeping your system clean of heavy third-party drivers.

## 🧠 The Technical "Why"
**Why do I need a script? Can't I just unbind Spotlight?**

The dedicated Search key on newer Macs is not a standard keyboard key; it sends a hardware "Consumer Control" signal (`0xC00000221`) that macOS listens for at the kernel level to trigger Spotlight.

Simply disabling the Spotlight shortcut in System Settings often leaves this key dead or inconsistent. **Deflector** is necessary because it uses `hidutil` to intercept this signal at the registry level and "deflect" it to a standard key code (**F19**) *before* the OS processes it. This effectively shields the input from macOS's default behavior, giving you a clean, usable key.

## 📦 Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/deflector.git](https://github.com/YOUR_USERNAME/deflector.git)
    cd deflector
    ```

2.  **Make the script executable:**
    ```bash
    chmod +x deflector.sh
    ```

3.  **Run the Menu:**
    ```bash
    ./deflector.sh
    ```
    Select option `[1]` to engage the persistent mapping.

---

## ⚡ Configuration: Choose Your Priority

Deflector ensures **BOTH** your physical Search key and the classic `Cmd+Space` shortcut launch your app. However, macOS Shortcuts introduces a slight execution delay (~300ms).

You must choose which trigger gets "Native Speed" (Instant) and which gets "Emulated Speed" (Slight Delay).

### Mode A: Hardware Priority (Recommended)
*Choose this if you want the dedicated Search key to be the fastest way to launch.*

| Trigger | Speed | Setup |
| :--- | :--- | :--- |
| **Search Key** | **Instant** ⚡ | Set your App (Raycast/Alfred) Hotkey to **F19**. |
| **Cmd + Space** | **~300ms Delay** | Create a Shortcut bound to `Cmd+Space` that runs `extras/forward_toggle.applescript`. |

### Mode B: Classic Priority
*Choose this if you rely on Cmd+Space muscle memory and want zero latency there.*

| Trigger | Speed | Setup |
| :--- | :--- | :--- |
| **Cmd + Space** | **Instant** ⚡ | Set your App (Raycast/Alfred) Hotkey to **Cmd + Space**. |
| **Search Key** | **~300ms Delay** | Create a Shortcut bound to **F19** that runs `extras/reverse_toggle.applescript`. |

*Note: Regardless of which mode you choose, ensure the native macOS Spotlight shortcut is disabled in System Settings > Keyboard > Keyboard Shortcuts.*

## License
MIT License.

---
**Developed by Dave J.** | [davesorbit.com](https://davesorbit.com)