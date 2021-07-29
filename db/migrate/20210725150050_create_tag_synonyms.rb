# frozen_string_literal: true

class CreateTagSynonyms < ActiveRecord::Migration[5.2]
  def change
    create_table :tag_synonyms do |t|
      t.string :synonym, null: false
      t.string :tag_name, null: false

      t.timestamps
    end
    add_index :tag_synonyms, :synonym, unique: true
    add_index :tag_synonyms, :tag_name
  end
end
