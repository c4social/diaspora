# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StreamsController < ApplicationController
  before_action :authenticate_user!, except: :public
  before_action :save_selected_aspects, :only => :aspects

  layout proc { request.format == :mobile ? "application" : "with_header" }

  respond_to :html,
             :mobile,
             :json

  def aspects
    aspect_ids = (session[:a_ids] || [])
    @stream = Stream::Aspect.new(current_user, aspect_ids,
                                 :max_time => max_time)
    stream_responder
  end

  def public
    stream_responder(Stream::Public)
  end

  def local_public
    if AppConfig.local_posts_stream?(current_user)
      stream_responder(Stream::LocalPublic)
    else
      head :not_found
    end
  end

  def activity
    stream_responder(Stream::Activity)
  end

  def multi
    if current_user.getting_started
      gon.preloads[:getting_started] = true
      inviter = current_user.invited_by.try(:person)
      gon.preloads[:mentioned_person] = {name: inviter.name, handle: inviter.diaspora_handle} if inviter
    end

    stream_responder(Stream::Multi)
  end

  def commented
    stream_responder(Stream::Comments)
  end

  def liked
    stream_responder(Stream::Likes)
  end

  def mentioned
    stream_responder(Stream::Mention)
  end

  def followed_tags
    gon.preloads[:tagFollowings] = tags
    stream_responder(Stream::FollowedTag)
  end

  private

  def stream_responder(stream_klass=nil)

    if stream_klass.present?
      @stream ||= stream_klass.new(current_user, :max_time => max_time)
    end

    @popular_tags = popular_tags
    respond_with do |format|
      format.html { render 'streams/main_stream' }
      format.mobile { render 'streams/main_stream' }
      format.json { render :json => @stream.stream_posts.map {|p| LastThreeCommentsDecorator.new(PostPresenter.new(p, current_user)) }}
    end
  end

  def save_selected_aspects
    if params[:a_ids].present?
      session[:a_ids] = params[:a_ids]
    end
  end

  # Returns popular public tags by tags used in a timespan, only one count per pos creator
  # Prohibites flooding tags from mass uploading bots
  def popular_tags
    time_span = Time.zone.today - 1.day
    ActsAsTaggableOn::Tagging.find_by_sql "select count(*) as count, t.name from
          (select tags.name, posts.author_id from taggings
            left join tags on taggings.tag_id = tags.id
            left join posts on posts.id = taggable_id
            where taggable_type = 'Post' and posts.created_at >= '#{time_span}'
            and posts.public = true
            group by tags.name, author_id order by tags.name asc) as t group by t.name
            order by count desc
            limit 10"
  end
end
