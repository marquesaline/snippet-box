class SharesController < ApplicationController
  def new
    @share = Share.new
  end

  def create
    @share = Share.new(share_params)
    @share.has_files = params[:share][:files].present?
    if @share.save
      cookies["owner_#{@share.slug}"] = {
        value: @share.edit_token,
        expires: 30.days.from_now
      } 
      redirect_to slug_path(@share.slug)
    else 
      render :new, status: :unprocessable_entity 
    end
  end

  private 

  def share_params
    params.require(:share).permit(:slug, :content, files: [])
  end
end
