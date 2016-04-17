package bloomfilter.bit;
import haxe.ds.Vector;
import haxe.io.Bytes;

private typedef Self = ByteBitArray;

abstract ByteBitArray(Bytes) from Bytes {
  public var length(get, never):Int;

  inline public function new(nbits:Int) {
    this = Bytes.alloc((nbits + 7) >>> 3);
  }

  inline private function t() {
    return this;
  }

  @:extern inline private function get_length():Int {
    return this.length << 3; // length * 32
  }

  /**
    Gets the bit at position `bitNum`
    Returns either 0 or 1
   **/
  @:arrayAccess inline public function get(bitNum:Int):Int {
    var bitidx = bitNum & 7;
    return (this.get(bitNum >>> 3) & (1 << bitidx)) >>> bitidx;
  }

  /**
    Sets the bit at position `bitNum`
   **/
  inline public function set(bitNum:Int):Void {
    var idx = bitNum >>> 3;
    this.set(idx, this.get(idx) | (1 << (bitNum & 7)));
  }

  /**
    Sets the bit at position `bitNum`
   **/
  inline public function unset(bitNum:Int):Void {
    this.set(idx, this.get(idx) & ~(1 << (bitNum & 7)));
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
      result.set(i, this.get(i) & other.get(i));
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
      result.set(i, this.get(i) & ~other.get(i));
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
      result.set(i, this.get(i) | other.get(i));
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
      result.set(i, this.get(i) ^ other.get(i));
    }
    return result;
  }
}

