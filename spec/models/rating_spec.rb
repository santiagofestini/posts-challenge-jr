require "rails_helper"

RSpec.describe Rating, type: :model do
  describe "validations" do
    it { is_expected.to belong_to(:post) }
    it { is_expected.to belong_to(:user) }

    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_inclusion_of(:value).in_range(1..5) }

    describe "#uniqueness" do
      subject { create :rating }

      it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:post_id).with_message("can only rate a post once") }
    end
  end
end
