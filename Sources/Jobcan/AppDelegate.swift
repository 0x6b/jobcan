import AppKit
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private var hotkeyManager: HotkeyManager?
    private var contextMenu: NSMenu!

    private enum Constants {
        static let popoverSize = CGSize(width: 480, height: 700)
        static let iconSize = CGSize(width: 18, height: 18)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureStatusItem()
        configurePopover()
        configureContextMenu()
        configureMainMenu()

        hotkeyManager = HotkeyManager { [weak self] in
            self?.togglePopover()
        }
    }

    // MARK: - Status Item

    private func configureStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        guard let button = statusItem.button else { return }
        let icon = loadMenubarIcon()
        icon?.isTemplate = true
        button.image = icon
        button.target = self
        button.action = #selector(statusItemClicked(_:))
        button.toolTip = "Jobcan (⌥⌃J)"
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    // MARK: - Popover

    private func configurePopover() {
        popover.contentSize = Constants.popoverSize
        popover.behavior = .transient
        popover.contentViewController = WebViewController()
    }

    // MARK: - Context Menu

    private func configureContextMenu() {
        contextMenu = NSMenu()
        contextMenu.delegate = self

        let launchItem = NSMenuItem(
            title: "ログイン時に起動",
            action: #selector(toggleLaunchAtLogin(_:)),
            keyEquivalent: ""
        )
        launchItem.target = self
        contextMenu.addItem(launchItem)

        let hotkeyItem = NSMenuItem(
            title: "ショートカットを有効にする",
            action: #selector(toggleGlobalShortcut(_:)),
            keyEquivalent: ""
        )
        hotkeyItem.target = self
        contextMenu.addItem(hotkeyItem)

        contextMenu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Jobcan を終了",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: ""
        )
        contextMenu.addItem(quitItem)
    }

    // MARK: - Main Menu

    private func configureMainMenu() {
        let mainMenu = NSMenu()

        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Undo", action: #selector(UndoManager.undo), keyEquivalent: "z")
        editMenu.addItem(withTitle: "Redo", action: #selector(UndoManager.redo), keyEquivalent: "Z")
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        let editMenuItem = NSMenuItem()
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        NSApp.mainMenu = mainMenu
    }

    // MARK: - Icon Loading

    private func loadMenubarIcon() -> NSImage? {
        let image = NSImage(systemSymbolName: "suitcase.fill", accessibilityDescription: "Jobcan")
        image?.size = Constants.iconSize
        return image
    }

    // MARK: - Actions

    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled {
                try service.unregister()
            } else {
                try service.register()
            }
        } catch {
            print("Failed to toggle launch at login: \(error)")
        }
    }

    @objc private func toggleGlobalShortcut(_ sender: NSMenuItem) {
        guard let hotkeyManager else { return }
        hotkeyManager.setEnabled(!hotkeyManager.isEnabled)
    }

    @objc private func statusItemClicked(_ sender: Any?) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            statusItem.menu = contextMenu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            togglePopover()
        }
    }

    private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            guard let button = statusItem.button else { return }
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}

// MARK: - NSMenuDelegate

extension AppDelegate: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        if let launchItem = menu.items.first(where: { $0.action == #selector(toggleLaunchAtLogin(_:)) }) {
            launchItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        }
        if let hotkeyItem = menu.items.first(where: { $0.action == #selector(toggleGlobalShortcut(_:)) }) {
            hotkeyItem.state = hotkeyManager?.isEnabled == true ? .on : .off
        }
    }
}
