# gemini-cli-nix

Nix flake for Google's [Gemini CLI](https://github.com/google-gemini/gemini-cli), following the
npm release feed, so it is usually ahead of nixpkgs (which builds it from source and lags).

The package wraps the prebuilt bundle (`bundle/gemini.js`) that the npm tarball ships, and runs
it with Node 22. Nothing is built, and no npm dependency tree is fetched.

> **Status of the tool itself:** Google retired Gemini CLI for individual users on 2026-06-18
> (free, AI Pro and Ultra accounts; "Sign in with Google" now fails). It still works with a paid
> API key or Vertex AI, and for organisations with Gemini Code Assist licences. Google's
> replacement is Antigravity CLI, packaged in [agy-nix](https://github.com/mastratisi/agy-nix).

## Use

```
nix run github:mastratisi/gemini-cli-nix
```

In a flake-based NixOS config:

```nix
inputs.gemini-cli-nix.url = "github:mastratisi/gemini-cli-nix";
# ...
nixpkgs.overlays = [ gemini-cli-nix.overlays.default ];
environment.systemPackages = [ pkgs.gemini-cli ];
```

The overlay replaces nixpkgs' `gemini-cli`. Systems: Linux only.

## Known gaps

- The native optional dependencies (`node-pty`, `keytar`) are not in the tarball, so
  interactive shell (PTY) mode is probably unavailable, as in nixpkgs' build.
- `ripgrep` is put on `PATH`; the bundle is minified, so nixpkgs' source patch for it does not apply.
- The built-in auto-update setting is not switched off yet.

## How it stays current

- `update.sh` reads `https://registry.npmjs.org/@google/gemini-cli/latest` and writes
  `release.json` (version, tarball URL, npm's SRI integrity hash). Needs `jq`, `curl`.
- `.github/workflows/update.yml` runs it hourly, builds, checks `gemini --version` matches, and
  commits `release.json` if it changed.
- `package.nix` only reads `release.json`; it has no version of its own.

Update by hand: `nix develop -c ./update.sh && nix build`.
