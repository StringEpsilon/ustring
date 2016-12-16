Wrapper class for a variable length zstring

This implementation will allocate slightly more memory for each string than nescessary, to speed up some concatenations. You can modify this behavior by adjusting the constants in the ustringConstants namespace at the beginning of the file.

## License:

MPL 2.0. 
* You can use, modify and distribute ustring as you please. You can even include it in proprietary projects.
* You if you distribute a binary of your project, you must also provide the source code file ustring.bi you used (copyleft).
* All other code in your project remains under your license.

See COPYING for more details.

## Current status:

Useable, but not all that useful as of now. Some functions are not implemented and I have not tested the performance. If you decide to use it now, prepare for some minor API changes in the future.
And please make use of the bug tracker.

## Goals:

* A variable length zstring, that behaves like a normal zstring.
* Validation of UTF-8 strings
* Correct character counting and sane string manipulation
* Decent performance. 

## Non-Goals:

* Rendering of any kind. Use pango for that.
* "Typographical manipulation", i.e. lcase and ucase, ltr- and rtl marks, ...
* 'Sane' support for combining characters
* Identification / categorization of codepoints and characters.

ustring is meant to be just a string, not the kitchensink solution to your Unicode problems. 

## API

    ustring.Length
is a property that returns the number of characters in the string. You can use len(myustring) to get the same value.

    ustring.Size 
is a property that returns the number of bytes in use by the string data. The actual memory allocated might be slightly higher than that,
just like with regular FreeeBASIC strings.

    ustring.+=
can be used to add additional characters, like you'd with regular strings. The operator accepts strings, ustrings, and zstrings,

    ustring.Mid(start, length)
Behaves like MID(string, start, length), but uses the ustring character count.
Note: You can use the standard library MID() on ustrings.

Example:
```
dim test as ustring = "I ♥ FreeBASIC" ' the heart symbol is 3 codepoints long.
print test.Mid(3,1) ' ♥
print MID(test, 3, 3) ' ♥
```

    ustring.Left(length)
Behaves like LEFT(string, length), but uses the ustring character count.
Note: You can not use the standard library LEFT() on ustrings, until some bugs in the runtime are fixed.

Example:
```
dim test as ustring = "I ♥ FreeBASIC" ' the heart symbol is 3 codepoints long.
print test.Left(3) '>I ♥<
```


    ustring.Right(length)
Behaves like RIGHT(string, length), but uses the ustring character count.
Note: You can not use the standard library RIGHT() on ustrings, until some bugs in the runtime are fixed.


    ustring.Char(index) as ustring
returns the character at the given index or zero length ustring. This is zero indexed
and based on the internal character counting.

Example:
```
dim test as ustring = "I ♥ FreeBASIC"
print test.char(2) ' "♥"
```
