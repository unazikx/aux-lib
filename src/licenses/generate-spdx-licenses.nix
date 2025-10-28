let
  lib = import ../../default.nix;

  jsonData = (builtins.readFile result/json/licenses.json |> builtins.fromJSON).licenses;

  padFrontIfNumber =
    x:
    lib.strings.when (builtins.elem (builtins.substring 0 1 x) (
      builtins.genList (x: builtins.toString x) 10
    )) "_"
    + x;

  mkAttrName =
    spdxID: lib.strings.lower spdxID |> builtins.replaceStrings [ "." ] [ "_" ] |> padFrontIfNumber;
in
''
  # THIS IS A GENERATED FILE. DO NOT EDIT!
  lib:
  {
''
+ (
  jsonData
  |> builtins.filter (x: !x.isDeprecatedLicenseId)
  |> map (x: ''
    /**
      ${x.name}
      see ${x.reference}
    */
    ${lib.strings.escape.nix.identifier (mkAttrName x.licenseId)} = lib.licenses.mkLicense {
      fullName = ${lib.strings.escape.nix.value x.name};
      spdxId = ${lib.strings.escape.nix.value x.licenseId};
    };
  '')
  |> builtins.concatStringsSep "\n"
)
+ "}"
