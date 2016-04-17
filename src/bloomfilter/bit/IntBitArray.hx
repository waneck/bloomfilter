package bloomfilter.bit;
import haxe.ds.Vector;

private typedef Self = IntBitArray;

abstract IntBitArray(Vector<Int>) from Vector<Int> {
  public var length(get, never):Int;

  inline public function new(nbits:Int) {
    this = new Vector((nbits + 31) >>> 5);
  }

  inline private function t() {
    return this;
  }

  @:extern inline private function get_length():Int {
    return this.length << 5; // length * 32
  }

  /**
    Gets the bit at position `bitNum`
    Returns either 0 or 1
   **/
  @:arrayAccess inline public function get(bitNum:Int):Int {
    var bitidx = bitNum & 31;
    return ( this[bitNum >>> 5] & (1 << bitidx) ) >>> bitidx;
  }

  /**
    Sets the bit at position `bitNum`
   **/
  inline public function set(bitNum:Int):Void {
    this[bitNum >>> 5] |= (1 << (bitNum & 31));
  }

  /**
    Sets the bit at position `bitNum`
   **/
  inline public function unset(bitNum:Int):Void {
    this[bitNum >>> 5] &= ~(1 << (bitNum & 31));
  }

  /**
    Performs a bit and operation on `other`, and sets the result into `result`, if sent
    Returns the result
   **/
  public function bitAnd(other:Self, ?result:Self):Self {
    var len = this.length,
        other = other.t(),
        result = result.t(),
        minLen = len;

    if (minLen > other.length) {
      minLen = other.length;
    }

    if (result == null) {
      result = new Vector(len);
    } else if (minLen > result.length) {
      minLen = result.length;
    }

    if (minLen > other.length) {
      minLen = other.length;
    }

    for (i in 0...minLen) {
      result[i] = this[i] & other[i];
    }
    return result;
  }

  /**
    Performs a bit and not operation on `other`, and sets the result into `result`, if sent
    Returns the result
   **/
  public function bitAndNot(other:Self, ?result:Self):Self {
    var len = this.length,
        other = other.t(),
        result = result.t(),
        minLen = len;

    if (minLen > other.length) {
      minLen = other.length;
    }

    if (result == null) {
      result = new Vector(len);
    } else if (minLen > result.length) {
      minLen = result.length;
    }

    for (i in 0...minLen) {
      result[i] = this[i] & ~other[i];
    }
    return result;
  }

  /**
    Performs a bit or operation on `other`, and sets the result into `result`, if sent
    Returns the result
   **/
  public function bitOr(other:Self, ?result:Self):Self {
    var len = this.length,
        other = other.t(),
        result = result.t(),
        minLen = len;

    if (minLen > other.length) {
      minLen = other.length;
    }

    if (result == null) {
      result = new Vector(minLen);
    } else if (minLen > result.length) {
      minLen = result.length;
    }

    for (i in 0...minLen) {
      result[i] = this[i] | other[i];
    }
    return result;
  }

  /**
    Performs a bit xor operation on `other`, and sets the result into `result`, if sent
    Returns the result
   **/
  public function bitXor(other:Self, ?result:Self):Self {
    var len = this.length,
        other = other.t(),
        result = result.t(),
        minLen = len;

    if (minLen > other.length) {
      minLen = other.length;
    }

    if (result == null) {
      result = new Vector(len);
    } else if (minLen > result.length) {
      minLen = result.length;
    }

    for (i in 0...minLen) {
      result[i] = this[i] ^ other[i];
    }
    return result;
  }
}
