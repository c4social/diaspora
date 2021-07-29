# frozen_string_literal: true

describe TagSynonym, type: :model do
  it "normalized tags before storing" do
    tag_synonym = TagSynonym.create(synonym: "  #ToBeCleaned ", tag_name: "  #ToBeCleanStemWord ")
    expect(tag_synonym.synonym).to eq("tobecleaned")
    expect(tag_synonym.tag_name).to eq("tobecleanstemword")
  end
end
