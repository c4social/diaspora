# frozen_string_literal: true

class TagsService
  def popular_tags_aligned
    tags_collection = []
    popular_tags_simplified.each do |synonym|
      tags_collection.push(Tag.new(synonym[1][:stem_word], synonym[1][:count]))
    end
    tags_collection.sort_by(&:count).reverse.take(10)
  end

  def popular_tags_simplified
    tags_and_synonyms = {}
    popular_tags.each do |tag|
      existing_tag_synonym = TagSynonym.find_by(synonym: tag[:name])
      if existing_tag_synonym.present?
        add_synonym(tags_and_synonyms, tag, existing_tag_synonym)
      else
        add_tag(tags_and_synonyms, tag)
      end
    end
    tags_and_synonyms
  end

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
            limit 50"
  end

  class Tag
    attr_reader :name, :count

    def initialize(tag_name, count)
      @name = tag_name
      @count = count
    end
  end

  private

  def add_synonym(aligned_tag_list, tag, existing_tag_synonym)
    stem_word = existing_tag_synonym.tag_name
    aligned_tag_list[stem_word] = {} unless aligned_tag_list.has_key?(stem_word)
    # A synonym is added with half value. Posts might use many synonyms.Dont ignore them, dont let them count double
    aligned_tag_list[stem_word] = {stem_word: existing_tag_synonym.tag_name, # more common tag (stem word)
                                   count:     [aligned_tag_list[stem_word][:count] || 1, (tag[:count]) * 0.5].max}
  end

  # Add as a normal tag if stem word or unknown as synonym
  def add_tag(aligned_tag_list, tag)
    aligned_tag_list[tag[:name]] = {stem_word: tag[:name],
                                    count:     tag[:count]}
  end
end
