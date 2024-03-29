require 'rails_helper'
require 'factory_bot'
require 'fuzzbert'


RSpec.describe "/uploads", type: :request do
  
  path = Rails.root + "app/assets/test_zip/rus.zip"
  path_fail = Rails.root + "spec/support/assets/big_chungus.jpg"
  before :each do 
    sign_in user = build(:user)
    host! "localhost:3000"
  end
  let(:valid_attributes) {{ 
      "file" => Rack::Test::UploadedFile.new(path),
      "upload_tag_links" => [UploadTagLink.new(tag: Tag.new(:name => "test")), UploadTagLink.new(tag: Tag.new(:name => "test2"))],
      "tags" => [Tag.new(:name => "hello")]
    }}
    

  let(:invalid_attributes) {
    { 
      "file" => Rack::Test::UploadedFile.new(path_fail),
      "upload_tag_links" => [UploadTagLink.new(tag: Tag.new(:name => "!!!")), UploadTagLink.new(tag: Tag.new(:name => "!!!@"))],
      "tags" => [Tag.new(:name => "hello!"),Tag.new(:name => "hello2!!")]
    }}

  describe "GET /index" do
    it "renders a successful response" do
      Upload.create! valid_attributes
      get uploads_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      upload = Upload.create! valid_attributes
      get uploads_url
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_upload_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      upload = Upload.create! valid_attributes
      get edit_upload_url(upload)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Upload" do
        expect {
          post uploads_url, params: { upload: valid_attributes }
        }.to change(Upload, :count).by(0)
      end

      it "redirects to the created upload" do
        post uploads_url, params: { upload: valid_attributes }
        expect(response).to redirect_to(uploads_url)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Upload" do
        expect {
          post uploads_url, params: { upload: invalid_attributes }
        }.to change(Upload, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post uploads_url, params: { upload: invalid_attributes }
        expect(response).to redirect_to(uploads_url)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {{ 
        "file" => Rack::Test::UploadedFile.new(path),
        "upload_tag_links" => [UploadTagLink.new(tag: Tag.new(:name => "test")), UploadTagLink.new(tag: Tag.new(:name => "test2"))],
        "tags" => ["hello"]
      }}

      it "updates the requested upload" do
        upload = Upload.create! valid_attributes
        patch upload_url(upload), params: { :format => 'html', upload: new_attributes }
        upload.reload
        expect(flash[:danger]).to be_nil
      end
      it "redirects to the upload" do
        upload = Upload.create! valid_attributes
        patch upload_url(upload), params: { upload: new_attributes }
        upload.reload
        expect(response).to redirect_to(edit_upload_path(upload))
      end
    end

    context "with invalid parameters" do
      it "return Unprocessable Entity" do                         
        upload = Upload.create! valid_attributes
        patch upload_url(upload), params: { upload: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested upload" do
      upload = Upload.create! valid_attributes
      expect {
        delete upload_url(upload)
      }.to change(Upload, :count).by(-1)
    end

    it "redirects to the uploads list" do
      upload = Upload.create! valid_attributes
      delete upload_url(upload)
      expect(response).to redirect_to(uploads_url)
    end
  end
end