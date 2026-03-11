{ pkgs, ... }:
let
  agentSock =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else
      "~/.1password/agent.sock";

  inclusiveBlocksDir = "~/Projects/InclusiveBlocks";
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
        extraOptions = {
          IdentityAgent = agentSock;
          ConnectTimeout = "10";
        };
      };

      "oci-claw" = {
        hostname = "placeholder.invalid";
        user = "sasha";
        port = 2222;
      };

      "nuc" = {
        hostname = "nuc";
        port = 2222;
        extraOptions = {
          UserKnownHostsFile = "${inclusiveBlocksDir}/nuc/known_hosts";
        };
      };

      "rpi4-01" = {
        hostname = "rpi4-01";
        user = "sasha";
        port = 2222;
        extraOptions = {
          UserKnownHostsFile = "${inclusiveBlocksDir}/rpi4-01/known_hosts";
        };
      };

      "rpi4-01-wan" = {
        hostname = "192.168.1.108";
        user = "sasha";
        port = 2222;
        extraOptions = {
          UserKnownHostsFile = "${inclusiveBlocksDir}/rpi4-01/known_hosts";
        };
      };
    };
  };
}