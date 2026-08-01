# Android release signing

## Two different keys — don't confuse them

With Play App Signing enabled, there are two keys and you only ever hold one:

| Key | Who holds it | What it does |
|---|---|---|
| **App signing key** | **Google** | Signs the APKs actually delivered to users |
| **Upload key** | **You** | Signs what you upload to Play Console; Play verifies it, strips it, and re-signs with the app signing key |

The `certificates.zip` Play Console offers for download (`deployment_cert.der`
and the `hybrid_*_cert.der` post-quantum variants) contains **public
certificates only, no private key**. You cannot sign anything with it. It is
for registering SHA-256 fingerprints with third-party APIs and for verifying
what Google delivered. Generating the upload key below is a separate, local
step.

**Losing the upload key is recoverable** — Google can reset it on request.
Losing the app signing key would not be, which is exactly why Play App Signing
exists.

## Generate the upload keystore

```bash
keytool -genkeypair -v -keystore ~/openbike-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias openbike-upload
```

`keytool` prompts for the password interactively — prefer that over passing
`-storepass` on the command line, which lands the password in shell history.

Keep the `.jks` outside the repo and back it up (password manager). Then
export its public certificate, which Play Console asks for if it wants the
upload key registered explicitly:

```bash
keytool -export-rfc -keystore ~/openbike-upload.jks \
  -alias openbike-upload -file ~/openbike-upload-cert.pem
```

## Configure `android/key.properties`

Create `android/key.properties` (gitignored, sits next to `android/build.gradle.kts`):

```properties
storePassword=<keystore password>
keyPassword=<key password>
keyAlias=openbike-upload
storeFile=/Users/<you>/openbike-upload.jks
```

`storeFile` may also be a path relative to `android/app/`.

## Verifying a build is actually signed

The debug-signing fallback means `flutter build appbundle --release` **succeeds
even with no keystore configured**, producing a bundle Play rejects with "You
uploaded an APK or Android App Bundle that was signed in debug mode". A green
build is not evidence of a submittable artifact. Check before uploading:

```bash
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```

The owner must be your upload key's distinguished name. If it says
`CN=Android Debug, O=Android, C=US`, `key.properties` was not picked up.

## CI / release builds

The `android` job in `.github/workflows/release.yml` writes
`android/key.properties` and the keystore file from GitHub Actions secrets
before running `flutter build appbundle --release`, mirroring the pattern
already used for `--dart-define` OAuth credentials in `main.dart`. Configure
these repository secrets to produce a signed AAB:

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Base64 of the `.jks` (`base64 -i ~/openbike-upload.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | The keystore's `storePassword` |
| `ANDROID_KEY_PASSWORD` | The key's `keyPassword` |
| `ANDROID_KEY_ALIAS` | The `-alias` used when generating the keystore (`openbike-upload` above) |

When `ANDROID_KEYSTORE_BASE64` is unset, the job still succeeds and produces
a debug-signed AAB — never commit the keystore or `key.properties` to the
repository.
