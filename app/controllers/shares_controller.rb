class SharesController < ApplicationController
  before_action :set_share, only: [ :show, :edit, :update ]
  before_action :verify_owner, only: [ :edit, :update ]

  def show
  end

  def new
    @share = Share.new
  end

  def create
    @share = Share.new(share_params_create)
    @share.has_files = params[:share][:files].present?

    if @share.save
      cookies["owner_#{@share.slug}"] = {
        value: @share.edit_token,
        expires: 30.days.from_now
      }
      redirect_to share_path(@share.slug)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if params[:remove_files].present?
      params[:remove_files].each do |file_id|
        file = @share.files.find(file_id)
        file.purge
      end
    end

    @share.has_files = params[:share][:files].present? || @share.files.attached?

    if @share.update(share_params_update)
      redirect_to share_path(@share.slug), notice: "Share updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_share
    @share = Share.find_by!(slug: params[:slug])
  end

  def verify_owner
    unless cookies["owner_#{@share.slug}"] == @share.edit_token
      redirect_to share_path(@share.slug), alert: "You don't have permission to edit this share"
    end
  end

  def share_params_create
    params.require(:share).permit(:slug, :content, files: [])
  end

  def share_params_update
    params.require(:share).permit(:content, files: [])
  end
end
