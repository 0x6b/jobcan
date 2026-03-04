# Jobcan

A macOS menu bar app for quick access to the [Jobcan](https://jobcan.ne.jp/) attendance management page that I'm not good at.

> [!NOTE]
> This project is not affiliated with the [Jobcan](https://jobcan.ne.jp/) nor [Donuts Co. Ltd](https://www.donuts.ne.jp/).

## Features

- Lives in the menu bar (hidden from the Dock)
- Optional global hotkey `⌥⌃J` (Option+Ctrl+J) to toggle from anywhere (disabled by default, enable via context menu)
- Click the menu bar icon to show a popover

## Requirements

- macOS 26.3 (Tahoe) or later. Maybe work with older version but not tested.
- Apple Silicon
- Xcode 26.3+ or the corresponding Command Line Tools

## Build

```sh
make run        # Build → bundle → sign → launch
make install    # Build → bundle → sign → install to /Applications/
make uninstall  # Remove from /Applications/
make clean      # Remove build artifacts
```

## Project Structure

```
Sources/Jobcan/
  main.swift              # App entry point
  AppDelegate.swift       # NSStatusItem, NSPopover, menu management
  WebViewController.swift # Web page display via WKWebView
  HotkeyManager.swift     # Global hotkey registration via Carbon API
Resources/
  Info.plist              # LSUIElement=true (hidden from Dock)
  AppIcon.icns            # App icon
  menubar_icon.png        # Menu bar icon
  menubar_icon@2x.png     # Menu bar icon (Retina)
```

## Usage

| Action                | Behavior                                                     |
| --------------------- | ------------------------------------------------------------ |
| Click menu bar icon   | Toggle popover                                               |
| `⌥⌃J`                 | Toggle popover from any app                                  |
| Right-click           | Context menu (enable global shortcut, launch at login, quit) |
| Click outside popover | Dismiss popover                                              |

## License

MIT. See [LICENSE](LICENSE) for more details.
