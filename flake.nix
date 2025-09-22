{
  description = "Nix library for packaging Magisk modules";

  outputs =
    { self }:
    {
      lib.packageMagiskModule = pkgs: pkgs.callPackage ./packageMagiskModule.nix { };

      templates.default = {
        path = ./template;
        description = "Magisk module template using magisk-module-nix";
        welcomeText = ''
          # magisk-module-nix template

          Run `nix build .#magiskModule.installer` to get started
        '';
      };
    };
}
