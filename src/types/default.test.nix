let
  lib = import ./../default.nix;
in
{
  "PortableSubmodule" = {
    "is portable" =
      let
        submodule =
          { config }:
          {
            options = {
              primitive = lib.options.create {
                type = lib.types.string;
                default.value = "<default>";
              };

              computed = lib.options.create {
                type = lib.types.string;
                default.value = "computed: ${config.primitive}";
              };
            };
          };

        option = lib.options.create {
          default.value = { };
          type = lib.types.submodules.portable {
            module = submodule;
          };
        };

        moduleA = {
          options.a = option;
        };
        moduleB =
          { config }:
          {
            options.b = option;

            config.b = config.a;
          };
        moduleC = {
          config.b.primitive = "custom";
        };

        result = lib.modules.run {
          modules = [
            moduleA
            moduleB
            moduleC
          ];
        };
      in
      result.config.b.computed == "computed: custom";
  };
}
