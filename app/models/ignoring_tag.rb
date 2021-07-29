# frozen_string_literal: true

class IgnoringTag < ApplicationRecord
  before_validation :normalize_tag
  validates :name, presence: true, uniqueness: true

  private

  def normalize_tag
    self.name = name.downcase.strip
    self.name = name[1..] if name[0] == "#"
  end
end
