#!/usr/bin/env ruby

require 'pry'
require 'benchmark'
class Integer
  #takes out the last 2 bits of numbers
  def stego_decode
    self.to_s(2).bin_pad8[-2..-1] #last 2 characters
  end
  
  def bin_sub2 bits
    raise ArgumentError if self>255
    pixel = self
    res = pixel.to_s(2).chop.chop
    return (res+=bits).to_i 2
  end
end

class String
  def bin_pad8
    raise ArgumentError,'binary string expected' unless self =~ /\A[10]+\z/
    self.prepend('0'*(8-self.size))
  end
end
class Stego #Base class
  #require 'rmagick'
  require 'mini_magick'
  STEGO_HEADER_SIZE = 6 #A2 encryption if used(ya,no), V size of message, A4 ext
  def initialize file #initializes with cover image
    @cover_image = MiniMagick::Image.read(file)
    @cover_capacity = ((@cover_image.get_pixels.flatten.size)*2)/8
  end
  
  def encode message_file, stego_file_name #initializes the secret message
    if message_file.size > @cover_capacity - STEGO_HEADER_SIZE
      raise ArgumentError, 'Message too big for given cover'
    end
    @message = message_file.unpack('B*').first
    @message_size = message_file.size
    mes_bit_str = StringIO.new(@message.prepend(stego_header))
    #binding.pry
    pixels = @cover_image.get_pixels.flatten
    pixels.map! do |pixel|
      break if (bits = mes_bit_str.read(2)).nil?
      pixel = pixel.bin_sub2 bits
    end
    write stego_file_name, pixels
  end
  
  def write stego_file_name, pixels #writes the pixels into an image
    
    type = @cover_image.type.downcase
    type = (type=='JPEG') ? 'BMP' : type
    final = MiniMagick::Image.import_pixels(pixels.pack('c*'), @cover_image.width, @cover_image.height, @cover_image.data["depth"], "rgb", type)
    res_filename = stego_file_name+"."+type
    final.write res_filename
    return res_filename
  end
  
  def decode stego_file_name
    bit_str = ''
    pixels=@cover_image.get_pixels.flatten
    header_pix_size = STEGO_HEADER_SIZE * 4
    header_bit_str = StringIO.new(pixels.shift(header_pix_size).map(&:stego_decode).join)
    encryption = [header_bit_str.read(16)].pack('B*')
    message_size = [header_bit_str.read(32)].pack('B*').unpack('V').first
    #ext = [header_bit_str.read(32)].pack('B*')
    #binding.pry
    (0...(message_size*4)).each do |ind|
      bit_str << pixels[ind].stego_decode
    end
    file_name = stego_file_name
    File.open(file_name,'wb') do |file|
      file << [bit_str].pack('B*')
    end
    return file_name
  end
  def decode_header
    bit_str = ''
    pixels = @cover_image.get_pixels.flatten
    header_pix_size = STEGO_HEADER_SIZE * 4
    header_bit_str = StringIO.new(pixels.shift(header_pix_size).map(&:stego_decode).join)
    enc = [header_bit_str.read(16)].pack('B*')
    messize = [header_bit_str.read(32)].pack('B*').unpack('V').first
    #ext = [header_bit_str.read(32)].pack('B*')
    return [enc, messize]
  end
  
  private
  def stego_header
    ['NO', @message_size].pack('A2V').unpack('B*').first
  end
  def bin_sub2 pix_byte, bit2
    return pix_byte  if bit2.nil?
    bit_string = pix_byte.to_s(2).bin_pad8
    ((bit_string.chop.chop) + bit2).to_i 2
  end
  def format_bmp3 pixels
    pixels.each_slice(3).map{|x|x.reverse}.each_slice(@cover_image.width).to_a.reverse
  end
end
