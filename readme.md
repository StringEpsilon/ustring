Wrapper class for a variable length zstring

Goal is a variable length zstring (null terminated string) that can be used just like the regular string.

This implementation will allocate slightly more memory for each string than nescessary, to speed up some concatenations. You can modify this behavior
by adjusting the constants in the VZStringConstants namespace at the beginning of the file.
