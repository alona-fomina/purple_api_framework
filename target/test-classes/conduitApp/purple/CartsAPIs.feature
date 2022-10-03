@regression
Feature: Validation for Carts APIs

  Background:
    * def token = "eyJraWQiOiJ1cy13ZXN0LTIxIiwidHlwIjoiSldTIiwiYWxnIjoiUlM1MTIifQ.eyJzdWIiOiJ1cy13ZXN0LTI6YzE1ZmZlZmUtNDAwZS00MWVmLWIzZTAtM2FkYTk3Y2RhM2FiIiwiYXVkIjoidXMtd2VzdC0yOmEyZjllZTBlLWU5MTMtNGM2ZC1hYjljLTM5NGMyZDFkMjU1ZCIsImFtciI6WyJ1bmF1dGhlbnRpY2F0ZWQiXSwiaXNzIjoiaHR0cHM6Ly9jb2duaXRvLWlkZW50aXR5LmFtYXpvbmF3cy5jb20iLCJodHRwczovL2NvZ25pdG8taWRlbnRpdHkuYW1hem9uYXdzLmNvbS9pZGVudGl0eS1wb29sLWFybiI6ImFybjphd3M6Y29nbml0by1pZGVudGl0eTp1cy13ZXN0LTI6NDI4MDI4MjM5NDE0OmlkZW50aXR5cG9vbC91cy13ZXN0LTI6YTJmOWVlMGUtZTkxMy00YzZkLWFiOWMtMzk0YzJkMWQyNTVkIiwiZXhwIjoxNjY0ODI5MjExLCJpYXQiOjE2NjQ4Mjg2MTF9.jisWylTU7Gk8sgrk7FVI5C_KXwn3hJzvocUlq6Srk9Uody6y1bFv_okbKDE61-nWdajjsD1dSnnums0fF_338DPh7kizAk66zbFnSZYPZChqE_7vL-802bf1Hd1uWjjXcWtIAIXSu5RQSa9hYTHc9MWBkRRngd2OqsFq0M63QwB69CdtYwL3IA6DMLQMVrTj6bb4oQkKiMhIkJh4yi55BWAYrPVbW8VDH-R9i5282o02Ndb_NJPynogMv9kf4LMZNCNRPthDQ6J4EY8RbfVXCrIMlW1ZgA00lpqOtuenSaPxeIcwS3H2mRhsIfhXv0zsHH71OCBZ4ZLFiIHh8Fog5Q"
    * url 'https://commerce-api-stage.purple.com/carts'

    #Getting active cart
  Scenario: Get Active Cart
    Given path '/active-cart/'
    And header Authorization = 'Bearer ' + token
    When method Get
    Then status 200
    And match response ==
            """
            {
            id: #string,
            customerId: #ignore,
            customerEmail: #string,
            anonymousId: #string,
            shippingAddress: #ignore,
            customLineItems: #array,
            discountCodes: #array,
            totalPrice: {
                type: #string,
                currencyCode: #string,
                centAmount: #number,
                fractionDigits: #number
            },
            taxedPrice: #ignore,
            lineItems: #array,
            giftCards: #array,
            versionModifiedAt: #string,
            shippingMode: #string,
            shipping: #array,
            directDiscounts: #array,
            totalLineItemQuantity: #ignore,
            source: #string
            }
            """


  Scenario Outline: Add, update and remove -<product_name>- to cart
#    Before everything getting the active cart and validating it is empty
    Given path '/active-cart/'
    And header Authorization = 'Bearer ' + token
    When method Get
    Then status 200
    And match response ==
            """
            {
            id: #string,
            customerId: #ignore,
            customerEmail: #string,
            anonymousId: #string,
            shippingAddress: #ignore,
            customLineItems: #array,
            discountCodes: #array,
            totalPrice: {
                type: #string,
                currencyCode: #string,
                centAmount: #number,
                fractionDigits: #number
            },
            taxedPrice: #ignore,
            lineItems: #[0],
            giftCards: #array,
            versionModifiedAt: #string,
            shippingMode: #string,
            shipping: #array,
            directDiscounts: #array,
            totalLineItemQuantity: #ignore,
            source: #string
            }
            """

    Given path '/line-items'
    And request [{"sku": "<sku>","quantitiy": 1}];
    And header Authorization = 'Bearer '+ token
    When method Post
    Then status 200
    * def line_item_id = response.lineItems[0].id
    * def post_response = response
