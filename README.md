# Kwid Clock for iOS

A standalone SwiftUI clock app. This version contains no Home Screen widget or widget extension.

## Build
1. Open the Actions tab.
2. Select **Build Kwid Clock IPA** and tap **Run workflow**, or push a change to `main`.
3. Download `KwidClock-unsigned-IPA` from the completed run's Artifacts section.

The workflow produces an **unsigned** IPA for testing/build packaging. iOS will not install it directly until it is signed with a compatible certificate and provisioning profile, or installed through a supported development sideloading workflow. Keep signing certificates and private keys out of the repository.
