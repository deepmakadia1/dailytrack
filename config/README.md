# Build configuration

Nothing secret is committed here (constitution III). The files below are
git-ignored; only the `*.example.json` templates are tracked.

## `dart_defines.json`: Firebase and Google sign-in

Firebase client values and the Google web client ID, passed to every build
with `--dart-define-from-file=config/dart_defines.json`. Copy
`dart_defines.example.json` and fill it in.

## `prod.env.json`: production AdMob IDs

Copy `prod.env.example.json` to `prod.env.json` and fill in the real AdMob App
ID and the four ad unit IDs. It is read by:

- **Flutter**: pass it after the defines file, so the ad unit IDs reach Dart:
  `--dart-define-from-file=config/dart_defines.json --dart-define-from-file=config/prod.env.json`.
- **Gradle**: `ADMOB_APP_ID` goes into the manifest of the prod release. The
  App ID is taken from, in order: `config/prod.env.json`, `admob.appId` in
  `android/local.properties`, then the `ADMOB_APP_ID` environment variable.

Dev-flavor and debug builds always use Google's test IDs, whatever is set
here. A prod release without an App ID uses the test App ID and requests no
ads; a store build (`-PstoreBuild=true`, `DAILYTRACK_STORE_BUILD=true`, or
`android/key.properties` present) fails instead.

## `android/key.properties`: release signing

Create an upload key once and keep it safe outside the repo (losing it means
asking Google Play to reset the upload key):

```text
keytool -genkeypair -v -keystore android/upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

Then create `android/key.properties`:

```properties
storeFile=upload-keystore.jks
storePassword=…
keyAlias=upload
keyPassword=…
```

`storeFile` is relative to `android/`, or an absolute path. With this file
present, release builds are signed with the upload key and count as store
builds.

## GitHub secrets (release workflow)

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 android/upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | `storePassword` |
| `ANDROID_KEY_ALIAS` | `keyAlias` |
| `ANDROID_KEY_PASSWORD` | `keyPassword` |
| `PROD_ENV_JSON` | the whole `prod.env.json` |
