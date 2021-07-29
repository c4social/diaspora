# frozen_string_literal: true

class TagSynonym < ApplicationRecord
  before_validation :normalize
  validates :tag_name, presence: true
  validates :synonym, presence: true, uniqueness: true

  def self.find_by_synonym(synonym_tag)
    TagSynonym.find_by(synonym: normalize_name(synonym_tag))
  end

  def normalize_name(tag)
    tag = tag.downcase.strip
    tag = tag[1..] if tag[0] == "#"
    tag
  end

  private

  def normalize
    self.tag_name = normalize_name(tag_name)
    self.synonym = normalize_name(synonym)
  end
end
