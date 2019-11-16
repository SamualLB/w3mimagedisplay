require "./w3m_image_display/*"

module W3MImageDisplay
  VERSION = "0.1.2"

  BINARY_PATHS = ["/usr/lib/w3m/w3mimgdisplay", "/usr/libexec/w3m/w3mimgdisplay", "/usr/lib64/w3m/w3mimgdisplay", "/usr/libexec64/w3m/w3mimgdisplay", "/usr/local/libexec/w3m/w3mimgdisplay"]

  @@images = [] of Image
  @@proc : Process? = nil

  # Get the process, and start it if uninitialised
  def self.start : Process
    proc = @@proc
    return proc if proc && proc.exists? && !proc.terminated?
    @@proc = Process.new(find_binary_path, input: Process::Redirect::Pipe, output: Process::Redirect::Pipe)
  end

  protected def self.images
    @@images
  end

  protected def self.proc : Process
    return @@proc.not_nil! if @@proc
    start
  end

  # Path of the binary file
  private def self.find_binary_path : String
    paths = [ENV["W3MIMGDISPLAY_ENV"]?] + BINARY_PATHS
    paths.each do |path|
      return path if path && File.exists?(path)
    end
    raise "w3mimgdisplay executable file not found, use W3MIMGDISPLAY_ENV environment variable to set manually"
  end

  # Clear the pixels, used by `Image#clear`
  def self.clear(x, y, w, h)
    proc.input.puts "6;#{x};#{y};#{w};#{h}\n"
  end

  # The size of the terminal window measured in pixels {x, y}
  def self.pixel_size : {Int32, Int32}
    proc = Process.new(find_binary_path, ["-test"], output: Process::Redirect::Pipe)
    out = proc.output.gets.as(String)
    x, y = out.split(' ')
    {x.to_i, y.to_i}
  end

  # Horizontal cells / width / columns
  def self.width
    `tput cols`.to_i
  end

  # Vertical cells / height / lines
  def self.height
    `tput lines`.to_i
  end

  # The size of the terminal window in columns and lines {x, y}
  def self.size : {Int32, Int32}
    {width, height}
  end

  # The pixel size of the font {x, y}
  def self.font_size : {Int32, Int32}
    pix = pixel_size
    siz = size
    {(pix[0] + 2) // siz[0], (pix[1] + 2) // siz[1]}
  end

  def self.sync
    proc.input.puts "3;\n"
  end

  def self.sync_communication
    proc.input.puts "4;\n"
    proc.output.gets # Read \n
  end

  # The width and height of an image file
  def self.image_size(path) : {Int32, Int32}
    proc.input.puts "5;#{path}\n"
    x, y = proc.output.gets.as(String).split ' '
    {x.to_i, y.to_i}
  end

  # Prevent future images being drawn
  #
  # Does not seem to work in xterm
  #
  # TODO: Raise when this is set?
  def self.terminate
    proc.input.puts "2;\n"
  end
end
