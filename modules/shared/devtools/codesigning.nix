{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:

let
  moduleSet = "mySharedModules";
  moduleCategory = "devtools";
  moduleName = "codesigning";
  nixConfigHome = config.environment.variables.NIX_CONFIG_HOME;
  codeSignDir = "${nixConfigHome}/profiles/${mainUser.username}/private/codesign";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};

  ykSigningSlot = "9c";

  codeSignRSA = "2048";
  codeSignKeyEncFile = "${codeSignDir}/codesign-key.enc";
  codeSignKeyPubFile = "${codeSignDir}/codesign-key.pub";

  codeSignReqCsrFile = "${codeSignDir}/codesign-req.csr";
  codeSignReqConfFile = "${codeSignDir}/codesign-req.conf";
  codeSignReqConf = ''
    [req]
    prompt = no
    distinguished_name = req_distinguished_name
    req_extensions = v3_req

    [req_distinguished_name]
    C = ${mainUser.country}
    ST = ${mainUser.state}
    L = ${mainUser.city}
    O = ${mainUser.name}
    OU = ${mainUser.orgUnit}
    CN = ${mainUser.name}
    emailAddress = ${mainUser.email}

    [v3_req]
    keyUsage = digitalSignature
    extendedKeyUsage = codeSigning
  '';

  appleCertificatesUrl = "https://developer.apple.com/account/resources/certificates/list";
  appleNotaryApiUrl = "https://appstoreconnect.apple.com/access/integrations/api";
  appleCodeSignCertFile = "${codeSignDir}/codesign-apple.cer";
  appleCodeSignPemFile = "${codeSignDir}/codesign-apple.pem";
  appleCodeSignIdentityP12File = "${codeSignDir}/codesign-apple-identity.p12";
  appleCodeSignKeychainFile = "$HOME/Library/Keychains/login.keychain-db";
  appleNotaryProfile = "notary";
  appleNotaryApiKeyFile = "${codeSignDir}/codesign-apple-appstoreconnectapi.p8";
  appleNotaryTool = "/Applications/Xcode.app/Contents/Developer/usr/bin/notarytool";
  appleStaplerTool = "/Applications/Xcode.app/Contents/Developer/usr/bin/stapler";
  appleCodesignTool = "/usr/bin/codesign";
  appleSecurityTool = "/usr/bin/security";
  appleSpctlTool = "/usr/sbin/spctl";
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${mainUser.username} =
      { ... }:
      {
        home.packages = with pkgs; [
          age
          sops
          ssh-to-age
          age-plugin-yubikey
          yubico-piv-tool
          yubikey-manager
        ];

        home.sessionVariables = {
          CODESIGN_DIR = codeSignDir;
          CODESIGN_KEY_ENC_FILE = codeSignKeyEncFile;
          CODESIGN_KEY_PUB_FILE = codeSignKeyPubFile;
          CODESIGN_REQ_CONF_FILE = codeSignReqConfFile;
          CODESIGN_REQ_CSR_FILE = codeSignReqCsrFile;
          CODESIGN_APPLE_CERT_FILE = appleCodeSignCertFile;
          CODESIGN_APPLE_PEM_FILE = appleCodeSignPemFile;
          CODESIGN_IDENTITY_P12_FILE = appleCodeSignIdentityP12File;
          CODESIGN_NOTARY_P8_FILE = appleNotaryApiKeyFile;
        };

      };

    # helper alias scripts
    mySharedModules.home.shells.scripts = {
      cs-ensure-prereqs = ''
        mkdir -p "${codeSignDir}"

        if [ ! -f "${codeSignReqConfFile}" ]; then
          cs-generate-conf
        fi

        if [[ ! -f "${codeSignKeyEncFile}" || ! -f "${codeSignKeyPubFile}" ]]; then
          cs-generate-keys
        fi

        if [ ! -f "${codeSignReqCsrFile}" ]; then
          cs-generate-req
        fi
      '';

      sign-sops = ''
        SIGN_FILE=''${1}
        SIG_OUT="$SIGN_FILE.sig"

        if [ ! -f "$SIGN_FILE" ]; then
          echo "Please pass a valid file as arg 1 (what you want to sign)"
          exit 1
        fi

        sops -d "${codeSignKeyEncFile}" | openssl dgst \
          -sha512 \
          -sign /dev/stdin \
          -out "$SIG_OUT" \
          "$SIGN_FILE"

        echo "Signature created: $SIG_OUT"
      '';

      cs-setup = ''
        cs-ensure-prereqs

        ${
          if pkgs.stdenv.isDarwin then
            ''
              cs-setup-apple
            ''
          else
            ''

            ''
        }
      '';

      cs-apple-bin = ''
        set -euo pipefail

        BIN_FILE=''${1}

        if [ -z "''${BIN_FILE:-}" ] || [ ! -e "$BIN_FILE" ]; then
          echo "Usage: cs-apple-bin </path/to/binary-or-app>"
          exit 1
        fi

        SIGN_IDENT=$(\
          "${appleSecurityTool}" find-identity -v -p codesigning \
          | grep '"' \
          | cut -d '"' -f2 \
          | head -n1
        )

        if [ -z "''${SIGN_IDENT:-}" ]; then
          echo "No signing identity found"
          exit 1
        fi

        echo "Signing binary with $SIGN_IDENT"
        "${appleCodesignTool}" --force --timestamp --options runtime \
          --sign "$SIGN_IDENT" \
          "$BIN_FILE"

        "${appleCodesignTool}" --verify --strict --verbose=2 "$BIN_FILE"
      '';

      cs-apple-dmg = ''
        set -euo pipefail

        SIGN_FILE=''${1}
        NOTARY_PROFILE_VAL="''${2:-''${NOTARY_PROFILE:-${appleNotaryProfile}}}"

        if [ -z "''${SIGN_FILE:-}" ] || [ ! -e "$SIGN_FILE" ]; then
          echo "Usage: cs-apple-dmg <.dmg> [notary-profile]"
          exit 1
        fi

        if [ "''${SIGN_FILE##*.}" != "dmg" ]; then
          echo "cs-apple-dmg supports .dmg only"
          exit 1
        fi

        SIGN_IDENT=$(\
          "${appleSecurityTool}" find-identity -v -p codesigning \
          | grep '"' \
          | cut -d '"' -f2 \
          | head -n1
        )

        if [ -z "''${SIGN_IDENT:-}" ]; then
          echo "No signing identity found"
          exit 1
        fi

        echo "Signing with $SIGN_IDENT"

        "${appleCodesignTool}" --force --timestamp --options runtime \
          --sign "$SIGN_IDENT" \
          "$SIGN_FILE"

        "${appleCodesignTool}" --verify --strict --verbose=2 "$SIGN_FILE"

        echo "Notarizing $SIGN_FILE (profile: $NOTARY_PROFILE_VAL)"
        "${appleNotaryTool}" submit "$SIGN_FILE" --keychain-profile "$NOTARY_PROFILE_VAL" --wait

        echo "Stapling $SIGN_FILE"
        "${appleStaplerTool}" staple "$SIGN_FILE"

        echo "Assessing trust"
        "${appleSpctlTool}" --assess --type execute -vv "$SIGN_FILE"
      '';

      cs-setup-apple = ''
        set -euo pipefail

        if [ ! -x "${appleNotaryTool}" ] || [ ! -x "${appleStaplerTool}" ]; then
          echo "Missing Xcode notarization tools; install Xcode and open it once"
          exit 1
        fi

        echo "cs-apple: setup"
        xcode-select --install 2>/dev/null || true
        cs-ensure-prereqs

        if [ ! -f "${appleCodeSignCertFile}" ]; then
          echo "Missing ${appleCodeSignCertFile}; upload ${codeSignReqCsrFile} at ${appleCertificatesUrl}, then save cert as ${appleCodeSignCertFile}"
          exit 1
        fi

        umask 077
        TMPKEY="$(mktemp -t codesign_key.XXXXXX)"
        trap 'rm -f "$TMPKEY"' EXIT
        sops -d "${codeSignKeyEncFile}" > "$TMPKEY"

        APPLE_PEM="${appleCodeSignPemFile}"
        if openssl x509 -in "${appleCodeSignCertFile}" -inform DER -noout >/dev/null 2>&1; then
          openssl x509 -in "${appleCodeSignCertFile}" -inform DER -out "$APPLE_PEM"
        else
          cp "${appleCodeSignCertFile}" "$APPLE_PEM"
        fi

        KEYFP="$(openssl pkey -in "$TMPKEY" -pubout | openssl sha256 | awk '{print $2}')"
        CERTFP="$(openssl x509 -in "$APPLE_PEM" -pubkey -noout | openssl sha256 | awk '{print $2}')"
        if [ "$KEYFP" != "$CERTFP" ]; then
          echo "Apple cert does not match private key"
          echo "Regenerate CSR, upload ${codeSignReqCsrFile} at ${appleCertificatesUrl}, download new cert to ${appleCodeSignCertFile}, rerun cs-setup-apple"
          exit 1
        fi

        P12_OUT="${appleCodeSignIdentityP12File}"
        create_p12() {
          echo "Creating $P12_OUT (password prompt expected)"
          openssl pkcs12 -export \
            -inkey "$TMPKEY" \
            -in "$APPLE_PEM" \
            -name "Apple Code Signing" \
            -out "$P12_OUT"
        }

        if [ ! -f "$P12_OUT" ]; then
          create_p12
        fi

        echo "Importing identity to login keychain"
        if ! "${appleSecurityTool}" import "$P12_OUT" -f pkcs12 -k "${appleCodeSignKeychainFile}"; then
          echo "Import failed; recreating $P12_OUT"
          rm -f "$P12_OUT"
          create_p12
          "${appleSecurityTool}" import "$P12_OUT" -f pkcs12 -k "${appleCodeSignKeychainFile}"
        fi

        NOTARY_PROFILE_NAME="''${NOTARY_PROFILE:-${appleNotaryProfile}}"
        echo "Ensuring notary profile: $NOTARY_PROFILE_NAME"
        if ! "${appleNotaryTool}" history --keychain-profile "$NOTARY_PROFILE_NAME" >/dev/null 2>&1; then
          if [ ! -f "${appleNotaryApiKeyFile}" ]; then
            echo "Missing API key file: ${appleNotaryApiKeyFile}"
            exit 1
          fi

          echo "API key help: ${appleNotaryApiUrl}"
          NOTARY_KEY_ID="''${NOTARY_API_KEY_ID:-}"
          NOTARY_ISSUER_ID="''${NOTARY_API_KEY_ISSUER:-}"

          if [ -z "$NOTARY_KEY_ID" ]; then
            read -r -p "App Store Connect Key ID: " NOTARY_KEY_ID
          fi

          if [ -z "$NOTARY_ISSUER_ID" ]; then
            read -r -p "App Store Connect Issuer ID: " NOTARY_ISSUER_ID
          fi

          if [ -z "$NOTARY_KEY_ID" ] || [ -z "$NOTARY_ISSUER_ID" ]; then
            echo "Key ID and Issuer ID are required"
            exit 1
          fi

          echo "Creating notary profile from API key"
          "${appleNotaryTool}" store-credentials "$NOTARY_PROFILE_NAME" \
            --key "${appleNotaryApiKeyFile}" \
            --key-id "$NOTARY_KEY_ID" \
            --issuer "$NOTARY_ISSUER_ID"
        fi

        echo "Available codesigning identities:"
        "${appleSecurityTool}" find-identity -v -p codesigning

        echo "Use with: cs-apple-bin </path/to/bin-or-app> then cs-apple-dmg /path/to/MyApp.dmg [$NOTARY_PROFILE_NAME]"
      '';

      cs-generate-keys = ''

        if [ ! -f "${codeSignKeyEncFile}" ]; then
          echo "cs: generate private key"
          openssl genrsa ${codeSignRSA} | sops -e /dev/stdin > "${codeSignKeyEncFile}"
        fi

        if [ ! -f "${codeSignKeyPubFile}" ]; then
          echo "cs: generate public key"
          sops -d "${codeSignKeyEncFile}" | openssl rsa \
            -in /dev/stdin \
            -pubout -out "${codeSignKeyPubFile}"
        fi
      '';

      cs-generate-conf = ''
        echo "cs: write ${codeSignReqConfFile}"
        cat > "${codeSignReqConfFile}" <<EOF
        ${codeSignReqConf}
        EOF
      '';

      cs-generate-req = ''
        echo "cs: generate csr"
        sops -d "${codeSignKeyEncFile}" | openssl req -new \
          -key /dev/stdin \
          -config "${codeSignReqConfFile}" \
          -out "${codeSignReqCsrFile}"

        echo "cs: validate csr"
        openssl req -in "${codeSignReqCsrFile}" -verify -noout >/dev/null 2>&1

        echo "Upload ${codeSignReqCsrFile} to ${appleCertificatesUrl}"
      '';

      yk-info = ''
        ykman --version
        ykman list
        ykman info
        ykman piv info
      '';

      yk-piv-reset = ''
        # Offer full factory reset of Yubikey PIV
        read -p "Factory Reset Yubikey PIV Config? (y/N): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && ykman piv reset && echo "PIV reset complete"

        # Offer credential resetting
        read -p "Set new credentials? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          echo "Updating management key"
          #ykman piv access change-management-key --generate --protect
          ykman piv access change-management-key -a TDES --protect

          echo "Updating PIN"
          ykman piv access change-pin

          echo "Updating PUK"
          ykman piv access change-puk
        fi
      '';

      yk-getserials = ''
        ykman list --serials 2>/dev/null
      '';

      yk-push-signing = ''
        CRT_CA=''${1}

        if [ -z "$CRT_CA" ]; then
          echo "Please provide valid .crt as arg 1"
          exit 1
        fi

        echo "Clearing slot ${ykSigningSlot} cert"
        ykman piv certificates delete ${ykSigningSlot}

        echo "Done"
      '';

    };
  };
}
