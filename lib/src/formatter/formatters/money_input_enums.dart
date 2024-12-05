// ignore_for_file: type=lint, argument_type_not_assignable, return_of_invalid_type_from_closure, invalid_assignment
/*
(c) Copyright 2020 Serov Konstantin.

Licensed under the MIT license:

    http://www.opensource.org/licenses/mit-license.php

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

enum ShorteningPolicy {
  /// displays a value of 1234456789.34 as 1,234,456,789.34
  NoShortening,

  /// displays a value of 1234456789.34 as 1,234,456K
  RoundToThousands,

  /// displays a value of 1234456789.34 as 1,234M
  RoundToMillions,

  /// displays a value of 1234456789.34 as 1B
  RoundToBillions,
  RoundToTrillions,

  /// uses K, M, B, or T depending on how big the numeric value is
  Automatic
}

/// [Comma] means this format 1,000,000.00
/// [Period] means thousands and mantissa will look like this
/// 1.000.000,00
/// [None] no separator will be applied at all
/// [SpaceAndPeriodMantissa] 1 000 000.00
/// [SpaceAndCommaMantissa] 1 000 000,00
enum ThousandSeparator {
  Comma,
  Space,
  Period,
  None,
  SpaceAndPeriodMantissa,
  SpaceAndCommaMantissa,
}
