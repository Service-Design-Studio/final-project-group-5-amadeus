@admin @upload_new
Feature: upload zipped folder containing pdf file of articles
  As an admin of AMADEUS
  So that I can contribute documents for AMADEUS's knowledge repository
  I want to upload pdf locally in bulk using zipped format

  Background:
    Given I am logged in as an admin of AMADEUS
    And I am on the "New Upload" page
    Then I should see an area to upload my zip files either by browsing or dragging
    And I should see a "Upload" button

  @happy
  Scenario Outline: Uploading valid zip file
    Given I am on the "New Upload" page
    When I attach a zip file called <zip_name>
    And I click on the "Upload" button
    And I should be redirected to the "Database" page
    And I should see an article called <article_name>.

    Examples:
      | zip_name | article_name                                                              |
      | rus.zip  | Russia sentences US teacher to 14 years for cannabis smuggling - BBC News |
      | uav.zip  | Combat drones_ We are in a new era of warfare - here's why - BBC News     |
      | ukr.zip  | Ukraine war_ Thousands of civilians trapped in Severodonetsk - BBC News   |

  @sad
  Scenario: Upload no zip file
    Given I am on the "New Upload" page
    When I attach no zip file and upload
    And I should stay on the "New Upload" page

  @redirect
  Scenario: Back to home
    Given I am on the "New Upload" page
    When I click on the "Back to Database" button
    Then I should be redirected to the "Home" page
