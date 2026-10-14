# Releasing

Releases are driven by git tags.

1. Bump `version:` in `pubspec.yaml` (e.g. `3.0.1+38`) in a PR and merge it.
   iOS, macOS, Android and Windows all read their version from there.
2. Tag the merge commit on `main` and push the tag:

       git checkout main && git pull
       git tag v3.0.1
       git push origin v3.0.1

3. `.github/workflows/release.yml` then:
   - checks the tag matches `pubspec.yaml` and runs analyze + tests,
   - builds Windows (`Homiletics-Setup.exe` installer, `Homiletics-Windows.zip`),
   - builds a signed Android `Homiletics.apk` and the Play `.aab`
     (needs the `ANDROID_*` secrets listed at the top of the workflow),
   - publishes a GitHub Release with notes generated from merged PRs.
   Tags with a hyphen (`v3.1.0-beta.1`) publish a pre-release.

4. Store uploads stay manual for now:
   - **Google Play:** download the `Homiletics-Android-AAB` artifact from the
     workflow run and upload it in Play Console.
   - **App Store (iOS + Mac):** `flutter build ipa` on a Mac, upload with
     Xcode / Transporter.

The website's download buttons link to
`https://github.com/ntatko/homiletics-mobile/releases/latest/download/<file>`,
so they always point at the newest release.

Windows builds are unsigned until an Authenticode certificate is added (see
the commented signing steps in the workflow); until then Windows SmartScreen
shows a "Windows protected your PC" prompt on first run.
