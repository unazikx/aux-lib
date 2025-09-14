lib: {
  /**
    Return the smaller of two numbers.

    # Type

    ```
    min :: Int -> Int -> Int
    ```
  */
  min = x: y: if x < y then x else y;

  /**
    Return the larger of two numbers.

    # Type

    ```
    max :: Int -> Int -> Int
    ```
  */
  max = x: y: if x > y then x else y;
}
