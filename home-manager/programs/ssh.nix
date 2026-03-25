{ pkgs, config, ... }:
let
  agentSock =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else
      "~/.1password/agent.sock";

  inclusiveBlocksDir = "~/Projects/InclusiveBlocks";
  raspberryPiDir = "~/Projects/RaspberryPi";

  # Public key for homelab (rpi4-*, nuc). Prevents "Too many authentication failures"
  # when 1Password agent offers many keys; Pi has MaxAuthTries=3.
  # Download from 1Password SSH item if needed; default matches git.nix.
  homelabIdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
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
        user = "alice";
        port = 2222;
        extraOptions = {
          UserKnownHostsFile = "${inclusiveBlocksDir}/nuc/known_hosts";
          IdentityFile = homelabIdentityFile;
          IdentitiesOnly = "yes";
        };
      };

      # rpi4-01: Tailscale (rpi4-01), port 2222. 1Password (sasha@alice). BatchMode for nix when Pi is down.
      "rpi4-01" = {
        hostname = "rpi4-01";
        user = "rpi4-01";
        port = 2222;
        extraOptions = {
          UserKnownHostsFile = "${raspberryPiDir}/hosts/rpi4-01/known_hosts";
          ConnectTimeout = "10";
          BatchMode = "yes";
          IdentityFile = homelabIdentityFile;
          IdentitiesOnly = "yes";
        };
      };
      # rpi4-02: via rpi4-01 (ProxyJump) when alice off-LAN. rpi4-01 reachable via Tailscale.
      "rpi4-02" = {
        hostname = "10.0.0.3";
        user = "rpi4-02";
        port = 2222;
        proxyJump = "rpi4-01";
        extraOptions = {
          UserKnownHostsFile = "${raspberryPiDir}/hosts/rpi4-02/known_hosts";
          ConnectTimeout = "10";
          BatchMode = "yes";
          IdentityFile = homelabIdentityFile;
          IdentitiesOnly = "yes";
        };
      };
      # rpi4-02-direct: no ProxyJump. Use when alice is on LAN (can reach 10.0.0.3).
      "rpi4-02-direct" = {
        hostname = "10.0.0.3";
        user = "rpi4-02";
        port = 2222;
        extraOptions = {
          UserKnownHostsFile = "${raspberryPiDir}/hosts/rpi4-02/known_hosts";
          ConnectTimeout = "10";
          BatchMode = "yes";
          IdentityFile = homelabIdentityFile;
          IdentitiesOnly = "yes";
        };
      };
    };
  };
}
