require "rails_helper"

RSpec.describe Post, type: :model do
  describe "validations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:ratings).dependent(:destroy) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:ip) }
  end
end
