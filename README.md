# Kwid Clock for iOS

A SwiftUI clock app with a WidgetKit Home Screen widget.

## Build
1. Open the Actions tab.
2. Select **Build Kwid Clock IPA** and tap **Run workflow**.
3. Download `KwidClock-unsigned-IPA` from the completed run's Artifacts section.

The workflow creates an **unsigned** IPA. iOS will not install it directly until it is signed with a compatible certificate and provisioning profile or through a trusted sideloading workflow. Keep any signing certificates and private keys out of the repository. Store GitHub Actions signing secrets securely if automated signing is configured later.

WidgetKit controls Home Screen refresh frequency, so the widget is not guaranteed to update every second. The app updates every second while open.
