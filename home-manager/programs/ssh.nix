# SSH configuration — wires 1Password SSH agent for key management
#
# The sasha key (used for OCI, git signing, etc.) lives in 1Password.
# This module ensures all SSH sessions use the 1Password agent socket.
{ pkgs, ... }:
let
  agentSock =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else
      "~/.1password/agent.sock";
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        extraOptions = {
          IdentityAgent = agentSock;
        };
      };

      "oci-claw" = {
        hostname = "";
        user = "sasha";
        port = 2222;
      };

      "rpi4-01" = {
        hostname = "rpi4-01";
        user = "sasha";
        port = 2222;
      };
    };
  };
}
