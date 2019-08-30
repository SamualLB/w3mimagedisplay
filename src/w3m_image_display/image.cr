class W3MImageDisplay::Image

  @drawn = false # If it is a redraw
  @index_plus_one : Int32 # 0 is not a valid image number
  @path : String # Path to image file

  @previous_size : {Int32, Int32, Int32, Int32}? # Stored for clearing

  def initialize(@path)
    @index_plus_one = W3MImageDisplay.images.size + 1
    W3MImageDisplay.images << self
  end

  # Draw using terminal columns and lines
  #
  # Starting cell, then max size
  #
  # Stretch determines if the image should be made to fit the box
  #
  # `centre` determines if space should be added around the image
  # if it is made smaller
  def draw(x, y, w, h, stretch = true, centre = true)
    font_w, font_h = W3MImageDisplay.font_size
    size_x, size_y = size
    x *= font_w
    y *= font_h
    w *= font_w
    h *= font_h
    # Resize to original size if needed
    unless stretch
      new_w = w.clamp(0, size_x)
      x += (w - new_w) / 2 if centre
      w = new_w
      new_h = h.clamp(0, size_y)
      y += (h - new_h) / 2 if centre
      h = new_h
    end
    ratio = size_x.to_f / size_y.to_f
    if h*ratio > w
      new_h = (w.to_f / ratio).to_i
      y += (h - new_h) / 2 if centre
      h = new_h
    elsif w/ratio > h
      new_w = (h.to_f * ratio).to_i
      x += (w - new_w) / 2 if centre
      w = new_w
    end
    draw_pixel(x, y, w, h)
  end

  # Draw using pixels
  def draw_pixel(x, y, w, h)
    num = @drawn ? "1" : "0"
    W3MImageDisplay.proc.input.puts "#{num};#{@index_plus_one};#{x};#{y};#{w};#{h};;;;;#{@path}\n"
    @drawn = true
    @previous_size = {x, y, w, h}
    self
  end

  def sync
    W3MImageDisplay.sync
    self
  end

  def sync_communication
    W3MImageDisplay.sync_communication
    self
  end

  # Size of the image file
  def size
    W3MImageDisplay.image_size(@path)
  end

  # Remove the image
  def clear
    return unless (size = @previous_size)
    W3MImageDisplay.clear(*size)
  end
end
