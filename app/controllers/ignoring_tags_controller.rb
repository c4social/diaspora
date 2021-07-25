# frozen_string_literal: true

class IgnoringTagsController < ApplicationController
  before_action :authenticate_user!

  def index
    @ignoring_tags = IgnoringTag.all.order(:name)
    @new_tag_prototype = IgnoringTag.new
    render "admins/tags_board"
  end

  def destroy
    tag = IgnoringTag.find(params[:id])
    tag.destroy
    redirect_to ignoring_tags_path
  end

  def create
    IgnoringTag.create(tag_params)
    redirect_to ignoring_tags_path
  end

  private

  def tag_params
    params.require(:ignoring_tag).permit(:name)
  end
end
