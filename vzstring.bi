/'	
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at http://mozilla.org/MPL/2.0/. 
'/

#include once "crt.bi"

namespace VZStringConstants

const ChunkSize = 8

end namespace

function GetCodepointLength(codepoint as ubyte) as ubyte
	if codePoint <= &h7F then
		return 1
	else
		if ( codePoint shr 5 ) = &b110 then
			return 2
		elseif ( codePoint shr 4 ) = &b1110 then
			return 3
		elseif  ( codePoint shr 3 ) = &b11110 then
			return 4
		end if
	end if
end function

function CountGlyphs(utf8string as ubyte ptr) as uinteger
	dim glyphCount as uinteger
	dim codePoint as ubyte
	do
		codePoint = peek(ubyte, utf8string)
		utf8string += GetCodepointLength(codePoint)
		glyphCount += 1
	loop until codepoint = 0 
	glyphCount -= 1 'subtract the NUL byte.
	return glyphCount
end function


using VZStringConstants

type VZString 
	'private:
		_buffer as zstring ptr
		_length as uinteger 		' The length, in bytes, of the string data.
		_bufferSize as uinteger 	' The current size of the data buffer.
	
	public:
		' Initalizes the VZString with empty data
		declare constructor()
		
		' Initalizes the VZString with the given zstring value
		declare constructor(value as zstring ptr)
		
		' Initalizes the VZString by making a copy of the given VZString
		declare constructor(value as vZString)
		
		' Clean up:
		declare destructor()
		
		declare operator +=(value as zstring ptr)
		declare operator +=(value as vZstring)
		
		declare operator cast() byref as zstring
		
		declare operator [](index as uinteger) as ubyte		
		
		' Functions
		declare function GetGlyphCount() as uinteger
		
end type

operator len(value as vzstring) as integer
	return value.GetGlyphCount
end operator

destructor VZString()
	deallocate(this._buffer)
end destructor

constructor VZString()
	this._buffer = allocate(ChunkSize)
	this._length = 0
	this._bufferSize = 32
end constructor

constructor VZString(value as zstring ptr)
	this._length = len(*value)
	this._bufferSize = (int( this._length / ChunkSize )+2) * ChunkSize
	this._buffer = allocate(this._bufferSize)
	memcpy( this._buffer, value, this._length )
end constructor

constructor VZString(value as vzstring)
	this._length = value._length
	this._bufferSize = value._bufferSize
	this._buffer = allocate(this._bufferSize)
	memcpy( this._buffer, value._buffer, this._bufferSize )
end constructor

operator vZString.+=(value as zstring ptr)
	if ( len(*value) < this._bufferSize - this._length) then
		memcpy(this._buffer + this._length, value, len(*value))
		this._length += len(*value)
	else
		this._buffersize += len(*value)
		this._buffer = reallocate(this._buffer, this._buffersize)
		memcpy(this._buffer + this._length, value, len(value))
		this._length += len(*value)
	endif	
end operator

operator vZString.+=(value as vzstring)
	if ( value._buffersize < this._bufferSize - this._length) then
		memcpy(this._buffer + this._length, value._buffer, value._length)
		this._length += value._length
	else
		this._buffersize += value._buffersize - chunksize
		this._buffer = reallocate(this._buffer, this._buffersize)
		memcpy(this._buffer + this._length, value._buffer, value._length)
		this._length += value._length
	endif	
end operator

operator vzstring.[](index as uinteger) as ubyte
	return this._buffer[index]
end operator

operator vzstring.cast() byref as zstring
	return *this._buffer
end operator

function vzstring.GetGlyphCount() as uinteger
	return CountGlyphs(this._buffer)
end function
