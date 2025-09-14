lib: {
  /**
    Import a JSON file as a Nix value.

    # Type

    ```
    json :: Path -> Any
    ```
  */
  json = file: builtins.fromJSON (builtins.readFile file);

  /**
    Import a TOML file as a Nix value.

    # Type

    ```
    json :: Path -> Any
    ```
  */
  toml = file: builtins.fromTOML (builtins.readFile file);
}
