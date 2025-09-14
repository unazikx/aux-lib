lib: {
  /**
    A function that returns its argument.

    # Type

    ```
    id :: a -> a
    ```
  */
  id = x: x;

  /**
    A function that ignores its argument and returns a constant value.

    # Type

    ```
    const :: a -> b -> a
    ```
  */
  const = x: (_: x);

  /**
    Compose two functions to produce a new function that applies them both
    from right to left.

    # Type

    ```
    compose :: (b -> c) -> (a -> b) -> (a -> c)
    ```
  */
  compose = f: g: (x: f (g x));

  /**
    Process a value with a series of functions. Functions are applied in the
    order they are provided.

    # Type

    ```
    pipe :: [(Any -> Any)] -> Any -> Any
    ```
  */
  pipe = fs: (x: builtins.foldl' (value: f: f value) x fs);

  /**
    Reverse the order of arguments to a function that has two parameters.

    # Type

    ```
    flip2 :: (a -> b -> c) -> (b -> a -> c)
    ```
  */
  flip2 =
    f: a: b:
    f b a;
  /**
    Reverse the order of arguments to a function that has three parameters.

    # Type

    ```
    flip3 :: (a -> b -> c -> d) -> (c -> b -> a -> d)
    ```
  */
  flip3 =
    f: a: b: c:
    f c b a;
  /**
    Reverse the order of arguments to a function that has four parameters.

    # Type

    ```
    flip4 :: (a -> b -> c -> d -> e) -> (d -> c -> b -> a -> e)
    ```
  */
  flip4 =
    f: a: b: c: d:
    f d c b a;

  /**
    Get the arguments of a function or functor.
    An attribute set is returned with the arguments as keys. The values
    are `true` when the argument has a default value specified and `false`
    when it does not.

    # Type

    ```
    args :: Function -> Attrs
    ```
  */
  args =
    f: if f ? __functor then f.__args__ or (lib.fp.args (f.__functor f)) else builtins.functionArgs f;

  /**
    Create a function that is called with only the arguments it specifies.

    # Type

    ```
    withDynamicArgs :: (Attrs -> a) -> Attrs -> a
    ```
  */
  withDynamicArgs =
    f: args:
    let
      fArgs = lib.fp.args f;
      common = builtins.intersectAttrs fArgs args;
    in
    if builtins.isAttrs args then if fArgs == { } then f args else f common else f args;
}
