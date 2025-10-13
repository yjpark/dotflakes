{
  pkgs,
  lib,
  ...
}: {
  # https://nix-community.github.io/nixvim/plugins/lspconfig/index.html
  plugins.lspconfig.enable = true;
  plugins.lspconfig.autoLoad = true;

  # https://nix-community.github.io/nixvim/lsp/servers/index.html
  lsp.servers = {
    fish_slp.enable = true;
    gopls.enable = true;
    jsonls.enable = true;
    just.enable = true;
    marksman.enable = true;
    nixd.enable = true;
    nushell.enable = true;
    pyright.enable = true;
    ruff.enable = true;
    rust_analyzer.enable = true;
    tailwindcss.enable = true;
    tombi.enable = true;
  };

  # https://nix-community.github.io/nixvim/lsp/keymaps/index.html
  lsp.keymaps = [
    {
      key = "gd";
      lspBufAction = "definition";
    }
    {
      key = "gD";
      lspBufAction = "references";
    }
    {
      key = "gt";
      lspBufAction = "type_definition";
    }
    {
      key = "gi";
      lspBufAction = "implementation";
    }
    {
      key = "K";
      lspBufAction = "hover";
    }
    {
      action = lib.nixvim.mkRaw "function() vim.diagnostic.jump({ count=-1, float=true }) end";
      key = "<leader>k";
    }
    {
      action = lib.nixvim.mkRaw "function() vim.diagnostic.jump({ count=1, float=true }) end";
      key = "<leader>j";
    }
    {
      action = "<CMD>LspStop<Enter>";
      key = "<leader>lx";
    }
    {
      action = "<CMD>LspStart<Enter>";
      key = "<leader>ls";
    }
    {
      action = "<CMD>LspRestart<Enter>";
      key = "<leader>lr";
    }
    {
      action = lib.nixvim.mkRaw "require('telescope.builtin').lsp_definitions";
      key = "gd";
    }
    {
      action = "<CMD>Lspsaga hover_doc<Enter>";
      key = "K";
    }
  ];
}
# LSP

