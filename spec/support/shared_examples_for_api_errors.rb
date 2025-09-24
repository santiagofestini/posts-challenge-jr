RSpec.shared_examples "returns validation errors" do |expected_errors|
  it "returns unprocessable_content status" do
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "returns error messages in JSON" do
    json_response = JSON.parse(response.body)
    expect(json_response).to have_key("errors")

    Array(expected_errors).each do |error_message|
      expect(json_response["errors"]).to include(error_message)
    end
  end
end
