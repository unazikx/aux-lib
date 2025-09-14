lib: {
  merge = {
    /**
      Merge a list of option definitions into a single value.

      # Type

      ```
      default :: Location -> [Definition] -> Any
      ```
    */
    default =
      location: definitions:
      let
        values = lib.options.getDefinitionValues definitions;
        first = builtins.elemAt values 0;
        mergedFunctions = x: lib.options.mergeDefault location (builtins.map (f: f x) values);
        mergedLists = builtins.concatLists values;
        mergedAttrs = builtins.foldl' lib.attrs.merge { } values;
        mergedBools = builtins.any lib.bools.or false values;
        mergedStrings = lib.strings.concat values;
      in
      if builtins.length values == 1 then
        builtins.elemAt values 0
      else if builtins.all builtins.isFunction values then
        mergedFunctions
      else if builtins.all builtins.isList values then
        mergedLists
      else if builtins.all builtins.isAttrs values then
        mergedAttrs
      else if builtins.all builtins.isBool values then
        mergedBools
      else if builtins.all lib.strings.isString values then
        mergedStrings
      else if builtins.all builtins.isInt values && builtins.all (x: x == first) values then
        first
      # TODO: Improve this error message to show the location and definitions for the option.
      else
        builtins.throw "Cannot merge definitions.";

    /**
      Merge multiple option definitions together.

      # Type

      ```
      definitions :: Location -> Type -> [Definition]
      ```
    */
    definitions =
      location: type: definitions:
      let
        identifier = lib.options.getIdentifier location;
        resolve =
          definition:
          let
            properties = builtins.addErrorContext "while evaluating definitions from `${definition.__file__ or "<unknown>"}`:" (
              lib.modules.apply.properties definition.value
            );
            normalize = value: {
              __file__ = definition.__file__ or "<unknown>";
              inherit value;
            };
          in
          builtins.map normalize properties;

        resolved = builtins.concatMap resolve definitions;
        overridden = lib.modules.apply.overrides resolved;

        values =
          if builtins.any (definition: lib.types.is "order" definition.value) overridden.values then
            lib.modules.apply.order overridden.values
          else
            overridden.values;

        isDefined = values != [ ];

        invalid = builtins.filter (definition: !(type.check definition.value)) values;

        merged =
          if isDefined then
            if builtins.all (definition: type.check definition.value) values then
              type.merge location values
            else
              builtins.throw "A definition for `${identifier}` is not of type `${type.description}`. Definition values:${lib.options.getDefinitions invalid}"
          else
            builtins.throw "The option `${identifier}` is used but not defined.";

        optional = if isDefined then { value = merged; } else { };
      in
      {
        inherit
          isDefined
          values
          merged
          optional
          ;

        raw = {
          inherit values;
          inherit (overridden) highestPriority;
        };
      };

    /**
      Merge multiple option declarations together.

      # Type

      ```
      declarations :: Location -> [Option]
      ```
    */
    declarations =
      location: options:
      let
        merge =
          result: option:
          let
            mergedType = result.type.mergeType option.options.type.functor;
            isTypeMergeable = mergedType != null;
            shared = name: option.options ? ${name} && result ? ${name};
            typeSet = lib.attrs.when ((shared "type") && isTypeMergeable) { type = mergedType; };
            files = result.declarations;
            serializedFiles = builtins.concatStringsSep " and " files;
            typeSubmodules = option.options.type.submodules or null;
            submodules =
              if typeSubmodules != null then
                builtins.map (module: {
                  __file__ = option.__file__;
                  includes = [ module ];
                }) typeSubmodules
                ++ result.options
              else
                result.options;
            getPriority =
              value: if lib.types.is "override" value then value.priority else lib.modules.DEFAULT_PRIORITY;
            higherPriority = value1: value2: (getPriority value1) < (getPriority value2);
            mergeProperty =
              name:
              if (higherPriority result.${name} option.options.${name}) then
                result.${name}
              else if (higherPriority option.options.${name} result.${name}) then
                option.options.${name}
              else if result.${name} == option.options.${name} then
                result.${name} # This is mostly so any defaults/etc. get merged cleanly
              else
                builtins.throw "The option `${lib.options.getIdentifier location}` in `${option.__file__}` is already declared in ${serializedFiles}, but their ${name} values could not be merged. Please set one as a higher priority (e.g. using `${name} = lib.modules.overrides.force <value>`) or remove a definition";
          in
          if shared "type" && !isTypeMergeable then
            builtins.throw "The option `${lib.options.getIdentifier location}` in `${option.__file__}` is already declared in ${serializedFiles} but its type is not mergeable. Please remove a definition"
          else
            option.options
            // result
            // {
              declarations = result.declarations ++ [ option.__file__ ];
              options = submodules;
            }
            // (if shared "default" then { default = mergeProperty "default"; } else { })
            // (if shared "example" then { example = mergeProperty "example"; } else { })
            // (if shared "description" then { description = mergeProperty "description"; } else { })
            // (if shared "apply" then { apply = mergeProperty "apply"; } else { })
            // typeSet;
      in
      builtins.foldl' merge {
        inherit location;
        declarations = [ ];
        options = [ ];
      } options;

    /**
      Merge an option, only supporting a single unique definition.

      # Type

      ```
      unique :: String -> Location -> [Definition] -> Any
      ```
    */
    unique =
      message: location: definitions:
      let
        identifier = lib.options.getIdentifier location;
        total = builtins.length definitions;
        first = builtins.elemAt definitions 0;
      in
      if total == 1 then
        first.value
      else if total == 0 then
        builtins.throw "Cannot merge unused option `${identifier}`.\n${message}"
      else
        builtins.throw "The option `${identifier}` is defined multiple times, but must be unique.\n${message}\nDefinitions:${lib.options.getDefinitions definitions}";

    /**
      Merge a single instance of an option.

      # Type

      ```
      one :: Location -> [Definition] -> Any
      ```
    */
    one = lib.options.merge.unique "";

    equal =
      location: definitions:
      let
        identifier = lib.options.getIdentifier location;
        first = builtins.elemAt definitions 0;
        rest = builtins.tail definitions;
        merge =
          x: y:
          if x != y then
            builtins.throw "The option `${identifier}` has conflicting definitions:${lib.options.getDefinitions definitions}"
          else
            x;
        merged = builtins.foldl' merge first rest;
      in
      if builtins.length definitions == 0 then
        builtins.throw "Cannot merge unused option `${identifier}`."
      else if builtins.length definitions == 1 then
        first.value
      else
        merged.value;
  };

  /**
    Check whether a value is an option.

    # Type

    ```
    is :: Attrs -> Bool
    ```
  */
  is = lib.types.is "option";

  /**
    Create an option.

    # Type

    ```
    create :: { type? :: String | Null, apply? :: (a -> b) | Null, default? :: { value :: a, text :: String }, example? :: String | Null, visible? :: Bool | Null, internal? :: Book | Null, writable? :: Bool | Null, description? :: String | Null } -> Option a
    ```
  */
  create =
    settings@{
      type ? lib.types.unspecified,
      apply ? lib.modules.overrides.default null,
      default ? lib.modules.overrides.default { },
      example ? lib.modules.overrides.default null,
      visible ? null,
      internal ? null,
      writable ? null,
      description ? lib.modules.overrides.default null,
    }:
    {
      __type__ = "option";
      inherit
        type
        apply
        default
        example
        visible
        internal
        writable
        description
        ;
    };

  /**
    Create a sink option.

    # Type

    ```
    sink :: { type? :: String | Null, apply? :: (a -> b) | Null, default? :: { value :: a, text :: String }, example? :: String | Null, visible? :: Bool | Null, internal? :: Book | Null, writable? :: Bool | Null, description? :: String | Null } -> Option a
    ```
  */
  sink =
    settings:
    let
      defaults = {
        internal = true;
        visible = false;
        default = false;
        description = "A sink option for unused definitions";
        type = lib.types.create {
          name = "sink";
          check = lib.fp.const true;
          merge = lib.fp.const (lib.fp.const false);
        };
        apply = value: builtins.throw "Cannot read the value of a Sink option.";
      };
    in
    lib.options.create (defaults // settings);

  /**
    Get the definition values form a list of options definitions.

    # Type

    ```
    getDefinitionValues :: [Definition] -> Any
    ```
  */
  getDefinitionValues = definitions: builtins.map (definition: definition.value) definitions;

  /**
    Convert a list of option identifiers into a single identifier.

    # Type

    ```
    getIdentifier :: [String] -> String
    ```
  */
  getIdentifier =
    location:
    let
      special = [
        # lib.types.attrs.of (lib.types.submodule {})
        "<name>"
        # lib.types.list.of (submodule {})
        "*"
        # lib.types.function
        "<function body>"
      ];
      escape = part: if builtins.elem part special then part else lib.strings.escape.nix.identifier part;
    in
    lib.strings.concatMapSep "." escape location;

  /**
    Get a string message of the definitions for an option.

    # Type

    ```
    getDefinitions :: [Definition] -> String
    ```
  */
  getDefinitions =
    definitions:
    let
      serialize =
        definition:
        let
          valueWithRecursionLimit = lib.generators.withRecursion {
            limit = 10;
            throw = false;
          } definition.value;

          eval = builtins.tryEval (lib.generators.pretty { } valueWithRecursionLimit);

          lines = lib.strings.split "\n" eval.value;
          linesLength = builtins.length lines;
          firstFiveLines = lib.lists.take 5 lines;

          ellipsis = lib.lists.when (linesLength > 5) "...";

          value = builtins.concatStringsSep "\n    " (firstFiveLines ++ ellipsis);

          result =
            if !eval.success then
              ""
            else if linesLength > 1 then
              ":\n    " + value
            else
              ": " + value;
        in
        "\n- In `${definition.__file__}`${result}";
    in
    lib.strings.concatMap serialize definitions;

  /**
    Run a set of definitions, calculating the resolved value and associated information.

    # Type

    ```
    getDefinitions :: Location -> Option -> [Definition] -> String & { value :: Any, highestPriority :: Int, isDefined :: Bool, files :: List String, definitions :: [Any], definitionsWithLocations :: [Definition] }
    ```
  */
  run =
    location: option: definitions:
    let
      identifier = lib.options.getIdentifier location;

      definitionsWithDefault =
        if option ? default && option.default ? value then
          [
            {
              __file__ = builtins.head option.declarations;
              value = lib.modules.overrides.option option.default.value;
            }
          ]
          ++ definitions
        else
          definitions;

      merged =
        if option.writable or null == false && builtins.length definitionsWithDefault > 1 then
          let
            separatedDefinitions = builtins.map (
              definition:
              definition
              // {
                value = (lib.options.merge.definitions location option.type [ definition ]).merged;
              }
            ) definitionsWithDefault;
          in
          builtins.throw "The option `${identifier}` is not writable, but is set more than once:${lib.options.getDefinitions separatedDefinitions}"
        else
          lib.options.merge.definitions location option.type definitionsWithDefault;

      value = if option.apply or null != null then option.apply merged.merged else merged.merged;
    in
    option
    // {
      value = builtins.addErrorContext "while evaluating the option `${identifier}`:" value;
      highestPriority = merged.raw.highestPriority;
      isDefined = merged.isDefined;
      files = builtins.map (definition: definition.__file__) merged.values;
      definitions = lib.options.getDefinitionValues merged.values;
      definitionsWithLocations = merged.values;
      __toString = identifier;
    };
}
