# frozen_string_literal: true

class CreateIgnoringTags < ActiveRecord::Migration[5.2]
  def change
    create_table :ignoring_tags do |t|
      t.string :name
      t.timestamps
    end
    add_index :ignoring_tags, :name, unique: true
  end
end
