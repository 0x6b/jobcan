import Carbon

final class HotkeyManager {
    private var hotkeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?
    private let callback: () -> Void
    private(set) var isEnabled: Bool = false

    init(callback: @escaping () -> Void) {
        self.callback = callback
    }

    deinit {
        unregisterHotkey()
    }

    func setEnabled(_ enabled: Bool) {
        if enabled {
            registerHotkey()
        } else {
            unregisterHotkey()
        }
    }

    private func unregisterHotkey() {
        if let hotkeyRef {
            UnregisterEventHotKey(hotkeyRef)
            self.hotkeyRef = nil
        }
        if let handlerRef {
            RemoveEventHandler(handlerRef)
            self.handlerRef = nil
        }
        isEnabled = false
    }

    // MARK: - Registration

    private func registerHotkey() {
        guard !isEnabled else { return }

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        let installStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            hotkeyEventHandler,
            1,
            &eventType,
            selfPtr,
            &handlerRef
        )
        guard installStatus == noErr else {
            print("Failed to install event handler: \(installStatus)")
            return
        }

        let hotkeyID = EventHotKeyID(
            signature: OSType(0x4A4F4243), // "JOBC"
            id: 1
        )

        let registerStatus = RegisterEventHotKey(
            UInt32(kVK_ANSI_J),
            UInt32(optionKey | controlKey),
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotkeyRef
        )
        guard registerStatus == noErr else {
            print("Failed to register hotkey: \(registerStatus)")
            return
        }

        isEnabled = true
    }

    fileprivate func invokeCallback() {
        DispatchQueue.main.async { [weak self] in
            self?.callback()
        }
    }
}

// MARK: - Carbon Event Handler

private func hotkeyEventHandler(
    nextHandler: EventHandlerCallRef?,
    event: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let userData else { return OSStatus(eventNotHandledErr) }
    let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
    manager.invokeCallback()
    return noErr
}
