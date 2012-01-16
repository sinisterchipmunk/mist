Feature: Update existing post
  As a blog owner
  In order to protect by site from malicious users
  I want to authorize who can destroy an existing post
  
  Scenario: Destroy post when not authorized
    Given I have created a post called "Post title"
      And I am not authorized
    When I look at the "Post title" post
    Then I should not see "Destroy"

  Scenario: Destroy post when authorized
    Given I have created a post called "Post title"
      And I am authorized
    When I look at the "Post title" post
    Then I should see "Destroy"

  Scenario: Destroy from main page when authorized
    Given I have created a post called "Post title"
      And I am authorized
    When I am on the posts page
    Then I should see "Destroy"
  
  Scenario: Destroy from main page when not authorized
    Given I have created a post called "Post title"
      And I am not authorized
    When I am on the posts page
    Then I should not see "Destroy"
