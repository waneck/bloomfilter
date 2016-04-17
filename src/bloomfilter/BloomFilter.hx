package bloomfilter;

/**
  The Bloom Filter creator - This is macro implementation, and you should use it with your chosen
  bit array implementation as its type parameter
 **/
@:genericBuild(bloomfilter.internal.BloomFilterBuilder.build())
class BloomFilter<Rest> {
}
