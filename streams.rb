class Stream
  attr_reader :head, :delayed_tail

  def initialize( head = nil, &block )
    @head = head
    @delayed_tail = block || head && Proc.new { Stream.new }
  end

  def tail
    @tail ||= delayed_tail && delayed_tail.call
  end

  def empty?
    head.nil?
  end

  def size
    return 0 if empty?
    1 + tail.size
  end

  def each( &block )
    return if empty?
    block.call( head )
    tail.each( &block )
  end

  def map( &block )
    return self if empty?
    Stream.new( block.call( head ) ) { tail.map( &block ) }
  end
  
  def select( &block )
    return self if empty?
    
    if block.call( head )
      return Stream.new( head ) { tail.select( &block ) }
    end

    tail.select( &block )
  end

  def reject( &block )
    select do | element |
      !block.call( element )
    end
  end

  def merge( other )
    return self if other.empty?
    return other if self.empty?
    Stream.new( head + other.head ) { tail.merge( other.tail ) }
  end
  
  def append( other )
    return self if other.empty? 
    return other if empty?
    Stream.new( head ) { tail.append( other ) }
  end

  def take( n )
    return Stream.new if empty? || n.zero?
    return Stream.new( head ) if n == 1
    Stream.new( head ) { tail.take( n - 1 ) }
  end

  def at( n )
    raise ArgumentError, "Index out of bounds" if empty? && n >= 0
    return head if n.zero?
    tail.at( n - 1 )
  end

  def drop( n )
    return self if n.zero?
    return Stream.new if empty?
    tail.drop( n - 1 )
  end

  def uniq
    return self if empty?
    Stream.new( head ) { tail.select { | element | element != head }.uniq }
  end

  def last
    return nil if empty?
    return head if tail.empty?
    tail.last
  end

  def to_a
    return [] if empty?
    [ head ] + tail.to_a
  end

  def join( separator = "" )
    return "" if empty?
    return head.to_s if tail.empty?
    head.to_s + separator + tail.join( separator )
  end

  def inspect
    "[" + join( ", " ) + "]"
  end

  def include?( element )
    return false if empty?
    head == element || tail.include?( element )
  end

  def ==( other )
    head == other.head && tail == other.tail
  end

  def take_while( &block )
    if block.call( head )
      Stream.new( head ) { tail.take_while( &block ) }
    else
      Stream.new
    end
  end

  def all?( &block )
    return true if empty?
    block.call( head ) && tail.all?( &block )
  end

  def any?( &block )
    return false if empty?
    block.call( head ) || tail.any?( &block )
  end
end

class Array
  def to_stream
    return Stream.new if empty?
    Stream.new( first ) { self[ 1..-1 ].to_stream }
  end
end

class Integer
  def enumerate( step = 1, &block )
    if block_given?
      return Stream.new( self ) { block.call( self ).enumerate( &block ) }
    end
    Stream.new( self ) { ( self + step ).enumerate( step ) }
  end

  def enumerate_to( value, step = 1, &block )
    return Stream.new if ( step >= 0 && self > value ) || ( step < 0 && self < value )
    if block_given?
      return Stream.new( self ) { block.call( self ).enumerate_to( value, &block ) }
    end

    Stream.new( self ) { ( self + step ).enumerate_to( value, step ) }
  end
end
