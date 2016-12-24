/'	
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at http://mozilla.org/MPL/2.0/.
	
	(c) 2016 - StringEpsilon. 
'/

' TODOs:
' * Function to validate a UTF-8 string
' * 'DeescapeString" or something to actually use EscapedToUtf8()
' * Make EscapedToUtf8() more robust (actually check for \u and u+, etc. )

#include once "crt.bi"

namespace ustringConstants

	dim shared as ubyte charLenghtLookup(256) = _
		{ _
			1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, _
			1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, _
			1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, _
			1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, _
			1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, _
			1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, _
			2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, _
			3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3, 4,4,4,4,4,4,4,4,5,5,5,5,6,6,6,6 _
		}

	#define GetCodepointLength(codepoint) (ustringConstants.charLenghtLookup(codepoint))

	#ifndef NUL
	const NUL = 0
	#endif
	const ChunkSize = 8 ' TODO: Find a good chunk size. 
	const replacementChar as string  = "�"

end namespace

function CountCharacters(byval utf8string as string) as uinteger
	dim charCount as uinteger
	dim codePoint as ubyte
	for i as integer = 0 to len(utf8string) -1
		codePoint = utf8string[i]
		i += ( GetCodepointLength(codePoint) - 1)
		charCount += 1 
	next
	return charCount
end function


using ustringConstants

type ustring 
	' Private in the future. Don't use those.
	'private:
		_buffer as string
		_length as uinteger 		' The length, in bytes, of the string data.
		_characters as uinteger 	' Actual count of characters / glyphs.
		declare function CharToByte(byval index as uinteger) as long	
	public:
		' Initalizes the ustring with empty data
		declare constructor()
		
		' Initalizes the ustring with the given string value
		declare constructor(byval value as string)
		
		' Initalizes the ustring by making a copy of the given ustring
		declare constructor(byref value as ustring)
		
		declare destructor()
		
		declare operator +=(byref value as string)
		declare operator +=(byref value as ustring)
		'~ declare operator +=(byref value as string)
		declare operator cast() byref as string
		declare operator [](byval index as uinteger) as ustring
		
		declare operator let(byref value as string)
		
		declare property Size() as uinteger
		declare property Length() as uinteger
		
		' TODO
		'declare function Mid(byval start as uinteger, byval lenght as uinteger) as ustring 
		
		declare function Left(byval lenght as uinteger) as ustring
		declare function Right(byval length as uinteger) as ustring
		
		' TODO
		declare function Instr(byref expression as ustring, byval start as uinteger = 0) as long
		declare function Instr(byref expression as string, byval start as uinteger = 0) as long
		
		' TODO
		declare function InstrRev(byref xpression as ustring, byval start as uinteger = 0) as long
		declare function InstrRev(byref expression as string, byval start as uinteger = 0) as long
		
		' TODO
		declare static function space(byval length as uinteger) as ustring
end type

declare function EscapedToUtf8 overload (byval escapedPoint as string) as string
declare function EscapedToUtf8 (byref escapedPoint as ustring) as string

declare function left overload (byref value as ustring, byval length as uinteger) as ustring
declare function right overload (byref value as ustring, byval length as uinteger) as ustring

operator len(byref value as ustring) as integer
	return value.Length
end operator

operator &(byref value as ustring, byref value2 as string) as ustring
	dim sum as ustring = value
	sum += value2
	return sum
end operator

operator ustring.let(byref value as string)
	if (len(value) > 0 ) then
		this._length = len(value)
		this._buffer = value
	end if
end operator

destructor ustring()
end destructor

constructor ustring()
	this._length = 0
end constructor

constructor ustring(byval value as string)
	this._length = len(value)
	this._buffer = value
end constructor

constructor ustring(byref value as ustring)
	this._length = value._length
	this._buffer = value
end constructor

operator ustring.+=(byref value as string)
	this._buffer += value
	this._characters = 0 ' reset the char count
end operator

operator ustring.+=(byref value as ustring)
	this._buffer = value._buffer
	this._characters = 0 ' reset the char count	
end operator

operator ustring.cast() byref as string
	return this._buffer
end operator

property ustring.Length() as uinteger
	if ( this._characters = 0) then
		this._characters = CountCharacters(this._buffer)
	end if
	return this._characters
end property

property ustring.Size() as uinteger
	return this._length
end property

function ustring.CharToByte(byval index as uinteger) as long
	dim codepoint as ubyte 
	dim charIndex as uinteger = 0
	dim byteIndex as uinteger = 0
	do
		codePoint = this._buffer[byteIndex]
		if codepoint = 0 then 
			return -1
		end if
		
		if index = charIndex then return byteIndex
		charIndex += 1
		byteIndex += GetCodepointLength(codePoint)
	loop until codepoint = 0
end function

