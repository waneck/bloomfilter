package bloomfilter;

private typedef BytesData =
#if (java || cs)
    haxe.io.BytesData
#else
    haxe.io.Bytes
#end;

abstract Bytes(BytesData) from BytesData to BytesData {
  public var length(get, never):Int;

  public static function alloc(byteSize:Int):Bytes {
#if java
    return (new java.NativeArray(byteSize) : haxe.io.BytesData);
#elseif cs
    return (new cs.NativeArray(byteSize) : haxe.io.BytesData);
#else
    return haxe.io.Bytes.alloc(byteSize);
#end
  }

  public static function ofString(str:String):Bytes {
#if (java || cs)
    return haxe.io.Bytes.ofString(str).getData();
#else
    return haxe.io.Bytes.ofString(str);
#end
  }

  inline private function get_length() {
#if cs
    return this.Length;
#else
    return this.length;
#end
  }

  @:arrayAccess inline function get(index:Int):Int {
#if java
    return (cast this[index]) & 0xFF;
#elseif cs
    return cast (this[index]);
#else
    return this.get(index);
#end
  }

  @:arrayAccess inline function set(index:Int, val:Int):Void {
#if (java || cs)
    this[index] = cast val & 0xFF;
#else
    this.set(index, val);
#end
  }
}
