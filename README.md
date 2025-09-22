# magisk-module-nix

**Nix library for packaging [Magisk](https://github.com/topjohnwu/Magisk) modules**

- Supports flakes and plain Nix
- Automatic update JSON and `module.prop` generation
- Declarative single source of truth
- Zero boilerplate: Code never gets stagnant
- [Reproducible](https://reproducible-builds.org/): Users can trust that software hasn't been altered

## Try it

Install [Nix](https://nixos.org/) with Nix flakes, and run these commands:

```console
$ nix flake new my-module -t github:axelkar/magisk-module-nix
# magisk-module-nix template

Run `nix build .#magiskModule.installer` to get started
```

## Example

```nix
let
  pkgs = import <nixpkgs> {};
  webui = pkgs.writeTextDir "index.html" ''
    Hello, world!
  '';
  magiskModule = import <magisk-module-nix>/packageMagiskModule.nix pkgs {
    modid = "my-module";
    prettyName = "My Module";
    version = "25.09";
    # 0000XXYYZZ
    versionCode = "0000250900";
    author = "John Doe";
    description = "Showcase of magisk-module-nix functionality";
    updateJSONUrl = "https://raw.githubusercontent.com/johndoe/my-module/main/magisk-update.json";

    # Will copy e.g. `./module/system` to `system` in the ZIP file
    src = ./module;

    # Link in from another derivation
    installCommands = ''
      cp -r ${webui} $out/webroot
    '';

    # For update JSON
    gitHubOwnerRepo = "johndoe/my-module";
  };
in
{
  # Directory containing
  inherit magiskModule;

  # Magisk module installer ZIP file as defined here:
  # https://topjohnwu.github.io/Magisk/guides.html#magisk-module-installer
  installer = magiskModule.installer;

  # Magisk update JSON as defined here:
  # https://topjohnwu.github.io/Magisk/guides.html#moduleprop
  updateJSON = magiskModule.magiskUpdateJSON;
}
```

```console
$ nix build .#magiskModule.installer
$ zipinfo -1 result
META-INF/
META-INF/com/
META-INF/com/google/
META-INF/com/google/android/
META-INF/com/google/android/update-binary
META-INF/com/google/android/updater-script
module.prop
system/
system/example
webroot/
webroot/index.html
```
