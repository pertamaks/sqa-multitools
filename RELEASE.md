# Release Process: SQA-Multitools

This document outlines the procedure for building, verifying, and publishing new versions of SQA-Multitools.

---

## 1. Release Workflow

We use **GitHub Actions** to automate the build and distribution of Windows release bundles. The workflow is triggered by version tags.

### Triggering a Release
To start a new release, push a tag following the `vX.Y.Z` format:

```bash
# Example: Creating version 0.1.0
git tag -a v0.1.0 -m "Release v0.1.0"
git push origin v0.1.0
```

### The Manual Approval Gate
To prevent accidental or unverified builds from reaching production, the `build_release.yml` workflow is protected by a **Manual Approval Gate**:

1. After the tag is pushed, the **"Build and Release"** action starts.
2. It will complete the compilation and artifact zipping.
3. The workflow will then pause and enter a **"Waiting"** state for the `production` environment.
4. A repository maintainer must go to the **Actions** tab, click on the running workflow, and click **"Review pending deployments"** to approve the release.

---

## 2. Release Artifacts

Once approved, the following artifacts are automatically generated and attached to a new GitHub Release:

- **`sqa-multitools-vX.Y-windows.zip`**: The complete production bundle (Portable).
- **`version.json`**: Updated metadata for the in-app update checker.

---

## 3. Pre-Release Checklist

Before pushing a release tag, ensure the following steps are completed:

- [ ] **Changelog**: Update `CHANGELOG.md` with all changes since the last release.
- [ ] **Version Bump**: Update the version number in `pubspec.yaml`.
- [ ] **Documentation**: Ensure all new features have a corresponding SRS document in `docs/srs/`.
- [ ] **Analysis**: Run `dart analyze` and ensure zero warnings.
- [ ] **Tests**: Run `flutter test` and ensure all tests pass.
- [ ] **Single Instance**: Verify that the `main.cpp` Mutex logic is correctly configured for the current app title.

---

## 4. Branching Strategy

- **`main`**: The primary stable branch. Tags should typically be pushed from here.
- **`release/vX.Y`**: Used for staging release candidates. Bug fixes discovered during RC testing are committed here and merged back to `main` after the release.

---

## 5. Versioning Policy

We follow [Semantic Versioning (SemVer)](https://semver.org/):

- **Major**: Breaking changes or complete architectural overhauls.
- **Minor**: New plugins or significant feature additions.
- **Patch**: Bug fixes and minor UI polish.
