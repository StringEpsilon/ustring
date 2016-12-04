/'	
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at http://mozilla.org/MPL/2.0/. 
'/

#include once "crt.bi"

namespace VZStringConstants

' The minimum size any given VZString buffer has:
const MinimumBufferSize = 32

'
const AdditionalBuffer = 8

end namespace

using VZStringConstants

type VZString 
	private:
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
end type

destructor VZString()
	deallocate(this._buffer)
end destructor

constructor VZString()
	this._buffer = callocate(sizeof(zstring)*MinimumBufferSize)
	this._length = 0
	this._bufferSize = 32
end constructor

constructor VZString(value as zstring ptr)
	this._length = len(*value)
	this._bufferSize = this._length * sizeof(zstring) + AdditionalBuffer
	this._buffer = callocate(this._bufferSize)
	memcpy( this._buffer, value, this._length )
end constructor

constructor VZString(value as vzstring)
	this._length = value._length
	this._bufferSize = value._bufferSize
	this._buffer = callocate(this._bufferSize)
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

operator vzstring.cast() byref as zstring
	? this._buffer
	return *this._buffer
end operator
