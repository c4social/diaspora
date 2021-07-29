# frozen_string_literal: true

describe IgnoringTag, type: :model do
  it "normalized tags before storing" do
    ignored_tag = IgnoringTag.create(name: "   #To_Be_Ignored  ")
    expect(ignored_tag.name).to eq("to_be_ignored")
  end
end
