== Haxe implementation of bloom filters

Based on https://github.com/Baqend/Orestes-Bloomfilter , uses macros to achieve the best performance possible,
and still allow customizations.

This allows this library to be from a first estimate, 2x faster than the library it was based on when targetting Java

Example:

```haxe
// create a simple bloom filter with estimated 2000 elements, 1% of probability of collisions

var filter = new bloomfilter.SimpleBloomFilter({ elements: 2000, probability: 0.01 });
filter.addString("hello");
filter.addString("world");
trace(filter.mayExist("hello")); // true
trace(filter.mayExist("world")); // true

// you can also specify the bitarray that is going to be used, and optionally the hash function:
var filter = new bloomfilter.BloomFilter<bloomfilter.bit.bloomfilter.bit.ByteBitArray>({ elements: 2000, probability: 0.01 });

// or, with the hash function as well:
var filter = new bloomfilter.BloomFilter<bloomfilter.bit.bloomfilter.bit.ByteBitArray, [bloomfilter.Hashes.murmur3]>({ elements: 2000, probability: 0.01 });
```

There is also an implementation of `CountingBloomFilter`, which tracks also the amount of elements each hash was associated, and because of this - it supports deletion (as long as no element overflows)

The following options are available:
```haxe
var counting = new bloomfilter.CountingBloomFilter<haxe.Int64, [some.Hash.func]>(...)
```
THe first type parameter is which int type is going to be used (note that the code doesn't perform any check if the type is really an int). The size of the Ints will determine the maximum size that an item can be added before it overflows

And lastly, there is an implementation o `PosBloomFilter`, which tracks a `position` of where the elements are. This position is made of a bit array that can vary in size according to the type parameter passed (e.g. `Int64` allows 64 positions, normal `Int` allows 32 positions, and so on).
As with counting bloom filter, this occupies more space proportionally to the bit size chosen. However, differently from `PosBloomFilter`, if the values are well distributed between positions, the amount of false positives will diminish rapidly
