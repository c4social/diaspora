# frozen_string_literal: true

class TagSynonymsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    tag = TagSynonym.find(params[:id])
    tag.destroy
    redirect_to admin_tags_path
  end

  def create
    TagSynonym.create(tag_params)
    redirect_to admin_tags_path
  end

  private

  def tag_params
    params.require(:tag_synonym).permit(:tag_name, :synonym)
  end
end