function ustring.Instr(byref expression as ustring, byval start as uinteger = 0) as long
	'Error case first:
	dim as uinteger index = this.CharToByte(start)
	if (index > this._length) then return -1
	
	dim as uinteger expressionLength = expression._length
	dim as uinteger i = index
	do 
		if i > this._length - expressionLength then
			exit do
		end if
		if memcmp(strptr(this._buffer) + i, strptr(expression._buffer), expressionLength) = 0 then
			dim charCount as uinteger
			dim codePoint as ubyte
			dim j as uinteger
			do
				codePoint = this._buffer[j]
				if codepoint = 0 then 
					return -1
				end if
				if j > i then return -1
				if j = i then return charCount
				charCount += 1
				j += GetCodepointLength(codePoint)
			loop until codepoint = 0 OR j >= i
			return charCount
		end if
		i += 1
	loop 
	return -1
end function

function ustring.Instr(byref expression as string, byval start as uinteger = 0) as long
	'Error case first:
	dim as uinteger index = this.CharToByte(start)
	if (index > this._length) then return -1
	
	dim as uinteger expressionLength = len(expression)
	dim as uinteger i = index
	do 
		if i > this._length - expressionLength then
			exit do
		end if
		if memcmp(strptr(this._buffer) + i, strptr(expression), expressionLength) = 0 then
			dim charCount as uinteger
			dim codePoint as ubyte
			dim j as uinteger
			do
				codePoint = this._buffer[j]
				if codepoint = 0 then 
					return -1
				end if
				if j > i then return -1
				if j = i then return charCount
				charCount += 1
				j += GetCodepointLength(codePoint)
			loop until codepoint = 0 OR j >= i
			return charCount
		end if
		i += 1
	loop 
	return -1
end function


operator ustring.[](byval index as uinteger) as ustring
	dim as ustring value
	dim i as long =  this.CharToByte(index)
	if (i <> -1) then
		value._buffer = mid(this._buffer, CharToByte(index)+1,  GetCodePointLength(this._buffer[i]))
	end if
	return value
end operator


function UnescapeUTF8(byval escapedPoint as string) as string
	dim as ulong codePoint = valulng("&h" & right(escapedPoint, len(escapedPoint)-2))	
	dim result as string
	
	if codePoint <= &h7F then
		result = space(1)
		result[0] = codePoint
		return result
	endif
	
	if 	(&hD800 <= codepoint AND codepoint <= &hDFFF) OR _
		(codepoint > &h10FFFD) then
		return ustringConstants.replacementChar
	end if
	
	if (codepoint <= &h7FF) then
		result = space(2)
		result[0] = &hC0 OR (codepoint SHR 6) AND &h1F 
		result[1] = &h80 OR codepoint AND &h3F
		return result
	end if
	if (codepoint <= &hFFFF) then
		result = space(3)
        result[0] = &hE0 OR codepoint SHR 12 AND &hF
        result[1] = &h80 OR codepoint SHR 6 AND &h3F
        result[2] = &h80 OR codepoint AND &h3F
        return result
    end if
	
	result = space(4)
	result[0] = &hF0 OR codepoint SHR 18 AND &h7
	result[1] = &h80 OR codepoint SHR 12 AND &h3F
	result[2] = &h80 OR codepoint SHR 6 AND &h3F
	result[3] = &h80 OR codepoint AND &h3F
    
	return result
end function

function EscapedToUtf8(byref escapedPoint as ustring) as string
	dim as ulong codePoint = valulng("&h" & right(escapedPoint, len(escapedPoint)-2))	
	dim result as string
	
	if codePoint <= &h7F then
		result = space(1)
		result[0] = codePoint
		return result
	endif
	
	if 	(&hD800 <= codepoint AND codepoint <= &hDFFF) OR _
		(codepoint > &h10FFFD) then
		return ustringConstants.replacementChar
	end if
	
	if (codepoint <= &h7FF) then
		result = space(2)
		result[0] = &hC0 OR (codepoint SHR 6) AND &h1F 
		result[1] = &h80 OR codepoint AND &h3F
		return result
	end if
	if (codepoint <= &hFFFF) then
		result = space(3)
        result[0] = &hE0 OR codepoint SHR 12 AND &hF
        result[1] = &h80 OR codepoint SHR 6 AND &h3F
        result[2] = &h80 OR codepoint AND &h3F
        return result
    end if
	
	result = space(4)
	result[0] = &hF0 OR codepoint SHR 18 AND &h7
	result[1] = &h80 OR codepoint SHR 12 AND &h3F
	result[2] = &h80 OR codepoint SHR 6 AND &h3F
	result[3] = &h80 OR codepoint AND &h3F
    
	return result
end function

function left overload (byref value as ustring, byval length as uinteger) as ustring
	return left(value._buffer, value.CharToByte(length))
end function

function right overload (byref value as ustring, byval length as uinteger) as ustring
	return right(value._buffer, value.CharToByte(len(value)-length))
end function
