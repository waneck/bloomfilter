package bloomfilter;

/**
  A counting Bloom Filter creator - This is macro implementation, and you should use it with your
  chosen Int type implementation for its size
 **/
@:genericBuild(bloomfilter.internal.PosBloomFilterBuilder.build())
class PosBloomFilter<Rest> {
}
