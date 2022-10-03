Feature: Realworld APIs test

Background: Define Url
    # Logs in to get token for hitting APIs we need 
    Given url 'https://api.realworld.io'
    And path '/api/users/login'
    And request {"user": {"email": "purple1@gmail.com", "password": "purple1234"}}
    When method Post
    Then status 200
    * def token = response.user.token

Scenario: Create and delete article
    # Creates an article and saves the slug for future calls
    Given header Authorization = 'Token ' + token
    And path '/api/articles/'
    And request {"article":{"tagList":[],"title":"purple1","description":"about purple","body":"body"}}
    When method Post
    Then status 200
    *  def slug = response.article.slug

    # Gets every article and validates first article in response
    Given header Authorization = 'Token ' + token
    And params {limit:10, offset:0}
    And path '/api/articles/'
    When method Get
    Then status 200
    And match response.articles[0].title == 'purple1'

    # Gets a single article and validates the title
    Given header Authorization = 'Token ' + token
    And path '/api/articles/' + slug
    When method Get
    Then status 200
    And match response.article.title == 'purple1'

    # Deletes the article with the slug provided
    Given header Authorization = 'Token ' + token
    And path '/api/articles/' + slug
    When method Delete
    Then status 200
