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
