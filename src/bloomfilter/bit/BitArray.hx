package bloomfilter.bit;

typedef BitArray =
  #if (java || cs)
    Int64BitArray
  #elseif js
    ByteBitArray
  #else
    IntBitArray
  #end;
