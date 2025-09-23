# magisk-module-nix

**Nix library for packaging [Magisk](https://github.com/topjohnwu/Magisk) modules**

- Supports flakes and plain Nix
- Automatic update JSON and `module.prop` generation
- Declarative single source of truth
- Zero boilerplate: Code never gets stagnant
- [Reproducible](https://reproducible-builds.org/): Users can trust that software hasn't been altered

## Try it

Install [Nix](https://nixos.org/) with Nix flakes and run these commands:

```console
$ nix flake new my-module -t github:axelkar/magisk-module-nix

# magisk-module-nix template

Run `nix build .#magiskModule.installer` to get started

$ cd my-module
$ nix build .#magiskModule.installer
$ zipinfo -1 result/installer-zip/my-module-25.09.zip
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

You can start off with just one file: [`flake.nix`](template/flake.nix).

See [ZygiskFrida-webui](https://github.com/axelkar/ZygiskFrida-webui) for an example of GitHub Actions integration.

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

    # Copy from another derivation
    extraCommands = ''
      cp -r ${webui} $out/webroot
    '';

    # For update JSON
    gitHubOwnerRepo = "johndoe/my-module";
  };
in
{
  # Directory containing the module
  inherit magiskModule;

  # Magisk module installer ZIP file as defined here:
  # https://topjohnwu.github.io/Magisk/guides.html#magisk-module-installer
  installer = magiskModule.installer;

  # Magisk update JSON as defined here:
  # https://topjohnwu.github.io/Magisk/guides.html#moduleprop
  updateJSON = magiskModule.magiskUpdateJSON;
}
```

## API

### `packageMagiskModule`

#### Arguments

`pkgs`: [Nixpkgs](https://github.com/NixOS/nixpkgs) instance. Example: `import <nixpkgs> { }`

<dl>
  <dt><code>modid</code></dt>
  <dd>Magisk module ID

  Example: `"my-module"`

  Must match the regular expression `^[a-zA-Z][a-zA-Z0-9._-]+$`</dd>
  <dt><code>prettyName</code></dt>
  <dd>Name of the module, shown in the Magisk app

  Example: `"My Module"`</dd>
  <dt><code>version</code></dt>
  <dd>Version of the module

  Example: `"1.2.3"`</dd>
  <dt><code>versionCode</code></dt>
  <dd>32-bit integer representation of the module's version

  Example: `0000010203`</dd>
  <dt><code>author</code></dt>
  <dd>Name of the author, shown in the Magisk app</dd>
  <dt><code>description</code></dt>
  <dd>Description of the module, shown in the Magisk app</dd>
  <dt><code>updateJSONUrl</code> (Optional)</dt>
  <dd>URL of a <a href="https://topjohnwu.github.io/Magisk/guides.html#moduleprop">Magisk update JSON</a> document showing where to get the latest version</dd>
  <dt><code>src</code> (Optional)</dt>
  <dd>Directory to copy into the module's root</dd>
  <dt><code>extraCommands</code> (Optional)</dt>
  <dd>Bash script for adding additional files into the module

  Example: <code>"cp -r ${webui} $out/webroot"</code></dd>
  <dt><code>gitHubOwnerRepo</code></dt>
  <dd>GitHub `owner/repo` pair. Used for <code>gitHubCompatibleReleasesUrl</code></dd>
  <dt><code>gitHubCompatibleReleasesUrl</code></dt>
  <dd>GitHub-compatible releases URL. Also works with Forgejo and Gitea. Used for <code>zipUrl</code> and <code>changelogUrl</code></dd>
  <dt><code>gitTag</code></dt>
  <dd>Git Tag. Used for <code>zipUrl</code> and <code>changelogUrl</code></dd>
  <dt><code>zipUrl</code></dt>
  <dd>URL to an installer ZIP. Default assumes filename `${modid}-${version}.zip`. Used for <code>magiskUpdateJSON</code> attribute</dd>
  <dt><code>changelogUrl</code></dt>
  <dd>URL to a changelog. Used for <code>magiskUpdateJSON</code> attribute</dd>
</dl>

#### Return value

Derivation for the Magisk module, with the following passthru-attributes:

<dl>
  <dt><code>magiskUpdateJSON</code></dt>
  <dd><a href="https://topjohnwu.github.io/Magisk/guides.html#moduleprop">Magisk update JSON</a> string</dd>
  <dt><code>installer</code></dt>
  <dd><a href="https://topjohnwu.github.io/Magisk/guides.html#magisk-module-installer">Magisk module installer</a> ZIP</dd>
</dl>
