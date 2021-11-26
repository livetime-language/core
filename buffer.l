transient struct Buffer
	int readPos, writePos
	private object buffer
	private object dataView
	
	Buffer: object buffer = null
		    int size = 1024
		setup(size)
		
	private js void setup: int size = 1024
		if(!this.buffer) this.buffer = new ArrayBuffer(size)
		else             this.writePos = this.buffer.byteLength
		this.dataView = new DataView(this.buffer)
		
	js void writeInt: int value
		if(value < -2147483648 || value > 2147483647)
			throw new Error("Buffer: Value out of integer range: {value}")
		let n, lastByte
		if(value > 0) {
			n = value
			lastByte = n & 0x3f
		} else {
			n = -value
			lastByte = (n & 0x3f) | 0x40
		}
		if (n < (1 << 13)) {
			if (n < (1 << 6)) {
				if(this.writePos+1 > this.buffer.byteLength) this.expandBuffer(this.writePos+1)
				let dataView = this.dataView
				dataView.setUint8(this.writePos++, lastByte);
				return 1;
			} else {
				if(this.writePos+2 > this.buffer.byteLength) this.expandBuffer(this.writePos+2)
				let dataView = this.dataView
				dataView.setUint8(this.writePos++, (n >> 6) | 0x80);
				dataView.setUint8(this.writePos++, lastByte);
				return 2;
			}
		} else if (n < (1 << 27)) {
			if (n < (1 << 20)) {
				if(this.writePos+3 > this.buffer.byteLength) this.expandBuffer(this.writePos+3)
				let dataView = this.dataView
				dataView.setUint8(this.writePos++, (n >> 13) | 0x80);
				dataView.setUint8(this.writePos++, ((n >> 6) & 0x7f) | 0x80);
				dataView.setUint8(this.writePos++, lastByte);
				return 3;
			} else {
				if(this.writePos+4 > this.buffer.byteLength) this.expandBuffer(this.writePos+4)
				let dataView = this.dataView
				dataView.setUint8(this.writePos++,  (n >> 20) | 0x80);
				dataView.setUint8(this.writePos++, ((n >> 13) & 0x7f) | 0x80);
				dataView.setUint8(this.writePos++, ((n >>  6) & 0x7f) | 0x80);
				dataView.setUint8(this.writePos++, lastByte);
				return 4;
			}
		} else {
			if(this.writePos+5 > this.buffer.byteLength) this.expandBuffer(this.writePos+5)
			let dataView = this.dataView
			dataView.setUint8(this.writePos++,  (n >> 27) | 0x80);
			dataView.setUint8(this.writePos++, ((n >> 20) & 0x7f) | 0x80);
			dataView.setUint8(this.writePos++, ((n >> 13) & 0x7f) | 0x80);
			dataView.setUint8(this.writePos++, ((n >>  6) & 0x7f) | 0x80);
			dataView.setUint8(this.writePos++, lastByte);
			return 5;
		}
		
	js int readInt
		let dataView = this.dataView
		let a = dataView.getUint8(this.readPos++);
		if((a & 0x80) == 0) {
			return a & 0x40 ? -(a & 0x3f) 
			                :   a;
		} else {
			a &= 0x7f;
			let b = dataView.getUint8(this.readPos++);
			if((b & 0x80) == 0) {
				return b & 0x40 ? -((b & 0x3f) | (a << 6)) 
				                :   (b         | (a << 6));
			} else {
				b &= 0x7f;
				let c = dataView.getUint8(this.readPos++);
				if((c & 0x80) == 0) {
					return c & 0x40 ? -((c & 0x3f) | (b << 6) | (a << 13))
					                :   (c         | (b << 6) | (a << 13));
				} else {
					c &= 0x7f;
					let d = dataView.getUint8(this.readPos++);
					if((d & 0x80) == 0) {
						return d & 0x40 ? -((d & 0x3f) | (c << 6) | (b << 13) | (a << 20))
						                :   (d         | (c << 6) | (b << 13) | (a << 20));
					} else {
						d &= 0x7f;
						let e = dataView.getUint8(this.readPos++);
						return e & 0x40 ? -((e & 0x3f) | (d << 6) | (c << 13) | (b << 20) | (a << 27))
						                :   (e         | (d << 6) | (c << 13) | (b << 20) | (a << 27));
					}
				}
			}
		}
		
	js void writeUnsignedInt: int value
		if(value < 0 || value > 2147483647)
			throw new Error("Buffer: Value out of integer range: {value}")
			
		var n = value
		if (n < (1 << 14)) {
			if (n < (1 << 7)) {
				if(this.writePos+1 > this.buffer.byteLength) this.expandBuffer(this.writePos+1)
				let dataView = this.dataView
				dataView.setUint8(this.writePos++, n);
				return 1;
			} else {
				if(this.writePos+2 > this.buffer.byteLength) this.expandBuffer(this.writePos+2)
				let dataView = this.dataView
				dataView.setUint8(this.writePos++, (n >> 7) | 0x80);
				dataView.setUint8(this.writePos++, n & 0x7f);
				return 2;
			}
		} else if (n < (1 << 28)) {
			if (n < (1 << 21)) {
				if(this.writePos+3 > this.buffer.byteLength) this.expandBuffer(this.writePos+3)
				let dataView = this.dataView
				dataView.setUint8(this.writePos++, (n >> 14) | 0x80);
				dataView.setUint8(this.writePos++, ((n >> 7) & 0x7f) | 0x80);
				dataView.setUint8(this.writePos++, n & 0x7f);
				return 3;
			} else {
				if(this.writePos+4 > this.buffer.byteLength) this.expandBuffer(this.writePos+4)
				let dataView = this.dataView
				dataView.setUint8(this.writePos++, (n >> 21) | 0x80);
				dataView.setUint8(this.writePos++, ((n >> 14) & 0x7f) | 0x80);
				dataView.setUint8(this.writePos++, ((n >> 7) & 0x7f) | 0x80);
				dataView.setUint8(this.writePos++, n & 0x7f);
				return 4;
			}
		} else {
			if(this.writePos+5 > this.buffer.byteLength) this.expandBuffer(this.writePos+5)
			let dataView = this.dataView
			dataView.setUint8(this.writePos++, (n >> 28) | 0x80);
			dataView.setUint8(this.writePos++, ((n >> 21) & 0x7f) | 0x80);
			dataView.setUint8(this.writePos++, ((n >> 14) & 0x7f) | 0x80);
			dataView.setUint8(this.writePos++, ((n >> 7) & 0x7f) | 0x80);
			dataView.setUint8(this.writePos++, n & 0x7f);
			return 5;
		}
		
	js int readUnsignedInt
		let dataView = this.dataView
		let a = dataView.getUint8(this.readPos++);
		if((a & 0x80) == 0) {
			return a;
		} else {
			a &= 0x7f;
			let b = dataView.getUint8(this.readPos++);
			if((b & 0x80) == 0) {
				return b | (a << 7);
			} else {
				b &= 0x7f;
				let c = dataView.getUint8(this.readPos++);
				if((c & 0x80) == 0) {
					return c | (b << 7) | (a << 14);
				} else {
					c &= 0x7f;
					let d = dataView.getUint8(this.readPos++);
					if((d & 0x80) == 0) {
						return d | (c << 7) | (b << 14) | (a << 21);
					} else {
						d &= 0x7f;
						let e = dataView.getUint8(this.readPos++);
						return e | (d << 7) | (c << 14) | (b << 21) | (a << 28);
					}
				}
			}
		}

	private js void expandBuffer: int size
		let prevLength = this.buffer.byteLength
		let len = Math.max(prevLength*2, size)
		this.buffer = new ArrayBuffer(len)
		let prevDataView = this.dataView
		let newDataView = new DataView(this.buffer)
		for(let i=0; i<prevLength; i++)
			newDataView.setInt8(i, prevDataView.getInt8(i))
				
		this.dataView = newDataView
		
	inline js void setInt16: int index, int value
		this.dataView.setInt16(index, value)
		
	internal skip: int count
		this.readPos += count
		
	internal js int reserveSize
		this.writePos += 4
		return this.writePos
	
	internal js void writeSize: int pos
		this.dataView.setInt32(pos-4, this.writePos-pos)
	
	js void writeInt8: int value
		if(this.writePos+1 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+1)
		this.dataView.setInt8(this.writePos, value)
		this.writePos += 1
	
	js void writeUnsignedInt8: int value
		if(this.writePos+1 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+1)
		this.dataView.setUint8(this.writePos, value)
		this.writePos += 1
	
	js void writeInt16: int value
		if(this.writePos+2 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+2)
		this.dataView.setInt16(this.writePos, value)
		this.writePos += 2
	
	js void writeUnsignedInt16: int value
		if(this.writePos+2 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+2)
		this.dataView.setUint16(this.writePos, value)
		this.writePos += 2
	
	js void writeInt32: int value
		if(this.writePos+4 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+4)
		this.dataView.setInt32(this.writePos, value)
		this.writePos += 4
	
	js void writeFloat64: float value
		if(this.writePos+8 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+8)
		this.dataView.setFloat64(this.writePos, value)
		this.writePos += 8
		
	js void writeBool: bool value
		if(this.writePos+1 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+1)
		this.dataView.setInt8(this.writePos, value ? 1 : 0)
		this.writePos += 1
		
	js void writeString: string value
		let len = value.length
		let size = 4+len*4
		if(this.writePos+size > this.buffer.byteLength)
			this.expandBuffer(this.writePos+size)
		this.dataView.setInt32(this.writePos, len*4)
		this.writePos += 4
		for(let i=0; i<len; ++i) {
			this.dataView.setInt32(this.writePos, value.charCodeAt(i))
			this.writePos += 4
		}
		
	void writeBuffer: Buffer source
		writeBuffer source, 0, source.writePos
	
	js void writeBuffer: Buffer source
		                 int start
		                 int length
		// Expand if neccessary
		if(this.writePos+length+4 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+length+4)
			
		// Write length
		this.writeUnsignedInt(length)
		
		// Write bytes
		let readPos = start
		let writePos = this.writePos
		let readPosEnd = start + length
		let targetDataView = this.dataView
		let sourceDataView = source.dataView
		while(readPos < readPosEnd)
			targetDataView.setUint8(writePos++, sourceDataView.getUint8(readPos++))
		this.writePos = writePos
		
	js void copyFromBuffer: Buffer source
		let readPos = 0
		let length = source.writePos
		let writePos = this.writePos
		
		// Expand if neccessary
		if(writePos+length > this.buffer.byteLength)
			this.expandBuffer(writePos+length)
			
		// Write bytes
		let readPosEnd = readPos + length
		while(readPos < readPosEnd)
			this.dataView.setUint8(writePos++, source.dataView.getUint8(readPos++))
			
		this.writePos = writePos
		
	inline js int peekInt8  := this.dataView.getInt8(this.readPos)
	inline js int peekInt16 := this.dataView.getInt16(this.readPos)
	inline js int peekInt32 := this.dataView.getInt32(this.readPos)
	
	js int readInt8
		return this.dataView.getInt8(this.readPos++)
		
	js int readUnsignedInt8
		return this.dataView.getUint8(this.readPos++)
		
	js int readInt16
		let value = this.dataView.getInt16(this.readPos)
		this.readPos += 2
		return value
		
	js int readUnsignedInt16
		let value = this.dataView.getUint16(this.readPos)
		this.readPos += 2
		return value
		
	js int readInt32
		let value = this.dataView.getInt32(this.readPos)
		this.readPos += 4
		return value

	js float readFloat64
		let value = this.dataView.getFloat64(this.readPos)
		this.readPos += 8
		return value
		
	js bool readBool
		return this.dataView.getInt8(this.readPos++) != 0
		
	js string readString
		let value = ""
		let len = this.dataView.getInt32(this.readPos)/4
		this.readPos += 4
		for(let i=0; i<len; ++i) {
			value += String.fromCharCode(this.dataView.getInt32(this.readPos))
			this.readPos += 4
		}
		return value

	js int readBuffer: Buffer writeBuffer
		               int writeStart = 0
		// Read length
		let length = this.readUnsignedInt()
		
		// Expand writeBuffer if neccessary
		if(writeStart+length > writeBuffer.buffer.byteLength)
			writeBuffer.expandBuffer(writeStart+length)
			
		// Read bytes
		let readPos = this.readPos
		let writePos = writeStart
		let readPosEnd = readPos + length
		let sourceDataView = this.dataView
		let targetDataView = writeBuffer.dataView
		while(readPos < readPosEnd)
			targetDataView.setUint8(writePos++, sourceDataView.getUint8(readPos++))
		this.readPos = readPos
		
		writeBuffer.writePos = writePos
		return length
			
	js string toString
		let result = "readPos:" + this.readPos + " writePos:" + this.writePos
		for(let i=0; i<this.writePos; i ++)
			result += " " + this.dataView.getUint8(i)
		return result
		
	js string toRangeString: int start, int end
		let result = ""
		for(let i=start; i<end; i++)
			result += " " + this.dataView.getUint8(i)
		return result
		
	canRead := readPos < writePos

	reset
		this.writePos = 0
		this.readPos = 0   
		
		
