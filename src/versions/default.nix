/**
  Version string functions.
*/
lib: {
  /**
    Check if a version is greather than another.

    # Example

    ```nix
    gt "1.2.3" "1.2.2"
    =>
    true
    ```

    # Type

    ```
    gt :: String -> String -> Bool
    ```
  */
  gt = first: second: builtins.compareVersions first second == -1;

  /**
    Check if a version is greater than or equal to another.

    # Example

    ```nix
    gte "1.2.3" "1.2.2"
    =>
    true
    ```

    # Type

    ```
    gte :: String -> String -> Bool
    ```
  */
  gte = first: second: builtins.compareVersions first second != 1;

  /**
    Check if a version is lesser than another.

    # Example

    ```nix
    lt "1.2.3" "1.2.2"
    =>
    false
    ```

    # Type

    ```
    lt :: String -> String -> Bool
    ```
  */
  lt = first: second: builtins.compareVersions first second == 1;

  /**
    Check if a version is lesser than or equal to another.

    # Example

    ```nix
    lte "1.2.3" "1.2.2"
    =>
    false
    ```

    # Type

    ```
    lte :: String -> String -> Bool
    ```
  */
  lte = first: second: builtins.compareVersions first second != -1;

  /**
    Checks if a version is equal to another.

    # Example

    ```nix
    eq "1.2.3" "1.2.2"
    =>
    false
    ```

    # Type

    ```
    eq :: String -> String -> Bool
    ```
  */
  eq = first: second: builtins.compareVersions first second == 0;

  /**
    Get the major version from a version string.

    # Example

    ```nix
    major "1.2.3"
    =>
    1
    ```

    # Type

    ```
    major :: String -> String
    ```
  */
  major =
    version:
    let
      parts = builtins.splitVersion version;
    in
    builtins.elemAt parts 0;

  /**
    Get the minor version from a version string.

    # Example

    ```nix
    minor "1.2.3"
    =>
    2
    ```

    # Type

    ```
    minor :: String -> String
    ```
  */
  minor =
    version:
    let
      parts = builtins.splitVersion version;
    in
    builtins.elemAt parts 1;
  /**
    Get the patch version from a version string.

    # Example

    ```nix
    patch "1.2.3"
    =>
    3
    ```

    # Type

    ```
    patch :: String -> String
    ```
  */
  patch =
    version:
    let
      parts = builtins.splitVersion version;
    in
    builtins.elemAt parts 2;
}
