Feature: Recent posts
  In order to make up-to-date content more easily accessible
  As a blog owner
  I want to list the most recent posts in the sidebar
  
  Scenario: No posts yet
    When I go to the posts page
    Then I should not see "Recent"
  
  Scenario: Most recent of 7
    Given I have published these posts:
      | title | published_at |
      | one   | 01-01-2011 |
      | two   | 01-02-2011 |
      | three | 01-03-2011 |
      | four  | 01-04-2011 |
      | five  | 01-05-2011 |
      | six   | 01-06-2011 |
      | seven | 01-07-2011 |
    When I go to the posts page
    Then the "recent posts" sidebar should contain:
      | title |
      | seven |
      | six   |
      | five  |
      | four  |
      | three |
  