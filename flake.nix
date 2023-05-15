{
  description = "shell configuration";

  inputs = { };

  outputs = { self }: { nixosModules.shell = import ./config.nix; };
}
