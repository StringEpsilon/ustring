Wrapper class for a variable length zstring

Goal is a variable length zstring (null terminated string) that can be used just like the regular string.

This implementation will allocate slightly more memory for each string than nescessary, to speed up some concatenations. You can modify this behavior
by adjusting the constants in the VZStringConstants namespace at the beginning of the file.

## API

```vzstring.Length``` 
is a property that returns the number of characters in the string. You can use len(myVzstring) to get the same value.

```vzstring.Size``` 
is a property that returns the number of bytes in use by the string data. The actual memory allocated might be slightly higher than that,
just like with regular FreeeBASIC strings.

```vzstring.+=```
can be used to add additional characters, like you'd with regular strings. The operator accepts strings, vzstrings, and zstrings,

```vzstring.Mid(start, length)```
Behaves like MID(string, start, length), but uses the vzstring character count.
Note: You can use the standard library MID() on vzstrings.

Example:
```
dim test as vstring = "I ♥ FreeBASIC" ' the heart symbol is 3 codepoints long.
print test.Mid(3,1) ' ♥
print MID(test, 3, 3) ' ♥
```

```vzstring.Left(length)```
Behaves like LEFT(string, length), but uses the vzstring character count.
Note: You can not use the standard library LEFT() on vzstrings, until some bugs in the runtime are fixed.

Example:
```
dim test as vstring = "I ♥ FreeBASIC" ' the heart symbol is 3 codepoints long.
print test.Left(3) '>I ♥<
```


```vzstring.Right(length)```
Behaves like RIGHT(string, length), but uses the vzstring character count.
Note: You can not use the standard library RIGHT() on vzstrings, until some bugs in the runtime are fixed.


```vzstring.Char(index) as vzstring```
returns the character at the given index or zero length vzstring. This is zero indexed
and based on the internal character counting.

Example:
```
dim test as vstring = "I ♥ FreeBASIC"
print test.char(2) ' "♥"

```
