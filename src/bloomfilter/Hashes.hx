package bloomfilter;

class Hashes {
  @:extern inline public static function murmur3(data:Bytes, bitSize:Int, hashes:Int, onHash:Int->Int->Bool) {
    var hash1:UInt = murmur3Hash(0, data);
    var hash2:UInt = murmur3Hash(hash1, data);
    for (i in 0...hashes) {
      var hash:Int = (hash1 + i * hash2) % bitSize;
      if (!onHash(i,hash)) {
        break;
      }
    }
  }

  /**
    Murmur3 hash
   **/
  private static function murmur3Hash(seed:Int, bytes:Bytes) {
    var h1 = seed;
    //Standard in Guava
    var c1 = 0xcc9e2d51;
    var c2 = 0x1b873593;
    var len = bytes.length;
    var i = 0;

    inline function rotateLeft(i:Int, dist:Int) {
      return (i >>> dist) | (i << -dist);
    }

    while (len >= 4) {
      //process()
      var k1 = bytes[i + 0];
      k1 |= (bytes[i + 1]) << 8;
      k1 |= (bytes[i + 2]) << 16;
      k1 |= (bytes[i + 3]) << 24;

      k1 *= c1;
      k1 = rotateLeft(k1, 15);
      k1 *= c2;

      h1 ^= k1;
      h1 = rotateLeft(h1, 13);
      h1 = h1 * 5 + 0xe6546b64;

      len -= 4;
      i += 4;
    }


    if (len > 0) {
      //processingRemaining()
      var k1 = 0;
      switch (len) {
        case 3:
          k1 ^= (bytes[i + 2]) << 16;
          // fall through
        case 2:
          k1 ^= (bytes[i + 1]) << 8;
          // fall through
        case 1:
          k1 ^= (bytes[i]);
          // fall through
        default:
          k1 *= c1;
          k1 = rotateLeft(k1, 15);
          k1 *= c2;
          h1 ^= k1;
      }
      i += len;
    }

    //makeHash()
    h1 ^= i;

    h1 ^= h1 >>> 16;
    h1 *= 0x85ebca6b;
    h1 ^= h1 >>> 13;
    h1 *= 0xc2b2ae35;
    h1 ^= h1 >>> 16;

    return h1;
  }
}
