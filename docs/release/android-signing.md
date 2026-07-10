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

The `android` job in `.github/workflows/release.yml` writes
`android/key.properties` and the keystore file from GitHub Actions secrets
before running `flutter build appbundle --release`, mirroring the pattern
already used for `--dart-define` OAuth credentials in `main.dart`. Configure
these repository secrets to produce a signed AAB:

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Base64 of the `.jks` (`base64 -i openbike-release.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | The keystore's `storePassword` |
| `ANDROID_KEY_PASSWORD` | The key's `keyPassword` |
| `ANDROID_KEY_ALIAS` | The `-alias` used when generating the keystore (`openbike` above) |

When `ANDROID_KEYSTORE_BASE64` is unset, the job still succeeds and produces
a debug-signed AAB — never commit the keystore or `key.properties` to the
repository.
