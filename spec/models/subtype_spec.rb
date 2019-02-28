require 'rails_helper'

RSpec.describe Subtype, type: :model do
  it { should validate_presence_of(:name) }
  it { should belong_to(:subject) }
  it { should belong_to(:parent) }
  it { should have_many(:children) }

  context 'with a self-referential association' do
    let(:subject){ FactoryBot.create(:subject, name: :bear) }
    let(:parent_subtype){ FactoryBot.create(:subtype, subject: subject, name: :brown) }
    let(:child_subtype){ FactoryBot.create(:subtype, subject: subject, parent: parent_subtype, name: :grizzly) }

    it 'can nest subtypes down the chain' do
      expect(parent_subtype.parent).to eq(nil)
      expect(parent_subtype.children).to eq([child_subtype])
      expect(child_subtype.parent).to eq(parent_subtype)
      expect(child_subtype.children).to eq([])
    end
  end
end
