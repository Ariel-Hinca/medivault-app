# MediVault

Local medicine cabinet for Android and iOS.

The cabinet is an encrypted SQLite file on the device. The database key is kept in the Android Keystore or the iOS Keychain. There is no account and no server.

Scanning reads a pack with the camera. Google ML Kit runs on the phone. The photo is deleted after reading, and the cabinet does not store the photo or the raw text. You confirm the details before a medicine is saved. The cabinet asks for your fingerprint, face, or PIN before it opens.
