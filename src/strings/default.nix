lib: {
  into = {
    /**
      Convert a character to an integer.

      # Type

      ```
      int :: String -> Int
      ```
    */
    int = char: builtins.getAttr char lib.strings.ascii;

    /**
      Convert a string into a list of characters.

      # Type

      ```
      chars :: String -> [String]
      ```
    */
    chars =
      value:
      let
        range = lib.lists.range 0 (builtins.stringLength value - 1);
        pick = index: builtins.substring index 1 value;
      in
      builtins.map pick range;

    shell = {
      /**
        Convert a value into a shell variable.

        # Type

        ```
        var :: String -> Any -> String
        ```
      */
      var =
        name: target:
        let
          baseVar = "${name}=${lib.strings.escape.shell.arg target}";
          listVar = "declare -a ${name}=(${lib.strings.escape.shell.args target})";
          attrsVar = "declare -A ${name}=(${
            builtins.concatStringsSep " " (
              lib.attrs.mapToList (
                k: v: "[${lib.strings.escape.shell.arg k}]=${lib.strings.escape.shell.arg v}"
              ) target
            )
          })";
        in
        assert lib.errors.trace (lib.strings.validate.posix name) "Invalid shell variable name: ${name}";
        if builtins.isAttrs target && !lib.strings.validate.stringifiable target then
          attrsVar
        else if builtins.isList target then
          listVar
        else
          baseVar;

      /**
        Create shell variables from a map of values.

        # Type

        ```
        vars :: Attrs -> String
        ```
      */
      vars =
        target: builtins.concatStringsSep "\n" (lib.attrs.mapToList lib.strings.into.shell.var target);
    };
  };

  escape = {
    /**
      Escape parts of a string.

      # Type

      ```
      any :: [String] -> String -> String
      ```
    */
    any =
      patterns: source:
      let
        escaped = builtins.map (x: "\\${x}") patterns;
        replacer = builtins.replaceStrings patterns escaped;
      in
      replacer source;

    /**
      Escape a given set of characters in a string using their
      ASCII code prefixed with "\x".

      # Type

      ```
      c :: [String] -> String
      ```
    */
    c =
      list:
      let
        serialize =
          char:
          let
            hex = lib.numbers.into.hex (lib.strings.into.int char);
          in
          "\\x${lib.strings.lower hex}";
      in
      builtins.replaceStrings list (builtins.map serialize list);

    nix = {
      /**
        Escape a string of Nix code.

        # Type

        ```
        value :: String -> String
        ```
      */
      value = value: lib.strings.escape.any [ "$" ] (builtins.toJSON value);

      /**
        Escape a string for use as a Nix identifier.

        # Type

        ```
        identifier :: String -> String
        ```
      */
      identifier =
        value:
        if builtins.match "[a-zA-Z_][a-zA-Z0-9_'-]*" value != null then
          value
        else
          lib.strings.escape.nix.value value;
    };

    /**
      Escape a string for use in a regular expression.

      # Type

      ```
      regex :: String -> String
      ```
    */
    regex = lib.strings.escape.any (lib.strings.into.chars "\\[{()^$?*+|.");

    /**
      Escape a string for use in XML.

      # Type

      ```
      xml :: String -> String
      ```
    */
    xml =
      builtins.replaceStrings
        [
          "\""
          "'"
          "<"
          ">"
          "&"
        ]
        [
          "&quot;"
          "&apos;"
          "&lt;"
          "&gt;"
          "&amp;"
        ];

    shell = {
      /**
        Escape a string for use as a shell argument.

        # Type

        ```
        arg :: String -> String
        ```
      */
      arg = value: "'${builtins.replaceStrings [ "'" ] [ "'\\''" ] (builtins.toString value)}'";

      /**
        Escape multiple strings for use as shell arguments.

        # Type

        ```
        arg :: [String] -> String
        ```
      */
      args = lib.strings.concatMapSep " " lib.strings.escape.shell.arg;
    };
  };

  validate = {
    /**
      Check if a string is a valid POSIX identifier.

      # Type

      ```
      posix :: String -> Bool
      ```
    */
    posix = name: builtins.match "[a-zA-Z_][a-zA-Z0-9_]*" name != null;

    /**
      Check if a value can be used as a string.

      # Type

      ```
      stringifiable :: Any -> Bool
      ```
    */
    stringifiable =
      value: builtins.isString value || builtins.isPath value || value ? outPath || value ? __toString;

    /**
      Check whether a string is empty. This includes strings that
      only contain whitespace.

      # Type

      ```
      empty :: String -> Bool
      ```
    */
    empty = value: builtins.match "[ \t\n]*" value != null;
  };

  order = {
    /**
      Create an ordered string that will be placed anywhere.

      # Type

      ```
      anywhere :: String -> OrderedString
      ```
    */
    anywhere = value: {
      inherit value;
      deps = [ ];
    };

    /**
      Create an ordered string that will be placed anywhere.

      # Type

      ```
      after :: String -> [String] -> OrderedString
      ```
    */
    after = deps: value: { inherit deps value; };

    /**
      Apply the order for a list of ordered strings. This function also supports
      plain strings in the list so long as they have an accompanying static definition
      provided.

      # Type

      ```
      apply :: Attrs -> [OrderedString | String]
      ```
    */
    apply =
      static: items:
      let
        process =
          complete: remaining:
          let
            next = builtins.head remaining;

            before = process complete next.deps;
            after = process before.complete (builtins.tail remaining);
          in
          if builtins.length remaining == 0 then
            {
              inherit complete;
              result = [ ];
            }
          else if builtins.isAttrs next then
            {
              inherit complete;
              result = before.result ++ [ next.value ] ++ after.result;
            }
          else
            process (complete // { "${next}" = true; }) ([ static.${next} ] ++ builtins.tail remaining);

        processed = process { } items;
      in
      processed.result;
  };

  /**
    Return a given string if a condition is true, otherwise return
    an empty string.

    # Type

    ```
    when :: Bool -> String -> String
    ```
  */
  when = condition: value: if condition then value else "";

  /**
    A table of ASCII characters mapped to their integer character code.

    # Type

    ```
        ascii :: Attrs
    ```
  */
  ascii = import ./ascii.nix;

  /**
    Lists of both upper and lower case ASCII characters.

    # Type

    ```
    alphabet :: { upper :: [String], lower :: [String] }
    ```
  */
  alphabet = import ./alphabet.nix;

  /**
    Concatenate a list of strings together.

    # Type

    ```
    concat :: [String] -> String
    ```
  */
  concat = builtins.concatStringsSep "";

  /**
    Concatenate and map a list of strings together.

    # Type

    ```
    concatMap :: [String] -> String
    ```
  */
  concatMap = lib.strings.concatMapSep "";

  /**
    Concatenate and map a list of strings together with a separator.

    # Type

    ```
    concatMapSep :: String -> (a -> String) -> [a] -> String
    ```
  */
  concatMapSep =
    separator: f: list:
    builtins.concatStringsSep separator (builtins.map f list);

  /**
    Change a string to uppercase.

    # Type

    ```
    upper :: String -> String
    ```
  */
  upper = builtins.replaceStrings lib.strings.alphabet.lower lib.strings.alphabet.upper;

  /**
    Change a string to lowercase.

    # Type

    ```
    lower :: String -> String
    ```
  */
  lower = builtins.replaceStrings lib.strings.alphabet.upper lib.strings.alphabet.lower;

  /**
    Add the context of one string to another.

    # Type

    ```
    withContext :: String -> String -> String
    ```
  */
  withContext = context: value: builtins.substring 0 0 context + value;

  /**
    Split a string by a separator.

    # Type

    ```
    split :: String -> String -> [String]
    ```
  */
  split =
    separator: value:
    let
      escaped = lib.strings.escape.regex (builtins.toString separator);
      raw = builtins.split escaped (builtins.toString value);
      parts = builtins.filter builtins.isString raw;
    in
    builtins.map (lib.strings.withContext value) parts;

  /**
    Check if a string starts with a given prefix.

    # Type

    ```
    hasPrefix :: String -> String -> Bool
    ```
  */
  hasPrefix =
    prefix: value:
    let
      text = builtins.substring 0 (builtins.stringLength prefix) value;
    in
    text == prefix;

  /**
    Check if a string ends with a given suffix.

    # Type

    ```
    hasSuffix :: String -> String -> Bool
    ```
  */
  hasSuffix =
    suffix: value:
    let
      valueLength = builtins.stringLength value;
      suffixLength = builtins.stringLength suffix;
      text = builtins.substring (valueLength - suffixLength) valueLength value;
    in
    (valueLength >= suffixLength) && text == suffix;

  /**
    Check if a string contains a given infix.

    # Type

    ```
    hasInfix :: String -> String -> Bool
    ```
  */
  hasInfix = infix: value: builtins.match ".*${lib.strings.escape.regex infix}.*" "${value}" != null;

  /**
    Remove a prefix from a string if it exists.

    # Type

    ```
    removePrefix :: String -> String -> String
    ```
  */
  removePrefix =
    prefix: value:
    let
      prefixLength = builtins.stringLength prefix;
      valueLength = builtins.stringLength value;
    in
    if lib.strings.hasPrefix prefix value then
      builtins.substring prefixLength (valueLength - prefixLength) value
    else
      value;

  /**
    Remove a suffix from a string if it exists.

    # Type

    ```
    removeSuffix :: String -> String -> String
    ```
  */
  removeSuffix =
    suffix: value:
    let
      suffixLength = builtins.stringLength suffix;
      valueLength = builtins.stringLength value;
    in
    if lib.strings.hasSuffix suffix value then
      builtins.substring 0 (valueLength - suffixLength) value
    else
      value;

  /**
    Pad the start of a string with a character until it reaches
    a given length.

    # Type

    ```
    padStart :: Int -> String -> String
    ```
  */
  padStart =
    length: char: value:
    let
      valueLength = builtins.stringLength value;
      padding = builtins.genList (_: char) (length - valueLength);
    in
    if valueLength < length then (builtins.concatStringsSep "" padding) + value else value;

  /**
    Pad the end of a string with a character until it reaches
    a given length.

    # Type

    ```
    padEnd :: Int -> String -> String
    ```
  */
  padEnd =
    length: char: value:
    let
      valueLength = builtins.stringLength value;
      padding = builtins.genList (_: char) (length - valueLength);
    in
    if valueLength < length then value + (builtins.concatStringsSep "" padding) else value;
}