#    after post getting the cart
    Given path '/active-cart/'
    And header Authorization = 'Bearer ' + token
    When method Get
    Then status 200
    * def post_active_cart_response = response


    Given path '/line-items/' + line_item_id + '/quantity'
    And request {"quantity": 5}
    And header Authorization = 'Bearer '+ token
    When method Patch
    Then status 200
    * def line_item_id = response.lineItems[0].id
    * def patch_response = response
#    after patch getting the cart
    Given path '/active-cart/'
    And header Authorization = 'Bearer ' + token
    When method Get
    Then status 200
    * def patch_active_cart_response = response


    Given path '/line-items/' + line_item_id
    And header Authorization = 'Bearer '+ token
    When method Delete
    Then status 200
#    after delete getting the cart
    Given path '/active-cart/'
    And header Authorization = 'Bearer ' + token
    When method Get
    Then status 200
    * def delete_active_cart_response = response


#    post call validations
    * match product_name == post_response.lineItems[0].name["en-US"]
    * match 1 == post_response.lineItems[0].quantity
    * match post_active_cart_response.lineItems == '#[1]'
    * match each post_response.lineItems ==
            """
            {
            id: #string,
            productId: #string,
            name: {
                en: #ignore,
                en-US: #string
            },
            productSlug: {
                en: #ignore,
                en-US: #string
            },
            price: {
                id: #string,
                value: {
                    type: #string,
                    currencyCode: #string,
                    centAmount: #number,
                    fractionDigits: #number
                }
            },
            taxedPrice: #ignore,
            totalPrice: {
                type: #string,
                currencyCode: #string,
                centAmount: #number,
                fractionDigits: #number
            },
            quantity: #number,
            addedAt: #string,
            taxRate: #ignore,
            discountedPricePerQuantity: #array,
            custom: {
                type: {
                    id: #string,
                    typeId: #string
                },
                fields: {
                    discounts_json: #string
                }
            },
            variant: {
                sku: #string,
                key: #string,
                images: #array,
                attributes: #array,
                id: #number,
                availability: #ignore
            },
            productKey: #string
            }
            """

#    patch call validations
    * match 5 == patch_response.lineItems[0].quantity
    * match patch_active_cart_response.lineItems == '#[1]'

