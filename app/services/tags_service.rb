# frozen_string_literal: true

class TagsService
  # Returns array of popular public tags and its count used in a timespan, only one count per post creator
  # Prohibits flooding tags from mass uploading bots
  def popular_tags
    time_span = Time.zone.today - 1.day
    ActsAsTaggableOn::Tagging.find_by_sql "select count(*) as count, t.name from
          (select tags.name, posts.author_id from taggings
            left join tags on taggings.tag_id = tags.id
            left join posts on posts.id = taggable_id
            where taggable_type = 'Post' and posts.created_at >= '#{time_span}'
            and posts.public = true
            and not exists (Select 1 from ignoring_tags as it where it.name = tags.name)
            group by tags.name, author_id order by tags.name asc) as t group by t.name
            order by count desc
            limit 10"
  end
end
