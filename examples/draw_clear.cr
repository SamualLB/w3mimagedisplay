require "../src/w3m_image_display"

img = W3MImageDisplay::Image.new("examples/image.jpg")

img.draw(0, 0, W3MImageDisplay.width, 10).sync.sync_communication

sleep 1

img.clear
