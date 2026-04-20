{inputs}: let
  inherit inputs;
in rec {
  mkPkgs = {system}:
    import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

  mkCompileMode = {system}: let
    pkgs = mkPkgs {inherit system;};
  in
    pkgs.vimUtils.buildVimPlugin {
      name = "compile-mode";
      doCheck = true;
      dependencies = with pkgs.vimPlugins; [plenary-nvim];
      src = pkgs.fetchFromGitHub {
        owner = "ej-shafran";
        repo = "compile-mode.nvim";
        rev = "v5.14.0";
        sha256 = "sha256-cUh3ekDENsVH/XVEHeV7KVKTIlkoht+rHtXnR3C+lGY=";
      };
    };

  mkVimPlugin = {system}: let
    pkgs = mkPkgs {inherit system;};
    compile-mode = mkCompileMode {inherit system;};
  in
    pkgs.vimUtils.buildVimPlugin {
      doCheck = true;
      name = "rudesome";
      src = ../.;

      dependencies = with pkgs.vimPlugins; [
        # languages
        nvim-lspconfig
        nvim-treesitter-context
        nvim-treesitter.withAllGrammars

        # completion
        cmp-buffer
        cmp-cmdline
        cmp-nvim-lsp
        cmp-path
        cmp-tabnine
        cmp-treesitter
        friendly-snippets
        lspkind-nvim
        luasnip
        cmp_luasnip
        nvim-cmp

        # telescope
        plenary-nvim
        telescope-nvim

        # theme
        gruvbox

        # floaterm
        vim-floaterm

        # extras
        compile-mode
        gitsigns-nvim
        harpoon2
        lualine-nvim
        nerdcommenter
        nui-nvim
        nvim-colorizer-lua
        nvim-notify
        nvim-web-devicons
      ];

      nvimSkipModules = [
        "init"
        "rudesome.languages"
        "rudesome.treesitter"
      ];

      postInstall = ''
        rm -rf $out/.gitignore
        rm -rf $out/README.md
        rm -rf $out/flake.lock
        rm -rf $out/flake.nix
        rm -rf $out/lib
      '';
    };

  mkNeovimPlugins = {system}: let
    rudesome-nvim = mkVimPlugin {inherit system;};
  in [
    # configuration (last)
    rudesome-nvim
  ];

  mkExtraPackages = {system}: let
    pkgs = mkPkgs {inherit system;};
    inherit (pkgs) python3Packages;
  in [
    # language servers
    pkgs.bash-language-server
    pkgs.dhall-lsp-server
    pkgs.dockerfile-language-server
    pkgs.gopls
    pkgs.jsonnet-language-server
    pkgs.lua-language-server
    pkgs.marksman
    pkgs.nil
    pkgs.nixd
    pkgs.ocamlPackages.ocaml-lsp
    pkgs.pyright
    pkgs.terraform-ls
    pkgs.typescript
    pkgs.typescript-language-server
    pkgs.vscode-langservers-extracted
    pkgs.yaml-language-server
    pkgs.zls

    # formatters
    pkgs.alejandra
    pkgs.gofumpt
    pkgs.golines
    pkgs.ocamlPackages.ocamlformat
    pkgs.terraform
    python3Packages.black
  ];

  mkExtraConfig = ''
    lua << EOF
      require 'rudesome'.init()
    EOF
  '';

  mkNeovim = {system}: let
    pkgs = mkPkgs {inherit system;};
    inherit (pkgs) lib neovim;
    extraPackages = mkExtraPackages {inherit system;};
    start = mkNeovimPlugins {inherit system;};
  in
    neovim.override {
      configure = {
        customRC = mkExtraConfig;
        packages.main = {inherit start;};
      };
      extraMakeWrapperArgs = ''--suffix PATH : "${lib.makeBinPath extraPackages}"'';
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };

  mkHomeManager = {system}: let
    extraConfig = mkExtraConfig;
    extraPackages = mkExtraPackages {inherit system;};
    plugins = mkNeovimPlugins {inherit system;};
  in {
    inherit extraConfig extraPackages plugins;
    defaultEditor = true;
    enable = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
  };
}
