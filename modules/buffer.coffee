# A string buffer class
class Buffer

  # Create a new buffer
  constructor: (str=null) ->
    @buffer = []
    @buffer.push(str) if str

  # Add a string to the buffer
  add: (str) ->
    @buffer.push(str)

  # Add another buffer's contents to the end of this buffer
  addBuffer: (buffer) ->
    for str in buffer.buffer
      @buffer.push(str)

  # Clear the buffer
  clear: ->
    @buffer = []

  # Check if buffer is empty
  isEmpty: ->
    return @buffer.length is 0

  # Convert the buffer's contents to a string
  toString: ->
    return @buffer.join('')

# Export buffer class
module.exports =
  Buffer: Buffer
