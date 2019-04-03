require_relative "./lsbStego.rb"
require_relative "./crypto.rb"
class SeekController < ApplicationController
  $pass = ''
  def start
    Seek.delete_all
    @seek = Seek.create(params.permit(:stego))
    session[:current_id]=@seek.id
    redirect_to seek_i_path
  end
  def new
    @seek = Seek.find(session[:current_id])
    if params[:stego]
      tempfile = params[:stego].tempfile
      if ALLOWED_TYPES.include?(params[:stego].content_type)
        @seek.stego.attach(io: tempfile, filename: params[:stego].original_filename)
      end
      messize = Stego.new(@seek.stego.download).decode_header
      if params[:pass]
      $pass = params[:pass]
      end
      @seek.messize = messize
      #binding.pry
    end
    @seek.save
  end
  
  def decode
    @seek = Seek.find(session[:current_id])
    im = Stego.new(@seek.stego.download)
    file_name = im.decode 'resout'
    file = File.open file_name
    #binding.pry
    if !$pass.empty?
      file = File.open file_name
      salt = file.size.to_s
      Crypt.dec file, $pass, '81889817'
      @seek.message.attach(io: file,filename: file_name)
    else
      @seek.message.attach(io: file,filename: file_name)
    end
    @seek.save
  end
  private
  ALLOWED_TYPES = ["image/png",
                   "image/gif",
                   "image/jpg",
                   "image/jpeg",
                   "image/bmp"]
end
