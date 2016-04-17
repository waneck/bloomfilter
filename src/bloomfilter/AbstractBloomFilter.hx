package bloomfilter;
import haxe.ds.Vector;
import bloomfilter.bit.BitArray;

class AbstractBloomFilter {
  var m_config:Config;

  /**
    Number of expected elements
   **/
  public var elements(default, null) : Int;

  /**
    Number of false positive probability
   **/
  public var probability(default, null) : Float;

  /**
    Number of hashes to use
   **/
  public var hashes(default, null) : Int;

  /**
    The total bit count of the underlying structure
   **/
  public var bitSize(default, null) : Int;

  private function new(config:Config) {
    m_config = config;
    this.elements = config.elements;
    this.probability = config.probability;
    this.hashes = config.hashes;
    this.bitSize = config.bitSize;
  }

  public function add(data:Bytes):Void {
    throw 'Not Implemented';
  }

  public function addString(str:String):Void {
    return this.add(Bytes.ofString(str));
  }

  public function mayExist(data:Bytes):Bool {
    throw 'Not Implemented';
  }

  public function mayExistString(str:String):Bool {
    return this.mayExist(Bytes.ofString(str));
  }

}
