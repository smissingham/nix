# Filen Desktop Nix Package Development Notes

## Problem Statement

The Filen Desktop Nix package had several issues on macOS:
1. The app showed as "Electron" in macOS UI (Activity Monitor, login items, etc.) instead of "Filen Desktop"
2. When "Open at Login" was enabled in Filen settings, it registered as generic "Electron" app
3. App data was stored in `~/Library/Application Support/Electron` instead of `~/Library/Application Support/@filen/desktop`

## Root Cause Analysis

### Initial Approach (Broken)
The package initially used:
- `buildNpmPackage` with custom build script
- `desktopToDarwinBundle` to create macOS .app
- `makeWrapper` to wrap electron binary
- Manual `postFixup` steps to modify Info.plist

**Why it failed:**
1. `desktopToDarwinBundle` creates a generic .app with `CFBundleIdentifier = org.nixos.Filen Desktop`
2. The .app executable was a wrapper script that `exec`'d the raw electron binary
3. macOS saw the final electron binary process, not the .app bundle
4. Even with correct Info.plist values, the running process was identified as "Electron"
5. Login items registered the electron binary path, not the .app bundle

### Key Discoveries

1. **App Identity Flow:**
   - When wrapper → electron binary, macOS sees electron as the running app
   - Bundle identifier in Info.plist doesn't matter if the actual binary is electron
   - Login items use `app.getPath("exe")` which returns electron binary path

2. **Attempted Fixes (All Failed):**
   - Setting `ELECTRON_APP_NAME` environment variable
   - Patching `app.setName()` and `app.setPath()` in source
   - Setting `FILEN_APP_PATH` and patching login item code
   - Modifying Info.plist with PlistBuddy
   - Replacing .app executable with wrapper

3. **The Real Solution:**
   - Use `electron-builder` to create proper .app bundle (like gitify package in nixpkgs)
   - Don't use `desktopToDarwinBundle` for electron apps
   - Let electron-builder handle all macOS app packaging

## Solution: Using electron-builder

### How Other Packages Do It

Researched nixpkgs packages:
- **obsidian**: Downloads pre-built .app (not source build)
- **vscode**: Downloads pre-built .app (not source build)  
- **gitify**: Builds from source using `electron-builder` ✓ (our model)

### Gitify Pattern (What We're Following)

```nix
buildPhase = ''
  cp -r ${electron.dist} electron-dist
  chmod -R u+w electron-dist
  
  pnpm exec electron-builder \
    --config config/electron-builder.js \
    --dir \
    -c.electronDist=electron-dist \
    -c.electronVersion="${electron.version}"
'';

installPhase = ''
  mkdir -p $out/Applications
  cp -r dist/mac*/Gitify.app $out/Applications
  makeWrapper $out/Applications/Gitify.app/Contents/MacOS/gitify $out/bin/gitify
'';
```

### What electron-builder Does Correctly

1. Creates proper .app bundle structure
2. Sets correct `CFBundleIdentifier` from package.json build config
3. Embeds app resources and icons
4. Creates proper executable that electron recognizes
5. Handles code signing requirements (we disable for Nix)

## Implementation Details

### File: `package.nix`

**Key Changes:**
1. Removed `desktopToDarwinBundle` dependency
2. Added `buildPhase` override to run `electron-builder`
3. macOS: Copy built .app from `prod/mac*/` to `$out/Applications/`
4. Linux: Extract unpacked resources as before
5. Removed all manual Info.plist patching (electron-builder handles it)

### Source Patches Required

```nix
postPatch = ''
  # Use nixpkgs electron
  substituteInPlace package.json \
    --replace-fail '"electron": "^34.1.1"' '"electron": "*"'
  
  # Fix app name and userData path  
  substituteInPlace src/index.ts \
    --replace-fail 'const options = await this.options.get()' \
      'app.setName("Filen Desktop")
      app.setPath("userData", pathModule.join(app.getPath("appData"), "@filen", "desktop"))
      const options = await this.options.get()'
  
  # Disable code signing
  substituteInPlace package.json \
    --replace-fail '"afterSign": "build/notarize.js",' ""
'';
```

### Build Process

