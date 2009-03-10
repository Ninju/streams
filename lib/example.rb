require 'streams'

class Stream
  def sieve
    Stream.new( head ) { tail.select { | n | n % head > 0 }.sieve }
  end
end

module Math 
  PRIMES = 2.enumerate.sieve
end
