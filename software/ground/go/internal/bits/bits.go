// Package bits reads and writes big-endian bit fields at arbitrary offsets, as the generated packet
// tables lay fields out (offset_bits, width_bits from the start of the packet).
package bits

// Get returns the unsigned value of width bits at offset.
func Get(data []byte, offset, width int) uint64 {
	var v uint64
	for k := 0; k < width; k++ {
		pos := offset + k
		v = v<<1 | uint64(data[pos>>3]>>(7-uint(pos&7))&1)
	}
	return v
}

// Put writes value into width bits at offset; it panics when the value does not fit.
func Put(data []byte, offset, width int, value uint64) {
	if width < 64 && value>>uint(width) != 0 {
		panic("bits: value does not fit the field")
	}
	for k := 0; k < width; k++ {
		pos := offset + k
		mask := byte(0x80) >> uint(pos&7)
		if value>>uint(width-1-k)&1 == 1 {
			data[pos>>3] |= mask
		} else {
			data[pos>>3] &^= mask
		}
	}
}