#    delete call validations with getting the active cart (since delete API doesn't have a response body)
    * match delete_active_cart_response.lineItems == '#[0]'

    Examples:
      | product_name                     | sku         |
      | Weighted Blanket                 | 10-38-13050 |
      | Purple Plus Mattress             | 10-21-23964 |
      | Replacement Seat Cushion Cover   | 40-41-42096 |
      | Replacement Seat Cushion Cover   | 40-41-42002 |
      | Replacement Seat Cushion Cover   | 40-41-42019 |
      | Replacement Seat Cushion Cover   | 40-41-42033 |
      | Replacement Seat Cushion Cover   | 40-41-42040 |
      | Replacement Seat Cushion Cover   | 40-41-42064 |
      | Replacement Seat Cushion Cover   | 40-41-42071 |
      | Replacement Seat Cushion Cover   | 40-41-42003 |
      | Replacement Seat Cushion Cover   | 40-41-42020 |
      | Replacement Seat Cushion Cover   | 40-41-42035 |
      | Replacement Seat Cushion Cover   | 40-41-42041 |
      | Replacement Seat Cushion Cover   | 40-41-42065 |
      | Replacement Seat Cushion Cover   | 40-41-42097 |
      | Replacement Seat Cushion Cover   | 40-41-42072 |
      | Replacement Seat Cushion Cover   | 40-41-42034 |
      | Purple Harmony™ Pillow           | 10-31-12890 |
      | Purple Harmony™ Pillow           | 10-31-12895 |
      | Purple Harmony™ Pillow           | 10-31-12911 |
      | Purple Harmony™ Pillow           | 10-31-12918 |
      | Purple Harmony™ Pillow           | 10-31-12914 |
      | Purple Harmony™ Pillow           | 10-31-12913 |
    #   | Sleepy Jones + Purple Pajamas    | 10-90-10075
      | Sleepy Jones + Purple Pajamas    | 10-90-10072 |
      | Sleepy Jones + Purple Pajamas    | 10-90-10076 |
      | Sleepy Jones + Purple Pajamas    | 10-90-10073 |
      | Sleepy Jones + Purple Pajamas    | 10-90-10077 |
    #   | Sleepy Jones + Purple Pajamas    | 10-90-10074
      | Sleepy Jones + Purple Pajamas    | 10-90-10078 |
      | Sleepy Jones + Purple Pajamas    | 10-90-10083 |
      | Sleepy Jones + Purple Pajamas    | 10-90-10079 |
      | Sleepy Jones + Purple Pajamas    | 10-90-10084 |
      | Sleepy Jones + Purple Pajamas    | 10-90-10080 |
      | Sleepy Jones + Purple Pajamas    | 10-90-10085 |
      | Sleepy Jones + Purple Pajamas    | 10-90-10086 |
      | Sleepy Jones + Purple Pajamas    | 10-90-10082 |
      | Portable Seat Cushion            | 10-41-12583 |
      | Purple SoftStretch Sheets        | 10-38-22830 |
      | Purple SoftStretch Sheets        | 10-38-22840 |
      | Purple SoftStretch Sheets        | 10-38-22830 |
      | Simply Seat Cushion              | 10-41-12576 |
      | The Purple PowerBase             | 10-38-12939 |
      | The Purple PowerBase             | 10-38-12946 |
      | The Purple PowerBase             | 10-21-13027 |
      | Purple Bed Frame                 | 10-38-45897 |
      | Purple Bed Frame                 | 10-38-45898 |
      | Purple Bed Frame                 | 10-38-45899 |
      | Purple Bed Frame                 | 10-38-45900 |
      | Purple Bed Frame                 | 10-38-45901 |
      | Purple Bed Frame                 | 10-38-45902 |
      | Purple Bed Frame                 | 10-38-45903 |
      | Purple Bed Frame                 | 10-38-45904 |
      | Purple Bed Frame                 | 10-38-45906 |
      | Purple Bed Frame                 | 10-38-45907 |
      | Purple Bed Frame                 | 10-38-45896 |
      | Purple Bed Frame                 | 10-38-45905 |
      | Back Cushion                     | 10-41-12378 |
      | Foldaway Seat Cushion            | 10-41-12574 |
      | Portable Seat Cushion            | 10-41-12583 |
      | Royal Seat Cushion               | 10-41-12573 |
      | Ultimate Seat Cushion1           | 10-41-12564 |
      | Back Cushion                     | 10-41-12378 |
      | Simply Seat Cushion              | 10-41-12576 |
      | Double Seat Cushion              | 10-41-12540 |
