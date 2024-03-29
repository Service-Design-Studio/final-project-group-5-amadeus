@admin @summariser_ai
Feature: AI automatically summarize article
  As an admin of AMADEUS
  So that I can quickly comprehend the uploaded articles
  I want to have my articles summarized by an AI when they are uploaded

  Background:
    Given I am logged in as an admin of AMADEUS

  @happy
  Scenario Outline: Auto-generated summary after each upload
    Given I have uploaded these zip files: rus.zip
    When I am on the edit page for the article "<article_name>"
    Then I should see a summary between 30 to 150 words for the article "<article_name>"

    Examples:
      | article_name                                                              |
      | Russia's economy in for a bumpy ride as sanctions bite - BBC News         |
      | Russia sentences US teacher to 14 years for cannabis smuggling - BBC News |
