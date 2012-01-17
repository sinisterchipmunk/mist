Feature: Authorize viewing unpublished posts
  As a blog author
  In order to keep my content clean and consistent
  I want to prevent others from seeing a post before it is published
  
  Scenario: Shown to authorized when not published
    Given I am authorized
    When I create a post called "Post title"
      And I am on the posts page
    Then I should see "Post title"
    
  Scenario: Not shown to unauthorized when not published
    Given I have created a post called "Post title"
      And I am not authorized
    When I am on the posts page
    Then I should not see "Post title"

  Scenario: Become available when published
    Given I have published a post called "Post title"
      And I am not authorized
    When I am on the posts page
    Then I should see "Post title"
