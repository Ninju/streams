require File.join( File.dirname(__FILE__), *%w[spec_helper] )
require 'streams'

describe Stream do
  it "should create a new instance" do
    Proc.new { Stream.new }.should_not raise_error
  end

  describe "basic" do
    before do
      @empty_stream = Stream.new
      @stream = Stream.new( 43 ) { @empty_stream }
    end

    it "should return the head" do
      @stream.head.should == 43 
    end

    it "should return the tail" do
      @stream.tail.should == @empty_stream
    end
    
    it "should call the delayed tail" do
      @stream.delayed_tail.expects( :call ).once.returns( @empty_stream )
      @stream.tail
    end

    it "should store the delayed tail in a block" do
      @stream.delayed_tail.should be_kind_of Proc
    end

    it "should not be empty" do
      @stream.should_not be_empty
    end

    it "should have the correct size" do
      @stream.size.should == 1 + @stream.tail.size
    end
  end

  describe "stream with head and without tail" do
    before do
      @stream = Stream.new( 42 )
    end

    it "should return the empty stream" do
      @stream.tail.should be_empty
    end 

    it "should return a stream" do
      @stream.tail.is_a?( Stream ).should be true
    end
  end

  describe "the empty stream" do
    before do
      @empty_stream = Stream.new
    end

    it "should be empty" do
      @empty_stream.should be_empty
    end

    it "should have zero size" do
      @empty_stream.size.should == 0
    end

    it "should return nil if you access the tail" do
      @empty_stream.tail.should be_nil
    end
  end
  
  describe "infinite stream" do
    before do
      @stream = Stream.new( 1 ) { @stream }
    end

    it "should return itself" do
      @stream.stubs( :inspect ).returns( nil ) 
      @stream.tail.should === @stream
    end
  end

  describe "basic stream behaviour: " do
    before do
      @stream = Stream.new( 1 ) { Stream.new( 2 ) { Stream.new( 3 ) } }
    end

    describe "Stream#each" do
      it "should loop through each element" do
        array = []
        @stream.each do | element |
          array << element
        end

        @stream.to_a.should == array
      end
    end

    describe "Stream#map" do
      it "should add 1 to each element" do
        add_one = Proc.new { | n | n + 1 }
        new_stream = @stream.map( &add_one )
        
        new_stream.head.should == add_one.call( @stream.head ) 
        new_stream.tail.should == @stream.tail.map( &add_one )
      end
    end

    describe "Stream#select" do
      it "should select elements that return true when the predicate is applied to the element" do
        even = Proc.new { | n | ( n % 2 ).zero? }
        
        odd_starting_stream = @stream
        odd_starting_filtered_stream = odd_starting_stream.select( &even )

        odd_starting_filtered_stream.head.should_not == odd_starting_stream.head
        odd_starting_filtered_stream.should == odd_starting_stream.tail.select( &even )

        even_starting_stream = Stream.new( 0 ) { odd_starting_stream }
        even_starting_filtered_stream = even_starting_stream.select( &even )

        even_starting_filtered_stream.head.should == even_starting_stream.head
        even_starting_filtered_stream.tail.should == even_starting_stream.tail.select( &even )
      end
    end

    describe "Stream#take" do
      it "should return a stream composed of the first N elements" do
        first_two = @stream.take( 2 )
        first_two.head.should == @stream.head
        first_two.tail.should == @stream.tail.take( 1 )
      end

      it "should return an empty stream if the stream is empty" do
        Stream.new.take( 100 ).should == Stream.new
      end

      it "should return the empty stream is N is zero" do
        @stream.take( 0 ).should == Stream.new
      end
    end

    describe "Stream#at" do
      it "should raise an ArgumentError if the index is out of bounds" do
        Proc.new { Stream.new.at( 50 ) }.should raise_error( ArgumentError )
      end
      
      it "should raise an ArgumentError if there are no elements in the stream" do
        Proc.new { Stream.new.at( 0 ) }.should raise_error( ArgumentError )
      end

      it "should return the element at the Nth position" do
        @stream.at( 1 ).should == 2
      end
    end

    describe "Stream#drop" do
      it "should remove the first n elements from the array" do
        @stream.drop( 1 ).should == @stream.tail
      end

      it "should return the empty stream if the amount of elements to drop is greater than the size of the stream" do
        Stream.new.drop( 1 ).should == Stream.new
      end
    end

    describe "Stream#last" do
      it "should return the last element" do
        @stream.last.should == 3
      end

      it "should return nil if the stream is empty" do
        Stream.new.last.should be_nil
      end
    end

    describe "Stream#uniq" do
      before do
        @stream = Stream.new( 1 ) { Stream.new( 2 ) { Stream.new( 2 ) { Stream.new( 1 ) } } }
      end

      it "should remove duplicate elements" do
        @stream.uniq.should == Stream.new( 1 ) { Stream.new( 2 ) }
      end
    end

    describe "Stream#==(other)" do
      before do
        @other_stream = @stream.dup
      end
      
      it "should return false if the elements are different" do
        Stream.new.should_not == @stream
      end

      it "should return true if they have the same elements" do
        @stream.should == @other_stream
      end
    end

    describe "Stream#reject" do
      it "should remove elements which return true when the predicate is applied to the element" do
        even = Proc.new { | n | ( n % 2 ).zero? }
        odd_starting_stream = @stream
        even_starting_stream = Stream.new( 0 ) { odd_starting_stream }

        even_starting_filtered_stream = even_starting_stream.reject( &even )
        even_starting_filtered_stream.head.should_not == even_starting_stream.head
        even_starting_filtered_stream.should == even_starting_stream.tail.reject( &even )

        odd_starting_filtered_stream = odd_starting_stream.reject( &even )
        odd_starting_filtered_stream.head.should == odd_starting_stream.head
        odd_starting_filtered_stream.tail.should == odd_starting_stream.tail.reject( &even )
      end
    end

    describe "Stream#merge" do
      before do
        @ones = Stream.new( 1 ) { Stream.new( 1 ) }
        @twos = Stream.new( 2 ) { Stream.new( 2 ) }
      end
      
      it "should merge the streams by summing each pairing element and constructing a new stream" do
        threes = @ones.merge( @twos )
        threes.head.should == @ones.head + @twos.head
        
        threes.tail.should == @ones.tail.merge( @twos.tail )
      end

      it "should return the mergee if the merger is empty" do
        Stream.new.merge( @ones ).should == @ones
      end

      it "should return the merger if the mergee is empty" do
        @ones.merge( Stream.new ).should == @ones
      end
    end

    describe "Stream#take_while( &block )" do
      it "should return a stream of the elements to the point where block.call( element ) is false" do
        @stream.take_while { | n | n == 1 }.should == Stream.new( 1 )  
      end
    end

    describe "Stream#append" do
      before do
        @ones = Stream.new( 1 ) { Stream.new( 1 ) }
        @twos = Stream.new( 2 ) { Stream.new( 2 ) }
      end

      it "should append the streams" do
        appended_stream = @ones.append( @twos )
        appended_stream.head.should == @ones.head
        appended_stream.tail.should == @ones.tail.append( @twos )
      end

      it "should return the appendee if the appender is empty" do
        Stream.new.append( @ones ).should == @ones
      end

      it "should return the appender if the appendee is empty" do
        @ones.append( Stream.new ).should == @ones
      end
    end
        
    describe "Stream#include?" do
      it "should return false if the object is not an element in the stream" do
        Stream.new.should_not include( "Hello, world!" )
      end

      it "should return true if the object is an element in the stream" do
        @stream.should include( 1 )
      end
    end

    describe "Stream#to_a" do
      it "should return the elements of the stream as an array" do
        @stream.to_a.should == [ 1, 2, 3 ]
      end

      it "should return an empty array if the stream is empty" do
        Stream.new.to_a.should == []
      end
    end
        
    describe "Stream#join" do
      it "should be an empty string if the stream is empty" do
        Stream.new.join.should == ""
      end

      it "should print the head as a string if there is only one element" do
        Stream.new( 1 ).join.should == 1.to_s
      end

      it "should join the elements by the separator" do
        @stream.join( ", " ).should == "1, 2, 3"
      end
    end

    describe "Stream#any?( &block )" do
      it "should return false if the stream is empty" do
        Stream.new.any? { | n | true }.should be false
      end

      it "should return true if any of the elements return true when passed to the block" do
        @stream.any? { | n | n == 2 }.should be true
      end

      it "should return false if none of the elements return true when passed to the block" do
        @stream.any? { | n | n < -500 }.should be false
      end
    end

    describe "Stream#all?( &block )" do
      it "should return true if the stream is empty" do
        Stream.new.all? { | element | false }.should be true
      end

      it "should return true if all the elements return true when the block is applied to the element" do
        @stream.all? { | n | n > 0 }.should be true
      end

      it "should return false if any of the elements return false when the block is applied to the element" do
        @stream.all? { | n | n != 2 }.should be false
      end
    end

    describe "Stream#inspect" do
      it "should show [].to_s if the stream is empty" do
        Stream.new.inspect.should == "[]"
      end

      it "should show the elements in an array - stream.to_s.inspect" do
        @stream.inspect.should == "[1, 2, 3]"
      end
    end

    it "should cache the tail" do
      @stream.delayed_tail.expects( :call ).with.once.returns( @stream )
      2.times { @stream.tail }
    end
  end
