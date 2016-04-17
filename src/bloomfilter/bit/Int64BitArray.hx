package bloomfilter.bit;
import haxe.ds.Vector;
#if java
import java.StdTypes;
#elseif cs
import cs.StdTypes;
#elseif cpp
import cpp.Int64;
#else
import haxe.Int64;
#end

private typedef Self = Int64BitArray;

abstract Int64BitArray(Vector<Int64>) from Vector<Int64> {
  public var length(get, never):Int;

  inline public function new(nbits:Int) {
    this = new Vector((nbits + 63) >>> 6);
  }

  inline private function t() {
    return this;
  }

  @:extern inline private function get_length():Int {
    return this.length << 6; // length * 32
  }

  /**
    Gets the bit at position `bitNum`
    Returns either 0 or 1
   **/
  @:arrayAccess inline public function get(bitNum:Int):Int {
    var bitidx = bitNum & 63;
    return cast ( ( this[bitNum >>> 6] & ((1 : Int64) << bitidx) ) >>> bitidx );
  }

  /**
    Sets the bit at position `bitNum`
   **/
  inline public function set(bitNum:Int):Void {
    this[bitNum >>> 6] |= ((1 : Int64) << (bitNum & 63));
  }

  /**
    Sets the bit at position `bitNum`
   **/
  inline public function unset(bitNum:Int):Void {
    this[bitNum >>> 6] &= ~((1 : Int64) << (bitNum & 63));
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

