{
  description = "Aux Lib, a pure Nix library complete with a module system and extended type support.";

  outputs = _: { lib = import ./src; };
}