#      | Plush Pillow                     | 10-31-12857
      | Plush Pillow                     | 10-31-12860 |
      | Purple Pillow Booster            | 10-31-13100 |
      | The Purple Mattress Protector    | 10-38-13731 |
      | The Purple Mattress Protector    | 10-38-13924 |
      | The Purple Mattress Protector    | 10-38-13748 |
      | The Purple Mattress Protector    | 10-38-13900 |
      | The Purple Mattress Protector    | 10-38-13994 |
      | The Purple Mattress Protector    | 10-38-13917 |
      | The Purple Mattress Protector    | 10-38-13918 |
      | Headboard                        | 10-38-45888 |
      | The Purple Squishy               | 10-11-18429 |
      | Purple Complete Comfort Sheets   | 10-38-23001 |
      | Purple Complete Comfort Sheets   | 10-38-23005 |
      | Purple Hybrid Premier 4 Mattress | 10-21-60013 |
      | Purple Hybrid Premier 4 Mattress | 10-21-60020 |
      | Purple Hybrid Premier 4 Mattress | 10-21-60014 |
      | Purple Hybrid Premier 4 Mattress | 10-21-60015 |
      | Purple Hybrid Premier 4 Mattress | 10-21-60013 |
      | Purple Hybrid Premier 4 Mattress | 10-21-60016 |
      | Purple Hybrid Premier 4 Mattress | 10-21-60058 |
      | Purple Platform Bed Frame        | 10-38-52891 |
      | Purple Platform Bed Frame        | 10-38-52892 |
      | Purple Platform Bed Frame        | 10-38-52893 |
      | Purple Platform Bed Frame        | 10-38-52846 |
      | Purple Platform Bed Frame        | 10-38-52815 |
      | Purple Platform Bed Frame        | 10-38-52822 |
      | Purple Hybrid Mattress           | 10-21-23968 |
      | Purple Hybrid Mattress           | 10-21-60018 |
      | Purple Hybrid Mattress           | 10-21-60006 |
      | Purple Hybrid Mattress           | 10-21-60007 |
      | Purple Hybrid Mattress           | 10-21-60008 |
      | Purple Hybrid Mattress           | 10-21-60028 |

            
            
            

       




# Examples:
# |product|status code|
# ||||


# And match response ==
# """
#         {
#             id: #string,
#             anonymousId: #string,
#             customLineItems: #array,
#             discountCodes: #array,
#             totalPrice: #object,
#             type: #string
#             lineItems: #array,
#             giftCards: #array,
#             versionModifiedAt: #string,
#             shippingMode: #string,
#             shipping: #array,
#             directDiscounts: #array,
#             totalLineItemQuantity: #number,
#             source: #string
#             }
#     """


# And match response.id == "#string"
# And match response.customerId == "#string"
# And match response.customerEmail == "#string"
# And match response.customerEmail == "#string"
# And match response.anonymousId == "#string"
# And match response.customLineItems == "#array"
# And match response.shippingAddress.firstName == "#string"
# And match response.shippingAddress.lastName == "#string"
# And match response.shippingAddress.streetName == "#string"
# And match response.shippingAddress.postalCode == "#string"
# And match response.shippingAddress.city == "#string"
# And match response.shippingAddress.firstName == "#string"
# And match response.shippingAddress.state == "#string"
# And match response.shippingAddress.country == "#string"
# And match response.shippingAddress.phone == "#string"
# And match response.shippingAddress.email == "#string"
# And match response.discountCodes == "#array"
# And match response.totalPrice.type == "#string"
# And match response.totalPrice.currencyCode == "#string"
# And match response.totalPrice.centAmount == int
# And match response.totalPrice.fractionDigits == int
# And match response.taxedPrice.totalNet.type == "#string"
# And match response.taxedPrice.totalNet.currencyCode == "#string"
# And match response.taxedPrice.totalNet.centAmount == int
# And match response.taxedPrice.totalNet.fractionDigits == int
# And match response.shipping == "#array"



#And match response.customLineItems.id == '#string'


#Adding Weighted Blanket to the active cart
# Given path '/line-items'
# And request [{"sku":"10-38-13050","quantitiy":1}]
# And header Authorization = 'Bearer '+ token
# When method Post
# Then status 200
# And match response.id == "#string"
# And match response.anonymousId == "#string"
# #And match response.customLineItems.money.currencyCode == '#string'
# #And match response.customerEmail == '#string'
# And match response.anonymousId == '#string'
# #And match response.customLineItems.id == '#string'


#     #Adding Replacement Seat Cushion Cover to the active cart
#     Given path '/line-items'
#     And request [{"sku":"40-41-42096","quantitiy":1}]
#     And header Authorization = 'Bearer '+ token
#     When method Post
#     Then status 200
#     And match response.id == "#string"
#     And match response.anonymousId == "#string"
#     #And match response.customLineItems.money.currencyCode == '#string'
#     #And match response.customerEmail == '#string'
#     And match response.anonymousId == '#string'


