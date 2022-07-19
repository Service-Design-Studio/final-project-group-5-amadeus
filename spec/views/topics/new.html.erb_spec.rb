require 'rails_helper'

RSpec.describe "topics/new", type: :view do
  before(:each) do
    assign(:topic, Topic.new(
      name: "MyString"
    ))
  end

  it "renders new tag form" do
    render

    assert_select "form[action=?][method=?]", topics_path, "post" do

      assert_select "input[name=?]", "tag[name]"
    end
  end
end