1. **TypeScript compilation**: `npm run build`
2. **electron-builder**: Creates .app in `prod/mac*/`
3. **Install**: Copy .app to `$out/Applications/`
4. **Wrapper**: Create `$out/bin/filen-desktop` pointing to .app executable

## Testing Checklist

After rebuild and reinstall, verify:

- [ ] App shows as "Filen Desktop" in Activity Monitor
- [ ] Menu bar shows "Filen Desktop" not "Electron"
- [ ] Login items show "Filen Desktop" with correct icon
- [ ] App data stored in `~/Library/Application Support/@filen/desktop`
- [ ] No `~/Library/Application Support/Electron` folder created
- [ ] "Open at Login" works correctly
- [ ] App launches from both CLI (`filen-desktop`) and Applications folder

## Important Notes

### macOS Specifics

- **electron.dist must be writable**: `cp -r ${electron.dist} electron-dist && chmod -R u+w electron-dist`
- **Output location**: electron-builder creates .app in `prod/mac-arm64/` or `prod/mac-x64/`
- **App name**: Defined in package.json as `productName: "Filen"`
- **Bundle ID**: Defined in package.json as `appId: "io.filen.desktop"`

### Login Items Behavior

The login item registration in Filen (`src/ipc/index.ts`):
```typescript
app.setLoginItemSettings({
  openAtLogin: enabled,
  openAsHidden: true,
  args: ["--hidden"]
})
```

When called from within a proper .app bundle, `app.setLoginItemSettings()` correctly registers the .app bundle (not the electron binary).

### Background Task Management

On macOS, apps appear in System Settings → Login Items under:
- **Open at Login**: User-initiated launch agents
- **Allow in Background**: System-registered background services

Both lists are populated from `launchd` services. Check with:
```bash
launchctl list | grep filen
sfltool dumpbtm | grep -i filen
```

## Troubleshooting

### If app still shows as "Electron"

1. Completely uninstall:
   ```bash
   pkill -f filen
   rm -rf ~/Library/Application\ Support/@filen
   rm -rf ~/Library/Application\ Support/Electron
   launchctl list | grep -i electron | awk '{print $3}' | xargs -I {} launchctl remove {}
   ```

2. Rebuild package completely (not just reinstall)

3. Check .app bundle identity:
   ```bash
   /usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" \
     /nix/store/*-filen-desktop-*/Applications/Filen.app/Contents/Info.plist
   ```
   Should return: `io.filen.desktop`

4. Verify electron-builder ran:
   ```bash
   # Build output should show: "electron-builder" running
   # Should create prod/mac-*/Filen.app
   ```

### Common Build Errors

**Error: `unexpected EOF while looking for matching `''`**
- Multiline string syntax error in substituteInPlace
- Use simple quoted strings, not `''$'...'` syntax

**Error: electron-builder not found**
- Check npmDepsHash is correct
- Verify electron-builder is in package.json dependencies

**Error: Code signing failed**
- Ensure `afterSign` is removed from package.json
- electron-builder tries to sign on macOS by default

## References

- Gitify package: `/nix/store/.../pkgs/by-name/gi/gitify/package.nix`
- Obsidian package: `/nix/store/.../pkgs/by-name/ob/obsidian/package.nix`
- electron-builder docs: https://www.electron.build/
- Filen Desktop repo: https://github.com/FilenCloudDienste/filen-desktop

## Next Steps

1. Test current electron-builder implementation
2. If successful, clean up any remaining unused code
3. Consider upstreaming to nixpkgs
4. Document any platform-specific quirks discovered

## Changes Made to Original Package

### Removed
- `desktopToDarwinBundle` (darwin-only)
- All `postFixup` Info.plist modifications
- `preInstall` icon copying
- Manual .app executable replacement
- FILEN_APP_PATH environment variable approach

### Added
- `buildPhase` override for electron-builder
- Platform-specific `installPhase`
- `copyDesktopItems` and `imagemagick` (Linux only)
- Proper electron.dist copying for macOS

### Modified
- `npmBuildScript` removed (using custom buildPhase)
- `nativeBuildInputs` cleaned up
- Source patches simplified
