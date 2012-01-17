Feature: Update existing post
  As a blog owner
  In order to protect by site from malicious users
  I want to authorize who can update an existing post
  
  Background:
    Given I have created a post called "Post title"
  
  Scenario: Change post when not authorized
    Given I am not authorized
    When I look at the "Post title" post
    Then I should not see "Edit"

  Scenario: Change post when authorized
    Given I am authorized
    When I look at the "Post title" post
    Then I should see "Edit"

  Scenario: Update from main page when authorized
    Given I am authorized
    When I am on the posts page
    Then I should see "Edit"
  
  Scenario: Update from main page when not authorized
    Given I am not authorized
    When I am on the posts page
    Then I should not see "Edit"
    