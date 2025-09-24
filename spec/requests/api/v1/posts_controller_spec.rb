require "rails_helper"

RSpec.describe "Api::V1::Posts", type: :request do
  describe "POST /api/1/posts" do
    let(:endpoint) { "/api/1/posts" }
    let(:valid_params) do
      {
        title: "Test Post Title",
        body: "This is the body of the test post",
        user_login: "testuser",
        user_ip: "192.168.1.100"
      }
    end
    let(:json_response) { JSON.parse(response.body) }

    def make_request(params = valid_params)
      post endpoint, params:
    end

    shared_examples "successful post creation response" do
      it "returns correct JSON structure" do
        expect(response).to have_http_status(:created)
        expect(json_response["post"]).to include(
          "id" => be_present,
          "title" => "Test Post Title",
          "body" => "This is the body of the test post",
          "ip" => "192.168.1.100",
          "user_id" => be_present,
          "user" => {
            "id" => be_present,
            "login" => "testuser"
          }
        )
      end
    end

    context "with valid parameters" do
      context "when user doesn't exist" do
        it "creates a new user and post" do
          expect {
            make_request
          }.to change(User, :count).by(1).and change(Post, :count).by(1)
        end

        it_behaves_like "successful post creation response" do
          before { make_request }
        end
      end

      context "when user already exists" do
        let!(:existing_user) { create(:user, login: "testuser") }

        it "uses existing user and creates new post" do
          expect {
            make_request
          }.to change(User, :count).by(0).and change(Post, :count).by(1)

          expect(json_response["post"]["user"]["id"]).to eq(existing_user.id)
        end

        it_behaves_like "successful post creation response" do
          before { make_request }
        end
      end
    end

    context "with invalid parameters" do
      context "when title is missing" do
        before { make_request(valid_params.except(:title)) }
        it_behaves_like "returns validation errors", "Title can't be blank"
      end

      context "when body is missing" do
        before { make_request(valid_params.merge(body: "")) }
        it_behaves_like "returns validation errors", "Body can't be blank"
      end

      context "when ip is missing" do
        before { make_request(valid_params.merge(user_ip: "")) }
        it_behaves_like "returns validation errors", "Ip can't be blank"
      end

      context "when user_login is missing" do
        before { make_request(valid_params.merge(user_login: "")) }
        it_behaves_like "returns validation errors", "Login can't be blank"
      end

      context "when multiple fields are invalid" do
        before { make_request(valid_params.merge(title: "", body: "", user_ip: "")) }
        it_behaves_like "returns validation errors", [
          "Title can't be blank",
          "Body can't be blank",
          "Ip can't be blank"
        ]
      end
    end
  end

  describe "GET /api/1/posts/top" do
    let(:top_endpoint) { "/api/1/posts/top" }

    def make_top_request(params = {})
      get top_endpoint, params:
    end

    context "with valid parameters" do
      context "when there are posts with ratings" do
        let!(:post1) { create(:post, title: "Best Post", body: "Great content", ratings_sum: 10, ratings_count: 2) }
        let!(:post2) { create(:post, title: "Good Post", body: "Nice content", ratings_sum: 8, ratings_count: 2) }
        let!(:post3) { create(:post, title: "OK Post", body: "Average content", ratings_sum: 6, ratings_count: 3) }

        it "returns the top posts by rating" do
          make_top_request(limit: 2)

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq({
            "posts" => [
              { "id" => post1.id, "title" => "Best Post", "body" => "Great content" },
              { "id" => post2.id, "title" => "Good Post", "body" => "Nice content" }
            ]
          })
        end

        context "when limit is nil" do
          it "returns all posts sorted by rating" do
            make_top_request(limit: nil)

            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body)).to eq({
              "posts" => [
                { "id" => post1.id, "title" => "Best Post", "body" => "Great content" },
                { "id" => post2.id, "title" => "Good Post", "body" => "Nice content" },
                { "id" => post3.id, "title" => "OK Post", "body" => "Average content" }
              ]
            })
          end
        end
      end

      context "when there are no posts with ratings" do
        let!(:post1) { create(:post, title: "Best Post", body: "Great content") }
        let!(:post2) { create(:post, title: "Good Post", body: "Nice content") }

        it "returns an empty array" do
          make_top_request(limit: 2)
        end
      end
    end

    context "with invalid parameters" do
      context "when limit is not a number" do
        it "returns an error" do
          make_top_request(limit: "not a number")
          expect(response).to have_http_status(:unprocessable_content)
          expect(JSON.parse(response.body)).to eq({
            "errors" => "invalid value for Integer(): \"not a number\""
          })
        end
      end
    end
  end
end
