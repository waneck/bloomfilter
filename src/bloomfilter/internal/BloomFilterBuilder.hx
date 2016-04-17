package bloomfilter.internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
using haxe.macro.Tools;

class BloomFilterBuilder {
  public static function findOrBuild(bitType:Type, ?hashExpr:Expr):Type {
    var complex:ComplexType = Context.follow(bitType).toComplexType();
    var tpath = null;
    var name = switch(complex) {
      case TPath( p ):
        tpath = p;
        var name = p.sub == null ? p.name : p.sub;
        'BloomFilter_' + name + (hashExpr == null ? '' : '_' + haxe.crypto.Sha1.encode(hashExpr.toString()).substr(0,5));
      case _:
        throw new Error('Cannot build bloom filter from type $bitType', Context.currentPos());
    };
    try {
      return Context.getType('bloomfilter.impl.$name');
    }
    catch(e:Dynamic) {
      // type does not exist
    }

    if (hashExpr == null) {
      hashExpr = macro bloomfilter.Hashes.murmur3;
    }
    var thisPath:TypePath = { pack:[], name:name };

    var cls = macro class $name extends bloomfilter.AbstractBloomFilter {
      public var bits(default, null):$complex;

      public function new(config:bloomfilter.Config, ?bits:$complex) {
        super(config);
        this.bits = bits == null ? new $tpath(config.bitSize) : bits;
      }

      public static function create(elements:Int, probability:Float) {
        return new $thisPath({ elements:elements, probability:probability });
      }

      override public function mayExist(data:bloomfilter.Bytes):Bool {
        var ret = true,
            bits = this.bits;
        $hashExpr(data, this.bitSize, this.hashes, function(hash) {
          if (bits[hash] == 0) {
            return ret = false;
          } else {
            return true;
          }
        });
        return ret;
      }

      override public function add(data:bloomfilter.Bytes):Void {
        var bits = this.bits;
        $hashExpr(data, this.bitSize, this.hashes, function(hash) {
          bits.set(hash);
        });
      }
    };

    cls.pack = ['bloomfilter','impl'];
    cls.name = name;
    Context.defineType(cls);
    return Context.getType('bloomfilter.impl.$name');
  }

  public static function build() {
    switch(Context.follow(Context.getLocalType())) {
    case TInst(_,tl):
      var realT = tl.shift(),
          hashFn = tl.shift();
      var expr = if (hashFn != null) {
        switch(Context.follow(hashFn)) {
          case TInst(_.get() => { kind: KExpr(e) }, _):
            switch(e.expr) {
            case EArrayDecl([e]):
              e;
            case _:
              e;
            }
          case _:
            throw new Error('Second argument should be an expression of the hash being used', Context.currentPos());
        }
      } else {
        null;
      }
      return findOrBuild(realT, expr);
    case t:
      throw new Error('Cannot build bloom filter from $t', Context.currentPos());
    }
  }
}
