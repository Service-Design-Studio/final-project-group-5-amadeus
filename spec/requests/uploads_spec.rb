require 'rails_helper'
require 'factory_bot'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/uploads", type: :request do
  
  # This should return the minimal set of attributes required to create a valid
  # Upload. As you add validations to Upload, be sure to
  # adjust the attributes here as well.
  path = Rails.root + "app/assets/test_zip/rus.zip"
  path_fail = Rails.root + "spec/support/assets/big_chungus.jpg"
  before :each do 
    sign_in user = build(:user)
  end
  let(:valid_attributes) {{ 
      "file" => Rack::Test::UploadedFile.new(path),
      "categories" => [Category.new(:name => "test"),Category.new(:name => "test2")],
      "topics" => [Topic.new(:name => "test"),Topic.new(:name => "test2")]
    }}

  let(:invalid_attributes) {
    { 
      "file" => Rack::Test::UploadedFile.new(path_fail)
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
      get upload_url(upload)
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
        }.to change(Upload, :count).by(2)
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
      "categories" => [Category.new(:name => "test"),Category.new(:name => "test2")],
      "topics" => [Topic.new(:name => "test"),Topic.new(:name => "test2")]
      }}

      it "updates the requested upload" do
        upload = Upload.create! valid_attributes
        patch upload_url(upload), params: { upload: new_attributes }
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
      it "renders a successful response (i.e. to display the 'edit' template)" do                         
        upload = Upload.create! valid_attributes
        patch upload_url(upload), params: { upload: invalid_attributes }
        expect(response).to redirect_to(edit_upload_path(upload))
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