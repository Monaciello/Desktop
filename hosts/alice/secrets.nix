{config, ...}: {
  sops = {
    defaultSopsFile = ../../secrets/alice.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    secrets = {};
  };
}
