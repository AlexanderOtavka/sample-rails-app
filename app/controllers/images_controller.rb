require 'fastimage'

class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy]

  # GET /images
  # GET /images.json
  def index
    index_params = params.permit(:page).reverse_merge({
      :page => 1 # pagination index starts at 1, not 0
    })

    @images = Image.order(created_at: :desc)
      .page(index_params[:page])
      .per(10)
    @images.each do |image|
      maybe_update_aspect_ratio image
    end
  end

  # GET /images/1
  # GET /images/1.json
  def show
    maybe_update_aspect_ratio @image
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  # POST /images.json
  def create
    @image = Image.new(image_params)
    @image.user_token = @user_token

    respond_to do |format|
      params_hash = image_params
      if not params_hash[:aspect_ratio]
        @image.errors.add(:url, "Must be a valid URL to an image")
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      elsif @image.save
        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    respond_to do |format|
      params_hash = image_params
      if @user_token != @image.user_token
        message = "You cannot edit images that aren't yours."
        format.html { redirect_to @image, notice: message }
        format.json { render json: { message: message }, status: :unauthorized }
      elsif not params_hash[:aspect_ratio]
        @image.errors.add(:url, "Must be a valid URL to an image")
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      elsif @image.update(params_hash)
        format.html { redirect_to @image, notice: 'Image was successfully updated.' }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    respond_to do |format|
      if @user_token != @image.user_token
        message = "You cannot remove images that aren't yours."
        format.html { redirect_to @image, notice: message }
        format.json { render json: { message: message }, status: :unauthorized }
      else
        @image.destroy
        format.html { redirect_to images_url, notice: 'Image was successfully removed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_params
      raw_image_params = params.require(:image)
      raw_image_params.permit(:title, :url).merge({
        :aspect_ratio => image_aspect_ratio(raw_image_params[:url])
      })
    end

    def maybe_update_aspect_ratio(image)
      if not image.aspect_ratio
        aspect_ratio = image_aspect_ratio(image.url)
        if aspect_ratio
          image.aspect_ratio = aspect_ratio
          image.save!
        end
      end
    end

    def image_aspect_ratio(url)
      width, height = FastImage.size url
      if width and height
        width.to_f / height
      else
        nil
      end
    end
end
