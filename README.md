# rudesome.nvim

Neovim configuration (Lua + Nix flake).

## Usage

### Run directly

```sh
nix run github:rudesome/rudesome.nvim#neovim
```

### Add as flake input

```nix
inputs = {
  rudesome-nvim.url = "github:rudesome/rudesome.nvim";
};
```

### Home Manager

```nix
programs.neovim = inputs.rudesome-nvim.lib.mkHomeManager {
  system = pkgs.system;
};
```

### NixOS / nix-darwin systemPackages

```nix
environment.systemPackages = [
  inputs.rudesome-nvim.packages.${pkgs.system}.neovim
];
```

## Layout

- `init.lua` — entrypoint, calls `require 'rudesome'.init()`
- `lua/rudesome/` — modules (vim, theme, telescope, languages, …)
- `lib/default.nix` — `mkVimPlugin`, `mkNeovim`, `mkHomeManager`
- `flake.nix` — outputs
