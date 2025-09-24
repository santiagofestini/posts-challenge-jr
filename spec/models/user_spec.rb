require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it { is_expected.to have_many(:posts).dependent(:destroy) }
    it { is_expected.to have_many(:ratings).dependent(:destroy) }

    it { is_expected.to validate_presence_of(:login) }

    describe "#uniqueness" do
      subject { create :user }

      it { is_expected.to validate_uniqueness_of(:login) }
    end
  end
end
