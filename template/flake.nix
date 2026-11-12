{
  description = "Magisk module template using magisk-module-nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    magisk-module-nix.url = "github:axelkar/magisk-module-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      magisk-module-nix,
    }:
    {
      packages = builtins.mapAttrs (system: pkgs: rec {
        webui = pkgs.writeTextDir "index.html" ''
          Hello, world!
        '';
        magiskModule = magisk-module-nix.lib.packageMagiskModule pkgs {
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

          # Copy from another derivation
          extraCommands = ''
            cp -r ${webui} $out/webroot
          '';

          # For update JSON
          gitHubOwnerRepo = "johndoe/my-module";
        };

        default = magiskModule.installer;
      }) nixpkgs.legacyPackages;
    };
}
