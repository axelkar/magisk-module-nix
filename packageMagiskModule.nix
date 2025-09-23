{
  lib,
  stdenvNoCC,
  runCommand,
  fetchurl,
  strip-nondeterminism,
  zip,
}:

lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  excludeDrvArgNames = [
    "modid"
    "prettyName"
    "version"
    "versionCode"
    "author"
    "description"
    "updateJSONUrl"
    "meta"
    "extraCommands"
    "gitHubOwnerRepo"
    "gitHubCompatibleReleasesUrl"
    "gitTag"
    "zipUrl"
    "changelogUrl"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      modid,
      prettyName,
      version,
      versionCode,
      author,
      description,
      updateJSONUrl ? null,
      meta ? { },
      extraCommands ? "",
      gitHubOwnerRepo,
      gitHubCompatibleReleasesUrl ? "https://github.com/${gitHubOwnerRepo}/releases",
      gitTag ? "v${version}",
      zipUrl ? "${gitHubCompatibleReleasesUrl}/download/${gitTag}/${modid}-${version}.zip",
      changelogUrl ? "${gitHubCompatibleReleasesUrl}/tag/${gitTag}",
      ...
    }:

    let versionCode' = builtins.toString versionCode; in
    let versionCode = versionCode'; in

    # https://topjohnwu.github.io/Magisk/guides.html#moduleprop
    assert
      ((builtins.match "^[a-zA-Z][a-zA-Z0-9._-]+$" modid) != null)
      || builtins.throw "Magisk module ID (modid) \"${modid}\" doesn't match regular expression ^[a-zA-Z][a-zA-Z0-9._-]+$";

    {
      pname = modid;
      inherit version;

      # `module.prop` contents as defined here:
      # https://topjohnwu.github.io/Magisk/guides.html#moduleprop
      moduleProp = ''
        id=${modid}
        name=${prettyName}
        version=${version}
        versionCode=${versionCode}
        author=${author}
        description=${description}
      ''
      + lib.optionalString (updateJSONUrl != null) ''
        updateJson=${updateJSONUrl}
      '';

      buildCommand = ''
        mkdir "$out"
        cd "$out"

        if [ -v src ]; then
          cp -r "$src/." "$out"
        fi

        printf "%s" "$moduleProp" > module.prop

        ${extraCommands}
      '';

      # Magisk update JSON as defined here:
      # https://topjohnwu.github.io/Magisk/guides.html#moduleprop
      passthru.magiskUpdateJSON = builtins.toJSON {
        inherit version versionCode zipUrl;
        changelog = changelogUrl;
      };

      # Magisk module installer ZIP file as defined here:
      # https://topjohnwu.github.io/Magisk/guides.html#magisk-module-installer
      passthru.installer = runCommand "${finalAttrs.finalPackage.name}-installer-zip" { } (
        let
          moduleInstaller = fetchurl {
            url = "https://raw.githubusercontent.com/topjohnwu/Magisk/8b7d1ffcdd64dc9c06de7f135ff312439e560eed/scripts/module_installer.sh";
            hash = "sha256-vPSx2ZE/OvF3VVachT4LWnW4AF9qGOs/htrcwOlowp0=";
          };
        in
        ''
          cd $(mktemp -d)

          cp -r "${finalAttrs.finalPackage}"/. .

          install -D ${moduleInstaller} META-INF/com/google/android/update-binary
          echo '#MAGISK' > META-INF/com/google/android/updater-script

          mkdir -p $out/installer-zip
          outZip=$out/installer-zip/${finalAttrs.finalPackage.name}.zip

          ${lib.getExe zip} -Xr $outZip .
          # Strip nondeterminism!
          ${lib.getExe strip-nondeterminism} $outZip

          # Hydra support
          mkdir -p $out/nix-support
          echo "file binary-dist $outZip" >> $out/nix-support/hydra-build-products
        ''
      );

      meta = {
        inherit description;
        changelog = changelogUrl;
      }
      // meta;
    };
}
