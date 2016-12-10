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
		_glyphs as uinteger 		' Actual count of characters / glyphs.
	
	public:
		' Initalizes the VZString with empty data
		declare constructor()
		
		' Initalizes the VZString with the given zstring value
		declare constructor(value as zstring ptr)
		
		' Initalizes the VZString by making a copy of the given VZString
		declare constructor(value as vZString)
		
		declare destructor()
		
		declare operator +=(byref value as zstring)
		declare operator +=(value as vZstring)
		declare operator +=(byref value as string)
		declare operator cast() byref as zstring
		declare operator [](index as uinteger) as ubyte		
		
		declare property Size() as uinteger
		declare property Length() as uinteger
		
		' TODO
		declare function Mid(start as uinteger, lenght as uinteger) as vzstring 
		
		' TODO
		declare function Left(lenght as uinteger) as vzstring
		
		' TODO
		declare function Right(length as uinteger) as vzstring
		
		' TODO
		declare function Instr(start as uinteger = 0, expression as vzstring) as uinteger
		declare function Instr(start as uinteger = 0, byref expression as zstring) as uinteger
		
		' TODO
		declare function InstrRev(start as uinteger = 0, expression as vzstring) as uinteger
		declare function InstrRev(start as uinteger = 0, byref expression as zstring) as uinteger
		
		' TODO
		declare static function space(length as uinteger) as vzstring 
	private:
		declare function GetGlyphCount() as uinteger
end type

operator len(value as vzstring) as integer
	return value.Length
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

operator vZString.+=(byref value as zstring)
	if ( len(value) < this._bufferSize - this._length) then
		memcpy(this._buffer + this._length, @value, len(value))
		this._length += len(value)
	else
		this._buffersize += len(value)
		this._buffer = reallocate(this._buffer, this._buffersize)
		memcpy(this._buffer + this._length, @value, len(value))
		this._length += len(value)
	endif
	this._glyphs = 0 ' reset the char count
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
	this._glyphs = 0 ' reset the char count	
end operator

operator vZString.+=(byref value as string)
	if ( len(value) < this._bufferSize - this._length) then
		memcpy(this._buffer + this._length, @value, len(value))
		this._length += len(value)
	else
		this._buffersize += len(value)
		this._buffer = reallocate(this._buffer, this._buffersize)
		memcpy(this._buffer + this._length, @value, len(value))
		this._length += len(value)
	endif
	this._glyphs = 0 ' reset the char count
end operator

operator vzstring.[](index as uinteger) as ubyte
	return this._buffer[index]
end operator

operator vzstring.cast() byref as zstring
	return *this._buffer
end operator

property vzstring.Length() as uinteger
	if ( this._glyphs = 0) then
		this._glyphs = this.GetGlyphCount()
	end if
	return this._glyphs
end property

property vzstring.Size() as uinteger
	return this._length
end property

function vzstring.GetGlyphCount() as uinteger
	return CountGlyphs(this._buffer)
end function
