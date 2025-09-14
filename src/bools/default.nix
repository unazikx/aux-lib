lib: {
  into = {
    /**
      Convert a boolean value into a string.
    */
    string = value: if value then "true" else "false";

    /**
      Convert a boolean into the string "yes" or "no".
    */
    yesno = value: if value then "yes" else "no";
  };

  /**
    Choose between two values based on a condition. When true, the first value
    is returned, otherwise the second value is returned.

    # Type

    ```
    when :: Bool -> a -> b -> a | b
    ```
  */
  when =
    condition: x: y:
    if condition then x else y;

  /**
    Perform a logical AND operation on two values.
  */
  and = a: b: a && b;

  /**
    Perform a logical AND operation on two functions being applied to a value.

    # Type

    ```
    and :: (a -> Bool) -> (a -> Bool) -> a -> Bool
    ```
  */
  and' = f: g: (x: (f x) && (g x));

  /**
    Perform a logical OR operation on two values.
  */
  or = a: b: a || b;

  /**
    Perform a logical OR operation on two functions being applied to a value.

    # Type

    ```
    or' :: (a -> Bool) -> (a -> Bool) -> a -> Bool
    ```
  */
  or' = f: g: (x: (f x) || (g x));

  /**
    Perform a logical NOT operation on two values.
  */
  not = a: !a;
}
