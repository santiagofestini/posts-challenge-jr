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

  describe ".top_by_rating" do
    context "when there are no posts with ratings" do
      before do
        create_list(:post, 3)
      end

      it "returns empty result" do
        expect(Post.top_by_rating(10)).to be_empty
      end
    end

    context "when there are posts with ratings" do
      let!(:post1) { create(:post, title: "Best Post", ratings_sum: 9, ratings_count: 2) }
      let!(:post2) { create(:post, title: "Good Post", ratings_sum: 12, ratings_count: 3) }
      let!(:post3) { create(:post, title: "OK Post", ratings_sum: 6, ratings_count: 2) }
      let!(:post4) { create(:post, title: "No Ratings", ratings_sum: 0, ratings_count: 0) }

      it "returns only posts with ratings" do
        results = Post.top_by_rating(10)
        expect(results).not_to include(post4)
        expect(results.size).to eq(3)
      end

      it "orders posts by calculated average rating desc" do
        results = Post.top_by_rating(10)

        expect(results[0]).to eq(post1)
        expect(results[1]).to eq(post2)
        expect(results[2]).to eq(post3)
      end

      it "respects the limit parameter" do
        results = Post.top_by_rating(2)

        expect(results.size).to eq(2)
        expect(results[0]).to eq(post1)
        expect(results[1]).to eq(post2)
      end

      it "handles limit larger than available posts" do
        results = Post.top_by_rating(100)

        expect(results.size).to eq(3)
      end
    end
  end

  describe ".with_shared_ips" do
    context "when no posts exist" do
      it "returns an empty array" do
        expect(Post.with_shared_ips.to_a).to eq([])
      end
    end

    context "when posts exist with different scenarios" do
      let(:login1) { "Stan" }
      let(:login2) { "Kyle" }
      let(:login3) { "Eric" }
      let(:ip1) { "192.168.1.1" }
      let(:ip2) { "10.0.0.1" }
      let(:ip3) { "172.16.0.1" }

      let!(:user1) { create(:user, login: login1) }
      let!(:user2) { create(:user, login: login2) }
      let!(:user3) { create(:user, login: login3) }

      let!(:shared_ip_post1) { create(:post, user: user1, ip: ip1) }
      let!(:shared_ip_post2) { create(:post, user: user2, ip: ip1) }
      let!(:shared_ip_post3) { create(:post, user: user3, ip: ip1) }

      let!(:another_shared_ip_post1) { create(:post, user: user1, ip: ip2) }
      let!(:another_shared_ip_post2) { create(:post, user: user2, ip: ip2) }

      let!(:single_user_ip_post) { create(:post, user: user1, ip: ip3) }

      it "returns only IPs with multiple different authors" do
        result = Post.with_shared_ips.to_a

        expect(result.size).to eq(2)

        shared_ip_result = result.find { |item| item.ip == ip1 }
        expect(shared_ip_result.author_logins).to contain_exactly(login1, login2, login3)

        another_shared_ip_result = result.find { |item| item.ip == ip2 }
        expect(another_shared_ip_result.author_logins).to contain_exactly(login1, login2)
      end

      it "excludes IPs with only one author" do
        result = Post.with_shared_ips.to_a

        ip_addresses = result.map { |item| item.ip }
        expect(ip_addresses).not_to include(ip3)
        expect(ip_addresses).not_to include(ip3)
      end

      it "handles multiple posts by same user from same IP correctly" do
        create(:post, user: user1, ip: ip1)

        result = Post.with_shared_ips.to_a
        shared_ip_result = result.find { |item| item.ip == ip1 }

        expect(shared_ip_result.author_logins).to contain_exactly(login1, login2, login3)
      end
    end
  end
end
