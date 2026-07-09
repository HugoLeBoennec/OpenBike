# Android release signing

Release builds are signed with a keystore referenced from `android/key.properties`.
That file is gitignored and must never be committed. When it is absent, release
builds fall back to debug signing so `flutter build apk --release` and CI keep
working without secrets.

## Generate a keystore

```bash
keytool -genkey -v -keystore ~/openbike-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias openbike
```

Store the resulting `.jks` file somewhere outside the repo (e.g. a password
manager or CI secret store) — never commit it.

## Configure `android/key.properties`

Create `android/key.properties` (gitignored, sits next to `android/build.gradle.kts`):

```properties
storePassword=<keystore password>
keyPassword=<key password>
keyAlias=openbike
storeFile=/absolute/path/to/openbike-release.jks
```

`storeFile` may also be a path relative to `android/app/`.

## CI / release builds

For CI-driven release builds, write `android/key.properties` and the keystore
file from CI secrets before running `flutter build appbundle --release` (or
`apk --release`), mirroring the pattern already used for `--dart-define` OAuth
credentials in `main.dart`. Never commit the keystore or `key.properties` to
the repository.
