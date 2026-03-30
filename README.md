# coderabbit-nix

Nix flake that packages the [CodeRabbit CLI](https://coderabbit.ai) -- an AI-powered code review tool for the command line.

There is no upstream Nix package for CodeRabbit. This flake fetches the official pre-built binary and patches it for NixOS using [wrap-buddy](https://github.com/Mic92/wrap-buddy).

## Quick start

```nix
# flake.nix
{
  inputs.coderabbit.url = "github:tienedev/coderabbit-nix";

  outputs = { self, nixpkgs, coderabbit, ... }: {
    # Then use one of the installation methods below
  };
}
```

## Installation

### Home-Manager module (recommended)

```nix
{
  imports = [ coderabbit.homeManagerModules.default ];
}
```

This adds the `coderabbit` (and `cr`) binary to your `home.packages`.

### Overlay

```nix
nixpkgs.overlays = [ coderabbit.overlays.default ];
```

Then use `pkgs.coderabbit` anywhere in your config.

### Standalone (try without installing)

```bash
nix run github:tienedev/coderabbit-nix -- --help
```

## Usage

```bash
# Authenticate with CodeRabbit
cr auth login

# Review the current branch against main
cr review

# Review with plain text output (no TUI)
cr review --plain

# Print the prompt without sending to AI
cr review --prompt-only

# Review a specific PR
cr review --pr 42
```

Run `cr --help` for the full command reference.

## Updating

When a new CodeRabbit CLI version is released:

1. Edit `package.nix` -- bump `version` and update the `hash` for each platform.
2. To get the new hashes, set each hash to `""` and run `nix build` -- the error output will include the correct hash.
3. Commit and push.

## Supported platforms

| System | Architecture |
| --- | --- |
| `x86_64-linux` | Intel/AMD 64-bit Linux |
| `aarch64-linux` | ARM 64-bit Linux |
| `x86_64-darwin` | Intel Mac |
| `aarch64-darwin` | Apple Silicon Mac |

## How it works

The CodeRabbit CLI is distributed as a Bun-compiled binary. On NixOS, these binaries fail at runtime because they expect FHS paths (e.g., `/lib64/ld-linux-x86-64.so.2`).

This flake uses [wrap-buddy](https://github.com/Mic92/wrap-buddy) (by Mic92) as a setup hook to automatically patch the binary's interpreter and library paths on Linux. On macOS, the binary works as-is -- wrap-buddy is skipped.

`libsecret` is included as a build input on Linux for keychain integration (`cr auth login`).

## License

This flake is [MIT licensed](LICENSE).

Note: the CodeRabbit CLI binary itself is proprietary software. See [coderabbit.ai](https://coderabbit.ai) for its terms.
