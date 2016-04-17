package bloomfilter;

class AbstractCountingBloomFilter extends AbstractBloomFilter {

  dynamic public function onOverflow(self:AbstractCountingBloomFilter) {
    trace('Overflow happened');
  }

  public function remove(data:Bytes):Bool {
    throw 'Not Implemented';
  }

  public function removeString(str:String):Bool {
    return this.remove(Bytes.ofString(str));
  }
}