#      #Adding The Purple Harmony Pillow Standart Medium to the active cart
#      Given path '/line-items'
#      And request [{"sku":"10-31-12890","quantitiy":1}]
#      And header Authorization = 'Bearer '+ token
#      When method Post
#      Then status 200
#      And match response.id == "#string"
#      And match response.anonymousId == "#string"
#      #And match response.customLineItems.money.currencyCode == '#string'
#      #And match response.customerEmail == '#string'
#      And match response.anonymousId == '#string'


#      #Adding The Purple Harmony Pillow Standart Tall to the active cart
#      Given path '/line-items'
#      And request [{"sku":"10-31-12895","quantitiy":1}]
#      And header Authorization = 'Bearer '+ token
#      When method Post
#      Then status 200
#      And match response.id == "#string"
#      And match response.anonymousId == "#string"
#      #And match response.customLineItems.money.currencyCode == '#string'
#      #And match response.customerEmail == '#string'
#      And match response.anonymousId == '#string'

#      #Adding The Purple Harmony Pillow Standart Low to the active cart
#      Given path '/line-items'
#      And request [{"sku":"10-31-12911","quantitiy":1}]
#      And header Authorization = 'Bearer '+ token
#      When method Post
#      Then status 200
#      And match response.id == "#string"
#      And match response.anonymousId == "#string"
#      #And match response.customLineItems.money.currencyCode == '#string'
#      #And match response.customerEmail == '#string'
#      And match response.anonymousId == '#string'

#      #Adding The Purple Harmony Pillow King Low to the active cart
#      Given path '/line-items'
#      And request [{"sku":"10-31-12918","quantitiy":1}]
#      And header Authorization = 'Bearer '+ token
#      When method Post
#      Then status 200
#      And match response.id == "#string"
#      And match response.anonymousId == "#string"
#      #And match response.customLineItems.money.currencyCode == '#string'
#      #And match response.customerEmail == '#string'
#      And match response.anonymousId == '#string'


#      #Adding The Purple Harmony Pillow King Medium to the active cart
#      Given path '/line-items'
#      And request [{"sku":"10-31-12914","quantitiy":1}]
#      And header Authorization = 'Bearer '+ token
#      When method Post
#      Then status 200
#      And match response.id == "#string"
#      And match response.anonymousId == "#string"
#      #And match response.customLineItems.money.currencyCode == '#string'
#      #And match response.customerEmail == '#string'
#      And match response.anonymousId == '#string'


#       #Adding The Purple Harmony Pillow King Tall to the active cart
#       Given path '/line-items'
#       And request [{"sku":"10-31-12913","quantitiy":1}]
#       And header Authorization = 'Bearer '+ token
#       When method Post
#       Then status 200
#       And match response.id == "#string"
#       And match response.anonymousId == "#string"
#       #And match response.customLineItems.money.currencyCode == '#string'
#       #And match response.customerEmail == '#string'
#       And match response.anonymousId == '#string'


#     Given path '/line-items'
#     And request [{"sku":"10-21-23964","quantitiy":1}]
#     And header Authorization = 'Bearer '+ token
#     When method Post
#     Then status 200
#     And match response.id == "#string"

#     Given path '/line-items'
#     And request [{"sku":"10-38-22850","quantitiy":4}]
#     And header Authorization = 'Bearer '+ token
#     When method Post
#     Then status 200
#     And match response.id == "#string"

#     #Delete all purple plus mattress from the active cart
# Scenario: Remove an item from the active cart
#     Given path '/line-items/0af9eaac-a0f8-4c4d-9126-01ef1b61b4ed'
#     And header Authorization = 'Bearer '+ token
#     When method Delete
#     Then status 200

# Scenario: Sets billing address to the active cart
#     Given path '/billing-address'
#     And header Authorization = 'Bearer '+ token
#     When method Post
#     Then status 20