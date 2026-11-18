{inputs}: rec {
  mkPkgs = {system}:
    import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

  mkCompileMode = {system}: let
    pkgs = mkPkgs {inherit system;};
  in
    pkgs.vimUtils.buildVimPlugin {
      pname = "compile-mode";
      version = "5.16.0";
      doCheck = true;
      dependencies = with pkgs.vimPlugins; [plenary-nvim];
      src = pkgs.fetchFromGitHub {
        owner = "ej-shafran";
        repo = "compile-mode.nvim";
        rev = "v5.16.0";
        hash = "sha256-rVDVo734ig5eNsJ2/vMGllxOcgvJvI3tw6ApOZ6sl3o=";
      };
    };

  mkVimPlugin = {system}: let
    pkgs = mkPkgs {inherit system;};
    compile-mode = mkCompileMode {inherit system;};
  in
    pkgs.vimUtils.buildVimPlugin {
      doCheck = true;
      pname = "rudesome";
      version = "0-unstable";
      src = pkgs.lib.fileset.toSource {
        root = ../.;
        fileset = ../lua;
      };

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
        nvim-colorizer-lua
        nvim-web-devicons
      ];

      nvimSkipModules = [
        "rudesome.languages"
        "rudesome.treesitter"
      ];
    };

  mkNeovimPlugins = {system}: let
    rudesome-nvim = mkVimPlugin {inherit system;};
  in [
    # configuration (last)
    rudesome-nvim
  ];

  mkExtraPackages = {system}: let
    pkgs = mkPkgs {inherit system;};
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
    pkgs.ocamlPackages.ocaml-lsp
    pkgs.pyright
    pkgs.terraform-ls
    pkgs.typescript
    pkgs.typescript-language-server
    pkgs.vscode-langservers-extracted
    pkgs.yaml-language-server
    pkgs.zls

    # formatters (invoked by the language servers above)
    pkgs.alejandra # nil_ls
    pkgs.ocamlPackages.ocamlformat # ocamllsp
    pkgs.terraform # terraformls (terraform fmt)
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
      # no plugin needs the remote-plugin providers
      withNodeJs = false;
      withPython3 = false;
      withRuby = false;
    };

  mkHomeManager = {system}: let
    extraConfig = mkExtraConfig;
    extraPackages = mkExtraPackages {inherit system;};
    plugins = mkNeovimPlugins {inherit system;};
  in {
    inherit extraConfig extraPackages plugins;
    defaultEditor = true;
    enable = true;
    withNodeJs = false;
    withPython3 = false;
    withRuby = false;
  };
}
