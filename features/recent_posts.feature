Feature: Recent posts
  In order to make up-to-date content more easily accessible
  As a blog owner
  I want to list the most recent posts in the sidebar
  
  Scenario: No posts yet
    When I go to the mist posts page
    Then I should not see "Recent"
  
  Scenario: Most recent of 7
    Given I have published these posts:
      | title |
      | one   | 
      | two   |
      | three |
      | four  |
      | five  |
      | six   |
      | seven |
    When I go to the mist posts page
    Then the "recent posts" sidebar should contain:
      | title |
      | seven |
      | six   |
      | five  |
      | four  |
      | three |
  