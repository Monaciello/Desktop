{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # python313FreeThreading
    nixd
    shellcheck
    ruff
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    mutableExtensionsDir = false;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # NIX IDE LSP
        jnoortheen.nix-ide

        # Type Checking / Python installation
        ms-pyright.pyright

        # Jupyter Lan
        ms-toolsai.jupyter

        # Git / GitHub
        eamodio.gitlens
        mhutchie.git-graph
        github.vscode-pull-request-github

        # YAML + GitHub Actions
        redhat.vscode-yaml
        # if available in your channel: github.vscode-github-actions

        # Shell / tooling
        timonwong.shellcheck
        # plus any xonsh/bash/fish/zsh syntax extensions available in your channel

        # QoL
        streetsidesoftware.code-spell-checker
        njpwerner.autodocstring
        usernamehw.errorlens
        oderwat.indent-rainbow

      ];

      userSettings = {
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
        "nix.enableLanguageServer" = true;
        "nix.formatterPath" = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";

        # Use your preferred shell in the integrated terminal
        "terminal.integrated.defaultProfile.linux" = "xonsh";
        "terminal.integrated.profiles.linux" = {

          #"bash" = { "path" = "${pkgs.bash}/bin/bash"; };
          # "zsh"  = { "path" = "${pkgs.zsh}/bin/zsh"; };
          # "fish" = { "path" = "${pkgs.fish}/bin/fish"; };

          "xonsh" = {
            "path" = "${pkgs.xonsh}/bin/xonsh";
          };
        };

        # Python: use system Python, Black, Ruff
        "python.defaultInterpreterPath" = "${pkgs.python313}/bin/python";
        "python.formatting.provider" = "black";
        "python.formatting.blackPath" = "${pkgs.black}/bin/black";
        "python.linting.enabled" = true;
        "python.linting.ruffEnabled" = true;
        "python.linting.ruffPath" = "${pkgs.ruff}/bin/ruff";
        "python.testing.pytestEnabled" = true;

        # Pyright
        "pyright.disableLanguageServices" = false;
        "pyright.disableOrganizeImports" = true;

        # Jupyter
        "jupyter.jupyterServerType" = "local";

        # YAML + GitHub Actions
        "yaml.schemas" = {
          #"https://json.schemastore.org/github-workflow.json" = ".github/workflows/*.yml";
          "https://json.schemastore.org/github-workflow.json" = ".github/workflows/*.yaml";
        };

        # Git
        "git.autofetch" = true;

        # QoL
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
