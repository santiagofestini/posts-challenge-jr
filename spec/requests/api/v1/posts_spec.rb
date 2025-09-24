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

    shared_examples "returns validation errors" do |field, error_message|
      it "returns validation errors for #{field}" do
        make_request(invalid_params)

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response["errors"]).to include(error_message)
      end
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
        let(:invalid_params) { valid_params.except(:title) }
        it_behaves_like "returns validation errors", "title", "Title can't be blank"
      end

      context "when body is missing" do
        let(:invalid_params) { valid_params.merge(body: "") }
        it_behaves_like "returns validation errors", "body", "Body can't be blank"
      end

      context "when ip is missing" do
        let(:invalid_params) { valid_params.merge(user_ip: "") }
        it_behaves_like "returns validation errors", "ip", "Ip can't be blank"
      end

      context "when user_login is missing" do
        let(:invalid_params) { valid_params.merge(user_login: "") }
        it_behaves_like "returns validation errors", "user_login", "Login can't be blank"
      end

      context "when multiple fields are invalid" do
        it "returns all validation errors" do
          invalid_params = valid_params.merge(title: "", body: "", user_ip: "")
          make_request(invalid_params)

          expect(response).to have_http_status(:unprocessable_content)
          expect(json_response["errors"]).to include(
            "Title can't be blank",
            "Body can't be blank",
            "Ip can't be blank"
          )
        end
      end
    end
  end
end
