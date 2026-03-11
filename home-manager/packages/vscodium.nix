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
      extensions = [
        pkgs.vscode-extensions.continue.continue
        pkgs.vscode-extensions.jnoortheen.nix-ide
        pkgs.vscode-extensions.ms-pyright.pyright
        pkgs.vscode-extensions.ms-toolsai.jupyter
        pkgs.vscode-extensions.eamodio.gitlens
        pkgs.vscode-extensions.mhutchie.git-graph
        pkgs.vscode-extensions.github.vscode-pull-request-github
        pkgs.vscode-extensions.redhat.vscode-yaml
        pkgs.vscode-extensions.timonwong.shellcheck
        pkgs.vscode-extensions.streetsidesoftware.code-spell-checker
        pkgs.vscode-extensions.njpwerner.autodocstring
        pkgs.vscode-extensions.usernamehw.errorlens
        pkgs.vscode-extensions.oderwat.indent-rainbow
      ];

      userSettings = {
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
        "nix.enableLanguageServer" = true;
        "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";

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
