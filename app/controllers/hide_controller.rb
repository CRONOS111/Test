require 'pry'
require_relative '../../../project/lsbStego.rb'
class HideController < ApplicationController
  def start
    @hide = Hide.create(params.permit(:cover_image, :message))
    session[:current_id] = @hide.id
    redirect_to hide_i_path
  end
  
  def new
    @hide = Hide.find(session[:current_id])
    #binding.pry
    if params[:cover_image]
    path = params[:cover_image].tempfile
      if params[:cover_image].content_type=~ /(jpeg\Z|png\Z|bmp\Z)/
        @hide.cover_image.attach(io: path, filename: params[:cover_image].original_filename)
      end
      binding.pry
      @hide.message_cap = path.size
    end
    if params[:message]
      if params[:message].tempfile.size < (@hide.message_cap - 8)
        @hide.message.attach(io: params[:message].tempfile, filename: params[:message].original_filename)
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
    file_name = im.encode(@hide.message.download, "stegout")
    @hide.stego_result.attach(io: File.open(file_name), filename: file_name)
  end
  private
  
  def valid_cover? file_io
    begin
      MiniMagick::Image.read(file_io).valid?
    rescue
      return false
    end
    return true
  end
end
