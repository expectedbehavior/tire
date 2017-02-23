# A buffer of strings that keeps total content size below the supplied max size.
# Automatically flushes when an additional string would exceed the buffer.
# Adapted from https://github.com/Arachni/arachni/blob/master/lib/arachni/support/buffer/autoflush.rb

class AutoFlushingBuffer
  attr_reader :max_size

  def initialize( max_size = nil, type = Array )
    @buffer    = type.new
    @max_size  = max_size
    @buffer_bytesize = 0

    @on_flush_blocks      = []
  end

  #
  # Calls {#on_push} blocks with the given object and pushes an object to the buffer.
  #
  # @param    [Object]    obj object to push
  #
  def <<( obj )
    validate_object obj
    ensure_max_buffer_size obj
    @buffer << obj
    @buffer_bytesize += obj.bytesize
    self
  end
  alias :push :<<

  # @return   [Integer]   amount of object in the buffer
  def size
    @buffer_bytesize
  end

  # @return   [Bool]  `true` if the buffer is empty, `false` otherwise
  def empty?
    @buffer.empty?
  end

  #
  # Calls {#on_flush} blocks with the buffer and then empties it.
  #
  # @return   current buffer
  #
  def flush
    buffer = @buffer.dup
    call_on_flush_blocks buffer
    buffer
  ensure
    @buffer.clear
    @buffer_bytesize = 0
  end

  # @param    [Block] block   block to call on {#flush}
  def on_flush( &block )
    @on_flush_blocks << block
    self
  end

  private
  def call_on_flush_blocks( *args )
    @on_flush_blocks.each { |b| b.call *args }
  end

  def validate_object(obj)
    unless obj.is_a? String
      raise 'Object must be a String.'
    end
    if obj.bytesize > @max_size
      raise PushLargerThanBufferException, 'Object is larger than the buffer size.'
    end
  end

  def ensure_max_buffer_size(obj)
    if !!(@max_size && (size + obj.bytesize > @max_size))
      flush
    end
  end
end

class PushLargerThanBufferException < Exception
end