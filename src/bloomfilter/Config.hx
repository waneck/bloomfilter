package bloomfilter;
import haxe.ds.Vector;

typedef Options = {
}

typedef CompleteConfig = {
  > Options,
  /**
    Number of expected elements
   **/
  ?elements : Int,

  /**
    Number of false positive probability
   **/
  ?probability : Float,

  /**
    Number of hashes to use
   **/
  ?hashes : Int,

  /**
    The total bit count of the underlying structure
   **/
  ?bitSize : Int,
}

@:forward abstract Config(CompleteConfig) {
  public var byteSize(get,never):Int;

  private function get_byteSize() {
    return this.bitSize << 3;
  }

  @:from public static function fromElementsProbability(arg:{ >Options, elements:Int, probability:Float, ?bitSize:Int, ?hashes:Int }):Config {
    var complete:CompleteConfig = cast arg;
    if (complete.bitSize == null) {
      complete.bitSize = optimalSize(complete.elements, complete.probability);
    }
    if (complete.hashes == null) {
      complete.hashes = optimalHashes(complete.elements, complete.bitSize);
    }
    return cast complete;
  }

  @:from public static function fromSizeHashes(arg:{ >Options, bitSize:Int, hashes:Int, ?elements:Int, ?probability:Float }):Config {
    var complete:CompleteConfig = cast arg;
    if (complete.elements == null) {
      complete.elements = optimalExpectedElements(complete.hashes, complete.bitSize);
    }
    if (complete.probability == null) {
      complete.probability = optimalProbability(complete.hashes, complete.bitSize, complete.elements);
    }
    return cast complete;
  }

  @:from public static function fromElementsSize(arg:{ >Options, elements:Int, bitSize:Int, ?hashes:Int, ?probability:Float }):Config {
    var complete:CompleteConfig = cast arg;
    if (complete.hashes == null) {
      complete.hashes = optimalHashes(complete.elements, complete.bitSize);
    }
    if (complete.elements == null) {
      complete.elements = optimalExpectedElements(complete.hashes, complete.bitSize);
    }
    return cast complete;
  }

  public static function optimalSize(elements:Int, probability:Float):Int {
    //return (int) Math.ceil(-1 * (n * Math.log(p)) / Math.pow(Math.log(2), 2));
    return Std.int(Math.ceil( -1 * (elements * Math.log(probability)) / Math.pow(Math.log(2), 2) ));
  }

  public static function optimalHashes(elements:Int, bitSize:Int) {
    // return (int) Math.ceil((Math.log(2) * m) / n);
    return Std.int( Math.ceil((Math.log(2) * bitSize) / elements) );
  }

  public static function optimalExpectedElements(hashes:Int, bitSize:Int) {
    // return (int) Math.ceil((Math.log(2) * m) / k);
    return Std.int( Math.ceil((Math.log(2) * bitSize) / hashes) );
  }

  public static function optimalProbability(hashes:Int, bitSize:Int, insertedElements:Int):Float {
    // return Math.pow((1 - Math.exp(-k * insertedElements / (double) m)), k);
    return Math.pow(1 - Math.exp(-hashes * insertedElements / bitSize), hashes);
  }
}
