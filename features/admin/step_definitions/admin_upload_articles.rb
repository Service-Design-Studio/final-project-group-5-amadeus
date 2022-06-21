And(/^I am viewing the upload page$/) do
  visit '/admin/uploads/new'
  expect(page).to have_current_path('/admin/uploads/new')
end

## View
Then(/^I should see an area to input my Topic$/) do
  expect(page).to have_css('input[type="text"]')
end


And(/^I should see an area to upload my zip files either by browsing or dragging$/) do
  expect(page).to have_button 'create-upload-button'
  expect(page).to have_field(:file)
end



## Upload funtionalities
When(/^I attach a zip file called (.*) and key in the topic (.*)$/) do |zip_name, topic_name|
  attach_file(Rails.root + "features/test_zip/#{zip_name}")
  fill_in :title, with: topic_name
end

Then(/^I click on the "Create Upload" button$/) do
  find("#create-upload-button").click
end

And(/^I should be redirected to upload database$/) do
  visit '/admin/uploads'
end

And(/^I should see the above (.*) zip file with its corresponding (.*)$/) do |zip_name, topic_name|
  expect(page).to have_current_path('/admin/uploads')
  expect(page).to have_content(zip_name)
  expect(page).to have_content(topic_name)
end

When(/^I attach no zip file and key in the topic (.*)$/) do |topic_name|
  expect(page).to have_current_path('/admin/uploads/new')
  fill_in :title, with: topic_name
end

And(/^I should remain in this upload page$/) do
  expect(page).to have_current_path('/admin/uploads/new')
end