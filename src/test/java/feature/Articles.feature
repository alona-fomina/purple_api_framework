Feature:Articles

Background: Define Url
    Given url 'https://conduit.productionready.io'
    Given path '/api/users/login'
    And request {"user": {"email": "purple1@gmail.com", "password": "purple1234"}}
    When method Post
    Then status 200
    * def token = response.user.token
    * call read('classpath:helpers/CreateToken.feature')
@ignore
Scenario: Create a new article
    Given header Authorization = 'Token ' + token
    Given path '/api/articles'
    And request {"article": {"tagList": [],"title": "purpjjjje","description": "about purple","body": "body"}}
    When method Post 
    Then status 200
    And match response.article.title == "purpjjjje"