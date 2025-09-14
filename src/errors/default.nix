lib: {
  /**
    Prints a message if the condition is not met. The result of
    the condition is returned.

    # Type

    ```
    trace :: Bool -> String -> Bool
    ```
  */
  trace = condition: message: if condition then true else builtins.trace message false;
}
