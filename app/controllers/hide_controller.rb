require 'pry'
require_relative './lsbStego.rb'
require_relative './crypto.rb'

class HideController < ApplicationController
  #include ActiveStorage::Downloading
  def start
    Hide.delete_all
    @hide = Hide.create(params.permit(:cover_image, :message))
    session[:current_id] = @hide.id
    redirect_to hide_i_path
  end
  
  def new
    @hide = Hide.find(session[:current_id])
    #binding.pry
    if params[:cover_image]
      tempfile = params[:cover_image].tempfile
      if ALLOWED_TYPES.include?(params[:cover_image].content_type)
        @hide.cover_image.attach(io: tempfile, filename: params[:cover_image].original_filename)
      end
      im = MiniMagick::Image.open(tempfile.path)
      @hide.message_cap = (im.width * im.height*2)/8
      im=nil
    end
    if params[:message]
      if params[:message].tempfile.size < (@hide.message_cap - 10)
        if !params[:pass].empty?
          salt = params[:message].tempfile.size.to_s
          Crypt.enc params[:message].tempfile, params[:pass], '81889817'
          @hide.message.attach(io: params[:message].tempfile, filename: params[:message].original_filename)
        else
          @hide.message.attach(io: params[:message].tempfile, filename: params[:message].original_filename)
        end
      end
    end
    @hide.save
    #binding.pry
  end
  
  def destroy
    Hide.delete_all
    reset_session
  end
  
  def encode
    @hide = Hide.find(session[:current_id])
    im = Stego.new(@hide.cover_image.download)
    file_name = ''
    file_name = im.encode(@hide.message.download, "stegout")
    @hide.stego_result.attach(io: File.open(file_name), filename: file_name)
    @hide.save
  end
  private
  ALLOWED_TYPES = ["image/png",
                   "image/gif",
                   "image/jpg",
                   "image/jpeg",
                   "image/bmp"]
  
end
