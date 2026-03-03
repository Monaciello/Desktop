{ config, pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  terminalPlatform = if isDarwin then "osx" else "linux";
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    mutableExtensionsDir = false;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        continue.continue # AI chat, inline edits, completion (Cursor-like)
        jnoortheen.nix-ide
        ms-pyright.pyright
        ms-toolsai.jupyter
        eamodio.gitlens
        mhutchie.git-graph
        github.vscode-pull-request-github
        redhat.vscode-yaml
        timonwong.shellcheck
        streetsidesoftware.code-spell-checker
        njpwerner.autodocstring
        usernamehw.errorlens
        oderwat.indent-rainbow
      ];

      userSettings = {
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
        "nix.enableLanguageServer" = true;
        "nix.formatterPath" = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";

        "terminal.integrated.defaultProfile.${terminalPlatform}" = "zsh";
        "terminal.integrated.profiles.${terminalPlatform}" = {
          "zsh" = {
            "path" = "${pkgs.zsh}/bin/zsh";
          };
        };

        "python.defaultInterpreterPath" = "${pkgs.python313}/bin/python";
        "python.formatting.provider" = "black";
        "python.formatting.blackPath" = "${pkgs.black}/bin/black";
        "python.linting.enabled" = true;
        "python.linting.ruffEnabled" = true;
        "python.linting.ruffPath" = "${pkgs.ruff}/bin/ruff";
        "python.testing.pytestEnabled" = true;

        "pyright.disableLanguageServices" = false;
        "pyright.disableOrganizeImports" = true;

        "jupyter.jupyterServerType" = "local";

        "yaml.schemas" = {
          "https://json.schemastore.org/github-workflow.json" = ".github/workflows/*.yaml";
        };

        "git.autofetch" = false;

        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.organizeImports" = "explicit";
        };
        "editor.rulers" = [ 79 ];
        "editor.renderWhitespace" = "selection";

        "errorLens.enabled" = true;
        "indentRainbow.enabled" = true;
        "cSpell.language" = "en-US";
      };
    };
  };
}
