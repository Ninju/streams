Description
=========

'Streams' is a lightweight streams processing library written in Ruby. 

I intend to keep this very small, and have added most common methods to make it immediately useable.

Example 
------------
```ruby
require 'streams'

class Stream
  def sieve
    Stream.new(head) { tail.select { |n| n % head > 0 }.sieve }
  end
end

class Integer
  def enumerate(step = 1, &block)
    if block_given?
      return Stream.new(self) { block.call(self).enumerate(&block) } 
    end
    
    Stream.new(self) { (self + step).enumerate(step) } 
  end
end

module Math
  PRIMES = 2.enumerate.sieve
end
```

```ruby
# in IRB
> Math::PRIMES.at( 30 )
=> 127
> Math::PRIMES.select { | n | n > 100 }.take( 50 )
=> [101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379]
```
