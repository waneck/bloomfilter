package bloomfilter.internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
using haxe.macro.Tools;

class CountingBloomFilterBuilder {
  public static function findOrBuild(intType:Type, ?hashExpr:Expr):Type {
    var complex:ComplexType = Context.follow(intType).toComplexType();
    var tpath = null;
    var name = switch(complex) {
      case TPath( p ):
        tpath = p;
        var name = p.sub == null ? p.name : p.sub;
        'CountingBloomFilter_' + name + (hashExpr == null ? '' : '_' + haxe.crypto.Sha1.encode(hashExpr.toString()).substr(0,5));
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

    var cls = macro class $name extends bloomfilter.AbstractCountingBloomFilter {
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
        $hashExpr(data, this.bitSize, this.hashes, function(_,hash) {
          if (vec[hash] == 0) {
            return ret = false;
          } else {
            return true;
          }
        });
        return ret;
      }

      override public function add(data:bloomfilter.Bytes):Void {
        var vec = this.vector;
        $hashExpr(data, this.bitSize, this.hashes, function(i,hash) {
          var old = vec[hash];
          if (old + 1 == 0) { // overflow
            this.onOverflow(this);
          } else {
            vec[hash] = vec[hash] + 1;
          }
          return true;
        });
      }

      override public function remove(data:bloomfilter.Bytes):Bool {
        var vec = this.vector,
            ret = true;
        $hashExpr(data, this.bitSize, this.hashes, function(i,hash) {
          var old = vec[hash];
          if (old != 0) {
            if (old + 1 != 0) {
              // once overflows, we canno support remove
              vec[hash] = old - 1;
            }
            return true;
          } else {
            // unlikely case that the value does not exist
            if (i != 0) {
              rollbackRemove(data, i);
            }
            return ret = false;
          }
        });
        return ret;
      }

      @:private @:final private function rollbackRemove(data:bloomfilter.Bytes, until:Int) {
        var vec = this.vector;
        $hashExpr(data, this.bitSize, until, function(i,hash) {
          vec[hash] = vec[hash] + 1;
          return true;
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
