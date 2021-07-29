# frozen_string_literal: true

class IgnoringTagsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    tag = IgnoringTag.find(params[:id])
    tag.destroy
    redirect_to admin_tags_path
  end

  def create
    IgnoringTag.create(tag_params)
    redirect_to admin_tags_path
  end

  private

  def tag_params
    params.require(:ignoring_tag).permit(:name)
  end
end
