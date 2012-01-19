Feature: Popular Posts
  As a blog owner
  In order to direct viewers to frequently-requested information
  I want the most popular posts to appear in the sidebar
  
  Scenario: No posts yet
    When I am on the posts page
    Then I should not see "Popular"
  
  Scenario: One post, not viewed
    Given I have published a post called "Post title"
    When I am on the posts page
    Then the "popular posts" sidebar should contain "Post title"
    
  Scenario: Ordered posts of varying popularity
    Given I have published these posts:
      | title | popularity |
      | one   |    10      |
      | two   |     5      |
      | three |     1      |
      | four  |     3      |
      | five  |     7      |
      | six   |     0      |
      | seven |     8      |
    When I am on the posts page
    Then the "popular posts" sidebar should contain:
      | title |
      | one   |
      | seven |
      | five  |
      | two   |
      | four  |
    And the "popular posts" sidebar should not contain "three"
    And the "popular posts" sidebar should not contain "six"
    