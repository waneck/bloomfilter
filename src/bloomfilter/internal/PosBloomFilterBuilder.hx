package bloomfilter.internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
using haxe.macro.Tools;

class PosBloomFilterBuilder {
  public static function findOrBuild(intType:Type, ?hashExpr:Expr):Type {
    var complex:ComplexType = Context.follow(intType).toComplexType();
    var tpath = null;
    var name = switch(complex) {
      case TPath( p ):
        tpath = p;
        var name = p.sub == null ? p.name : p.sub;
        'PosBloomFilter_' + name + (hashExpr == null ? '' : '_' + haxe.crypto.Sha1.encode(hashExpr.toString()).substr(0,5));
      case _:
        throw new Error('Cannot build bloom filter from type $intType', Context.currentPos());
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

    var cls = macro class $name extends bloomfilter.AbstractPosBloomFilter {
      public var vector(default, null):haxe.ds.Vector<$complex>;

      public function new(config:bloomfilter.Config, ?vec) {
        super(config);
        this.vector = vec == null ? new haxe.ds.Vector<$complex>(config.bitSize) : vec;
      }

      public static function create(elements:Int, probability:Float) {
        return new $thisPath({ elements:elements, probability:probability });
      }

      override public function mayExist(data:bloomfilter.Bytes):Bool {
        var ret = true,
            vec = this.vector;
        var cur:$complex = 0;
        cur = ~cur;

        $hashExpr(data, this.bitSize, this.hashes, function(_,hash) {
          cur &= vec[hash];
          if (cur == 0) {
            return ret = false;
          } else {
            return true;
          }
        });
        return ret;
      }

      override public function add(data:bloomfilter.Bytes, position:Int):Void {
        var vec = this.vector;
        var pos = (1 : $complex) << position;
        $hashExpr(data, this.bitSize, this.hashes, function(i,hash) {
          var old = vec[hash];
          vec[hash] = old | pos;
          return true;
        });
      }

      public function get(data:Bytes):$complex {
        var vec = this.vector;
        var cur:$complex = 0;
        cur = ~cur;

        $hashExpr(data, this.bitSize, this.hashes, function(_,hash) {
          cur &= vec[hash];
          if (cur == 0) {
            return false;
          } else {
            return true;
          }
        });
        return cur;
      }

      public function getString(str:String):$complex {
        return this.get(Bytes.ofString(str));
      }

      override public function getBits(data:Bytes):Int {
        return cast get(data);
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
