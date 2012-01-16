Feature: Authorization of Create new post
  As a blog owner
  In order to protect by blog from malicious users
  I want to authorize who creates a post
  
  Scenario: Create post without authorization
    Given I am not authorized
    When  I am on the posts page
    Then  I should not see "New Post"

  Scenario: Create post with authorization
    Given I am authorized
    When  I am on the posts page
    Then  I should see "New Post"
