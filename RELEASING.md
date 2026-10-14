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

## How Windows users get updates

Windows has no store, so the app checks for itself
(`lib/services/update_service.dart`). At launch (at most once a day) and from
**Settings → Check for updates**, it reads
`https://api.github.com/repos/ntatko/homiletics-mobile/releases/latest`
(which skips drafts and pre-releases) and offers any newer `vX.Y.Z`.

- **Installed copies** (the installer writes `install.ini` next to
  `Homiletics.exe`): **Update now** downloads that release's
  `Homiletics-Setup.exe`, checks its size against the release asset, runs it
  with `/SILENT /SUPPRESSMSGBOXES /CLOSEAPPLICATIONS /NORESTART /RELAUNCH=1`
  and quits. The installer keeps the existing per-user / all-users mode and
  reopens the app.
- **Portable zip copies:** **Download** opens homiletics.app/download.

So a release reaches Windows users as soon as it's published: keep the asset
named `Homiletics-Setup.exe`, never change the installer's `AppId`, and use a
hyphenated tag for anything that shouldn't be offered yet. Unsigned builds
can still show SmartScreen when the installer runs.
