# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AdminTagsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_moderator

  def index
    @ignoring_tags = IgnoringTag.all.order(:name)
    @new_tag_prototype = IgnoringTag.new
    @synonyms = TagSynonym.all.order(:synonym)
    @synonyms_prototype = TagSynonym.new
    render "admins/tags/index"
  end
end