end

describe Array, "Stream helpers" do
  before do
    @array = [ 1, 2, 3 ]
  end
  
  describe "Array#to_stream" do
    it "should convert the array to a stream" do
      @array.to_stream.should be_kind_of( Stream )
    end

    it "should fill the stream with the correct elements" do
      stream = @array.to_stream
      @array.first.should == stream.head
      @array[ 1..-1 ].to_stream.should == stream.tail
    end

    it "should return an empty stream if the array is empty" do
      [].to_stream.should == Stream.new
    end
  end
end

describe Integer, "Stream helpers" do
  describe "Integer#enumerate( step = 1, &block )" do
    it "should create an infinite stream of the natural numbers" do
      natural_numbers = 0.enumerate
      natural_numbers.head.should == 0
      natural_numbers.tail.head.should == 1
      natural_numbers.at( 30 ).should == 30
    end

    it "should return a stream" do
      2.enumerate.should be_kind_of( Stream )
    end

    it "should create an infinite stream with the difference between each element being the step passed" do
      multiples_of_5 = 0.enumerate( 5 )
      multiples_of_5.head.should == 0
      multiples_of_5.at( 5 ).should == 25
      multiples_of_5.at( 10 ).should == 50
    end
    
    it "should create an infinite stream with the difference between element being the difference between the proc applied to each element" do
      powers_of_2 = 1.enumerate { | n | n * 2 }
      powers_of_2.head.should == 1
      powers_of_2.at( 2 ).should == 4
      powers_of_2.at( 4 ).should == 16
    end

    it "should generate the next number based on the block rather than the step" do
      multiples_of_10 = 0.enumerate( 5 ) { | n | n + 10 }
      multiples_of_10.at( 0 ).should == 0
      multiples_of_10.at( 1 ).should == 10
      multiples_of_10.at( 2 ).should == 20
    end
  end

  describe "Integer#enumerate_to( value, step = 1, &block )" do
    it "should return a stream" do
      0.enumerate_to( 100 ).should be_kind_of( Stream )
    end

    it "should not contain an element less than value if the step is negative" do
      100.enumerate_to( 0, -3 ).any? { | n | n < 0 }.should_not be true
    end

    it "should not contain an element greater than value if the step is positive" do
      0.enumerate_to( 100, 3 ).any? { | n | n > 100 }.should_not be true
    end

    it "should generate the next number based on the block rather than the step" do
      stream = 0.enumerate_to( 100, 3 ) { | n | n + 11 }
      stream.head.should == 0
      stream.at( 1 ).should == 11
      stream.at( 2 ).should == 22
    end

    it "should generate the next number based on the proc passed" do
      stream = 0.enumerate_to( 100 ) { | n | n + 11 }
      stream.head == 0
      stream.at( 1 ).should == 11
      stream.at( 2 ).should == 22
    end
  end
end
