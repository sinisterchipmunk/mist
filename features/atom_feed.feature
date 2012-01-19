Feature: Atom feed
  As a blog owner
  In order to increase return visits
  I want to publish an Atom feed
  
  Scenario: With no blog posts
    When I am on the feed mist posts page in "atom" format
      # I don't know how to test this. But, at least we've made sure no errors
      # were generated...
    
  Scenario: With an unpublished blog post
    Given I have created a post called "Post title"
    When I am on the feed mist posts page in "atom" format
    Then I should not see "Post title"
    
  Scenario: With a published blog post
    Given I have published a post called "Post title"
    When I am on the feed mist posts page in "atom" format
    Then I should see "Post title"
  