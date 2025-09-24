require "rails_helper"

RSpec.describe Post, type: :model do
  describe "validations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:ratings).dependent(:destroy) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:ip) }
  end

  describe "#average_rating" do
    let(:post) { create(:post) }

    context "when post has no ratings" do
      it "returns 0.0" do
        expect(post.average_rating).to eq(0.0)
      end
    end

    context "when post has ratings" do
      it "calculates correct average from ratings_sum and ratings_count" do
        post.update!(ratings_sum: 15, ratings_count: 3)

        expect(post.average_rating).to eq(5.0)
      end
    end
  end
end
