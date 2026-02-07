let
  aux_lib = import ./../default.nix;
  nixpkgs_lib_path = (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/tags/25.05.tar.gz") + "/lib";
  nixpkgs_lib = import nixpkgs_lib_path;
  aux_nixpkgs_lib = aux_lib.nixpkgs;
  tests = lib: {
    "concatStrings" = {
      "concatenate zero strings" =
        let
          expected = "";
          actual = lib.strings.concatStrings [];
        in
        actual == expected;
      "concatenate one string" =
        let
          expected = "foo";
          actual = lib.strings.concatStrings ["foo"];
        in
        actual == expected;
      "concatenate two strings" =
        let
          expected = "foobar";
          actual = lib.strings.concatStrings ["foo" "bar"];
        in
        actual == expected;
    };
    "concatMapStrings" = {
      "idenity map zero strings" =
        let
          expected = "";
          actual = lib.strings.concatMapStrings (x: x) [];
        in
        actual == expected;
      "idenity map one string" =
        let
          expected = "foo";
          actual = lib.strings.concatMapStrings (x: x) ["foo"];
        in
        actual == expected;
      "idenity map two strings" =
        let
          expected = "foobar";
          actual = lib.strings.concatMapStrings (x: x) ["foo" "bar"];
        in
        actual == expected;
      "map zero strings" =
        let
          expected = "";
          actual = lib.strings.concatMapStrings (x: "hi " + x) []; 
        in
        actual == expected;
      "map one string" =
        let
          expected = "hi foo";
          actual = lib.strings.concatMapStrings (x: "hi " + x) ["foo"]; 
        in
        actual == expected;
      "map two strings" =
        let
          expected = "hi foohi bar";
          actual = lib.strings.concatMapStrings (x: "hi " + x) ["foo" "bar"]; 
        in
        actual == expected;
    };
    "concatImapStrings" = {
      "map zero strings" =
        let
          expected = "";
          actual = lib.strings.concatImapStrings (i: x: x) [];
        in
        actual == expected;
      "map one string" =
        let
          expected = "1foo";
          actual = lib.strings.concatImapStrings (i: x: (builtins.toString i) + x) ["foo"];
        in
        actual == expected;
      "map two strings" =
        let
          expected = "1foo2bar";
          actual = lib.strings.concatImapStrings (i: x: (builtins.toString i) + x) ["foo" "bar"];
        in
        actual == expected;
    };
    "intersperse" = {
      "zero length list" =
        let
          expected = [];
          actual = lib.strings.intersperse "foo" [];
        in
        actual == expected;
      "one length list" =
        let
          expected = ["bar"];
          actual = lib.strings.intersperse "foo" ["bar"];
        in
        actual == expected;
      "two length list" =
        let
          expected = ["bar" "foo" "baz"];
          actual = lib.strings.intersperse "foo" ["bar" "baz"];
        in
        actual == expected;
    };
    "concatStringsSep" = {
      "zero length list" =
        let
          expected = "";
          actual = lib.strings.concatStringsSep "foo" [];
        in
        actual == expected;
      "one length list" =
        let
          expected = "bar";
          actual = lib.strings.concatStringsSep "foo" ["bar"];
        in
        actual == expected;
      "two length list" =
        let
          expected = "barfoobaz";
          actual = lib.strings.concatStringsSep "foo" ["bar" "baz"];
        in
        actual == expected;
    };
  };
in {
    "nixpkgs_tests" = (tests nixpkgs_lib);
    "aux_nixkpgs_tests" = (tests aux_nixpkgs_lib);
}
