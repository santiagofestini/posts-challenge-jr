require "rails_helper"

RSpec.describe "Api::V1::Ratings", type: :request do
  describe "POST /api/v1/ratings" do
    let(:user) { create(:user) }
    let(:target_post) { create(:post) }
    let(:endpoint) { "/api/1/ratings" }

    def make_request(params = valid_params)
      post endpoint, params:
    end

    context "with valid parameters" do
      let(:valid_params) do
        {
          post_id: target_post.id,
          user_id: user.id,
          value: 4
        }
      end

      it "creates a rating successfully" do
        expect {
          make_request
        }.to change(Rating, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "updates post counters" do
        make_request

        target_post.reload
        expect(target_post.ratings_sum).to eq(4)
        expect(target_post.ratings_count).to eq(1)
      end

      it "returns correct average rating" do
        make_request

        json_response = JSON.parse(response.body)
        expect(json_response).to eq({ "average_rating" => 4.0 })
      end

      context "when post already has ratings" do
        let!(:existing_rating) { create(:rating, post: target_post, value: 2) }
        before do
          target_post.update!(ratings_sum: 2, ratings_count: 1)
        end

        it "calculates correct average" do
          make_request

          json_response = JSON.parse(response.body)
          expect(json_response["average_rating"]).to eq(3.0)
        end
      end
    end

    context "with invalid parameters" do
      context "missing post_id" do
        before { make_request({ user_id: user.id, value: 4 }) }
        it_behaves_like "returns validation errors", "Post must exist"
      end

      context "missing user_id" do
        before { make_request({ post_id: target_post.id, value: 4 }) }
        it_behaves_like "returns validation errors", "User must exist"
      end

      context "missing value" do
        before { make_request({ post_id: target_post.id, user_id: user.id }) }
        it_behaves_like "returns validation errors", "Value can't be blank"
      end

      context "value out of range" do
        before { make_request({ post_id: target_post.id, user_id: user.id, value: 10 }) }
        it_behaves_like "returns validation errors", "Value is not included in the list"
      end

      context "value below range" do
        before { make_request({ post_id: target_post.id, user_id: user.id, value: 0 }) }
        it_behaves_like "returns validation errors", "Value is not included in the list"
      end

      context "user already rated this post" do
        before do
          create(:rating, post: target_post, user:, value: 3)
          make_request({ post_id: target_post.id, user_id: user.id, value: 4 })
        end
        it_behaves_like "returns validation errors", "User can only rate a post once"
      end

      context "non-existent post" do
        before { make_request({ post_id: 99999, user_id: user.id, value: 4 }) }
        it_behaves_like "returns validation errors", "Post must exist"
      end

      context "non-existent user" do
        before { make_request({ post_id: target_post.id, user_id: 99999, value: 4 }) }
        it_behaves_like "returns validation errors", "User must exist"
      end
    end
  end
end
