require_relative "./lsbStego.rb"
class SeekController < ApplicationController
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
      enc, messize = Stego.new(@seek.stego.download).decode_header
      @seek.enc = (enc=="YA") ? true : false
      @seek.messize = messize
    end
    @seek.save
  end
  
  def decode
    @seek = Seek.find(session[:current_id])
    im = Stego.new(@seek.stego.download)
    file_name = im.decode 'resout'
    @seek.message.attach(io: File.open(file_name),filename: file_name)
    @seek.save
  end
  private
  ALLOWED_TYPES = ["image/png",
                   "image/gif",
                   "image/jpg",
                   "image/jpeg",
                   "image/bmp"]
end
