lib: {
  /**
    Concatenate a list of strings.

    # Type

    ```
    concatStrings :: [string] -> string
    ```

    # Examples
    :::{.example}
    ## `lib.strings.concatStrings` usage example

    ```nix
    concatStrings ["foo" "bar"]
    => "foobar"
    ```

    :::
  */
  concatStrings = lib.strings.concat;

  /**
    Map a function over a list and concatenate the resulting strings.

    # Inputs

    `f`
    : 1\. Function argument

    `list`
    : 2\. Function argument

    # Type

    ```
    concatMapStrings :: (a -> string) -> [a] -> string
    ```

    # Examples
    :::{.example}
    ## `lib.strings.concatMapStrings` usage example

    ```nix
    concatMapStrings (x: "a" + x) ["foo" "bar"]
    => "afooabar"
    ```

    :::
  */
  concatMapStrings = lib.strings.concatMap;

  /**
    Like `concatMapStrings` except that the f functions also gets the
    position as a parameter.

    # Inputs

    `f`
    : 1\. Function argument

    `list`
    : 2\. Function argument

    # Type

    ```
    concatImapStrings :: (int -> a -> string) -> [a] -> string
    ```

    # Examples
    :::{.example}
    ## `lib.strings.concatImapStrings` usage example

    ```nix
    concatImapStrings (pos: x: "${toString pos}-${x}") ["foo" "bar"]
    => "1-foo2-bar"
    ```

    :::
  */
  concatImapStrings = f: list: lib.strings.concat (lib.lists.mapWithIndex1 f list);

  /**
    Place an element between each element of a list

    # Inputs

    `separator`
    : Separator to add between elements

    `list`
    : Input list

    # Type

    ```
    intersperse :: a -> [a] -> [a]
    ```

    # Examples
    :::{.example}
    ## `lib.strings.intersperse` usage example

    ```nix
    intersperse "/" ["usr" "local" "bin"]
    => ["usr" "/" "local" "/" "bin"].
    ```

    :::
  */
  intersperse = lib.lists.intersperse;

  /**
    Concatenate a list of strings with a separator between each element

    # Inputs

    `sep`
    : Separator to add between elements

    `list`
    : List of input strings

    # Type

    ```
    concatStringsSep :: string -> [string] -> string
    ```

    # Examples
    :::{.example}
    ## `lib.strings.concatStringsSep` usage example

    ```nix
    concatStringsSep "/" ["usr" "local" "bin"]
    => "usr/local/bin"
    ```

    :::
  */
  concatStringsSep = sep: list: lib.strings.concat (lib.lists.intersperse sep list);
}# 
