@regression
Feature: Validation for Carts APIs

  Background:
    * def token = "eyJraWQiOiJ1cy13ZXN0LTIxIiwidHlwIjoiSldTIiwiYWxnIjoiUlM1MTIifQ.eyJzdWIiOiJ1cy13ZXN0LTI6YzE1ZmZlZmUtNDAwZS00MWVmLWIzZTAtM2FkYTk3Y2RhM2FiIiwiYXVkIjoidXMtd2VzdC0yOmEyZjllZTBlLWU5MTMtNGM2ZC1hYjljLTM5NGMyZDFkMjU1ZCIsImFtciI6WyJ1bmF1dGhlbnRpY2F0ZWQiXSwiaXNzIjoiaHR0cHM6Ly9jb2duaXRvLWlkZW50aXR5LmFtYXpvbmF3cy5jb20iLCJodHRwczovL2NvZ25pdG8taWRlbnRpdHkuYW1hem9uYXdzLmNvbS9pZGVudGl0eS1wb29sLWFybiI6ImFybjphd3M6Y29nbml0by1pZGVudGl0eTp1cy13ZXN0LTI6NDI4MDI4MjM5NDE0OmlkZW50aXR5cG9vbC91cy13ZXN0LTI6YTJmOWVlMGUtZTkxMy00YzZkLWFiOWMtMzk0YzJkMWQyNTVkIiwiZXhwIjoxNjY1NDM4NTcyLCJpYXQiOjE2NjU0Mzc5NzJ9.L1O4IkkA09jHFEdG6Il_TUQQ9ihJYrdnBqmATlJPGPvuooilrHx5j0dAFhxpdFttsXetzY4pPzTpmDnoV1EcIIyvD5qaZ-_ypgn0EZzvn8Ov7ghwI4Mken6kqLtawLZtkdDqtJcSWtvODDYd5dR86IZwXPjxRvdN_nVeUJUpm6DM8scd_-OAHOp659SkAKGYST4F-C43cl35W9Ir5ctAa7EaluWB7oFwdt2Rabak7LfkPVf3bOg1XAKhciIqvNJaSgWGI1T5zyaVQ3oWvjTxtygPamyR1NBHH449twJQM85WZICalqsRjvE6qMlL8fZFOlR3hRHL9V_KhKHbU5cv2Q"
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

    Given path '/line-items'
    And request [{"sku": "10-38-13050","quantitiy": 1}]
    And header Authorization = 'Bearer '+ token
    When method Post
    Then status 200
    * def line_itemid = response.lineItems[0].id

    Given path '/shipping-address'
    And request {"firstName":"Knopa","lastName":"Fomina","streetAddress":"352 Pembroke Court","postalCode":"60193","city":"Chicago","state":"IL","country":"US","email":"vitalik.fomin@gmail.com","apartment":"8"}
    And header Authorization = 'Bearer '+ token
    When method Post
    Then status 200
    And match response.shippingAddress ==
    """
    {
        firstName: #string,
        lastName: #string,
        streetName: #string,
        postalCode: #string,
        city: #string,
        state: #string,
        country: #string,
        email: #string
    }
    """

    Given path '/line-items/' + line_itemid
    And header Authorization = 'Bearer '+ token
    When method Delete
    Then status 200

  Scenario: Gets the available shipping methods for the active cart
    Given path '/shipping-methods'
    When method Get
    Then status 200
    And match response ==
    """
  {
  key: #string
  }
  {
  name: #string
  }
  {
  groups: #array
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
      | product_name                       | sku         |
      | Weighted Blanket                   | 10-38-13050 |
      | Purple Plus Mattress               | 10-21-23964 |
      | Replacement Seat Cushion Cover     | 40-41-42096 |
      | Replacement Seat Cushion Cover     | 40-41-42002 |
      | Replacement Seat Cushion Cover     | 40-41-42019 |
      | Replacement Seat Cushion Cover     | 40-41-42033 |
      | Replacement Seat Cushion Cover     | 40-41-42040 |
      | Replacement Seat Cushion Cover     | 40-41-42064 |
      | Replacement Seat Cushion Cover     | 40-41-42071 |
      | Replacement Seat Cushion Cover     | 40-41-42003 |
      | Replacement Seat Cushion Cover     | 40-41-42020 |
      | Replacement Seat Cushion Cover     | 40-41-42035 |
      | Replacement Seat Cushion Cover     | 40-41-42041 |
      | Replacement Seat Cushion Cover     | 40-41-42065 |
      | Replacement Seat Cushion Cover     | 40-41-42097 |
      | Replacement Seat Cushion Cover     | 40-41-42072 |
      | Replacement Seat Cushion Cover     | 40-41-42034 |
      | Purple Harmony™ Pillow             | 10-31-12890 |
      | Purple Harmony™ Pillow             | 10-31-12895 |
      | Purple Harmony™ Pillow             | 10-31-12911 |
      | Purple Harmony™ Pillow             | 10-31-12918 |
      | Purple Harmony™ Pillow             | 10-31-12914 |
      | Purple Harmony™ Pillow             | 10-31-12913 |
#      | Sleepy Jones + Purple Pajamas    | 10-90-10075   |
      | Sleepy Jones + Purple Pajamas      | 10-90-10072 |
      | Sleepy Jones + Purple Pajamas      | 10-90-10076 |
      | Sleepy Jones + Purple Pajamas      | 10-90-10073 |
      | Sleepy Jones + Purple Pajamas      | 10-90-10077 |
#      | Sleepy Jones + Purple Pajamas    | 10-90-10074   |
      | Sleepy Jones + Purple Pajamas      | 10-90-10078 |
      | Sleepy Jones + Purple Pajamas      | 10-90-10083 |
      | Sleepy Jones + Purple Pajamas      | 10-90-10079 |
      | Sleepy Jones + Purple Pajamas      | 10-90-10084 |
      | Sleepy Jones + Purple Pajamas      | 10-90-10080 |
      | Sleepy Jones + Purple Pajamas      | 10-90-10085 |
      | Sleepy Jones + Purple Pajamas      | 10-90-10086 |
      | Sleepy Jones + Purple Pajamas      | 10-90-10082 |
      | Portable Seat Cushion              | 10-41-12583 |
      | Purple SoftStretch Sheets          | 10-38-22830 |
      | Purple SoftStretch Sheets          | 10-38-22840 |
      | Purple SoftStretch Sheets          | 10-38-22830 |
      | Simply Seat Cushion                | 10-41-12576 |
      | The Purple PowerBase               | 10-38-12939 |
      | The Purple PowerBase               | 10-38-12946 |
      | The Purple PowerBase               | 10-21-13027 |
      | Purple Bed Frame                   | 10-38-45897 |
      | Purple Bed Frame                   | 10-38-45898 |
      | Purple Bed Frame                   | 10-38-45899 |
      | Purple Bed Frame                   | 10-38-45900 |
      | Purple Bed Frame                   | 10-38-45901 |
      | Purple Bed Frame                   | 10-38-45902 |
      | Purple Bed Frame                   | 10-38-45903 |
      | Purple Bed Frame                   | 10-38-45904 |
      | Purple Bed Frame                   | 10-38-45906 |
      | Purple Bed Frame                   | 10-38-45907 |
      | Purple Bed Frame                   | 10-38-45896 |
      | Purple Bed Frame                   | 10-38-45905 |
      | Back Cushion                       | 10-41-12378 |
      | Foldaway Seat Cushion              | 10-41-12574 |
      | Portable Seat Cushion              | 10-41-12583 |
      | Royal Seat Cushion                 | 10-41-12573 |
      | Ultimate Seat Cushion              | 10-41-12564 |
      | Back Cushion                       | 10-41-12378 |
      | Simply Seat Cushion                | 10-41-12576 |
      | Double Seat Cushion                | 10-41-12540 |
#      | Plush Pillow                     | 10-31-12857   |
      | Plush Pillow                       | 10-31-12860 |
      | The Purple Pillow Boosters         | 10-31-13100 |
      | The Purple Mattress Protector      | 10-38-13731 |
      | The Purple Mattress Protector      | 10-38-13924 |
      | The Purple Mattress Protector      | 10-38-13748 |
      | The Purple Mattress Protector      | 10-38-13900 |
      | The Purple Mattress Protector      | 10-38-13994 |
      | The Purple Mattress Protector      | 10-38-13917 |
      | The Purple Mattress Protector      | 10-38-13918 |
      | Headboard                          | 10-38-45888 |
      | The Purple Squishy                 | 10-11-18429 |
      | Purple Complete Comfort Sheets     | 10-38-23001 |
      | Purple Complete Comfort Sheets     | 10-38-23005 |
      | Purple Hybrid Premier 4 Mattress   | 10-21-60013 |
      | Purple Hybrid Premier 4 Mattress   | 10-21-60013 |
      | Purple Hybrid Premier 4 Mattress   | 10-21-60020 |
      | Purple Hybrid Premier 4 Mattress   | 10-21-60014 |
      | Purple Hybrid Premier 4 Mattress   | 10-21-60015 |
      | Purple Hybrid Premier 4 Mattress   | 10-21-60016 |
      | Purple Hybrid Premier 4 Mattress   | 10-21-60058 |
      | Purple Hybrid Mattress             | 10-21-23968 |
      | Purple Hybrid Mattress OOP         | 10-21-60018 |
      | Purple Platform Bed                | 10-38-52846 |
      | Purple Platform Bed                | 10-38-52815 |
      | Purple Platform Bed                | 10-38-52822 |
      | Purple Hybrid Mattress             | 10-21-23968 |
      | Purple Hybrid Mattress OOP         | 10-21-60018 |
      | Purple Hybrid Mattress OOP         | 10-21-60006 |
      | Purple Hybrid Mattress OOP         | 10-21-60007 |
      | Purple Hybrid Mattress OOP         | 10-21-60008 |
      | Purple Hybrid Mattress OOP         | 10-21-60028 |
      | Royal Seat Cushion                 | 10-41-12573 |
      | Ultimate Seat Cushion              | 10-41-12564 |
      | Purple Ascent® Adjustable Base     | 10-38-12958 |
      | Purple Ascent® Adjustable Base     | 10-38-12959 |
      | Purple Ascent® Adjustable Base     | 10-38-12956 |
      | Purple Ascent® Adjustable Base     | 10-38-12957 |
      | TwinCloud Pillow                   | 10-31-12919 |
      | TwinCloud Pillow                   | 10-31-12920 |
      | Complete Comfort Pillowcase Set    | 10-38-23031 |
      | Complete Comfort Pillowcase Set    | 10-38-23036 |
      | Complete Comfort Pillowcase Set    | 10-38-23030 |
      | Complete Comfort Pillowcase Set    | 10-38-23035 |
      | Complete Comfort Pillowcase Set    | 10-38-23034 |
      | Complete Comfort Pillowcase Set    | 10-38-23039 |
      | Complete Comfort Pillowcase Set    | 10-38-23032 |
      | Complete Comfort Pillowcase Set    | 10-38-23037 |
      | Kid Sheets                         | 10-38-12854 |
      | Kid Sheets                         | 10-38-12852 |
      | Kid Sheets                         | 10-38-12855 |
#    | Sample1Harmony Replacement Core| 10-31-12910 |
      | The Purple Mattress                | 10-21-23617 |
      | The Purple Mattress                | 10-21-23618 |
      | The Purple Mattress                | 10-21-23620 |
      | The Purple Mattress                | 10-21-23625 |
      | The Purple Mattress                | 10-21-23632 |
      | The Purple Mattress                | 10-21-23960 |
      | The Purple Mattress                | 10-21-23638 |
      | Double Seat Cushion                | 10-41-12540 |
      | Pet Bed Replacement Covers         | 40-22-00010 |
      | Pet Bed Replacement Covers         | 40-22-00020 |
      | Pet Bed Replacement Covers         | 40-22-00030 |
      | Kid Purple Pillow                  | 10-31-12869 |
      | Kid Purple Pillow                  | 10-31-12872 |
      | Kid Purple Pillow                  | 10-31-12871 |
      | Kid Purple Pillow                  | 10-31-12873 |
#      | Purple Pet Bed      | 10-22-10100| -> unpublished but tag as published
#      | Purple Pet Bed      | 10-22-10200|
#      | Purple Pet Bed      | 10-22-10300|
#      | (Obsolete)Purple SoftStretch Sheets | 10-38-228301 |-> not existed
#      | (Obsolete)Purple SoftStretch Sheets | 10-38-228401 |
#      | (Obsolete)Purple SoftStretch Sheets | 10-38-228351 |
#      | (Obsolete)Purple SoftStretch Sheets | 10-38-228350|
#      | (Obsolete)Purple SoftStretch Sheets |10-38-228551 |
#      | (Obsolete)Purple SoftStretch Sheets |110-38-22845 |
#      | (Obsolete)Purple SoftStretch Sheets |10-38-228311 |
#      | (Obsolete)Purple SoftStretch Sheets |10-38-228411|
#      | (Obsolete)Purple SoftStretch Sheets |10-38-228361|
#      | (Obsolete)Purple SoftStretch Sheets |10-38-228511 |
#      | (Obsolete)Purple SoftStretch Sheets |10-38-228561|
#      | (Obsolete)Purple SoftStretch Sheets |10-38-228461 |
#      | (Obsolete)Purple SoftStretch Sheets |10-38-228321 |
#      | (Obsolete)Purple SoftStretch Sheets |10-38-228371|
#      | (Obsolete)Purple SoftStretch Sheets |10-38-228521|
#      | (Obsolete)Purple SoftStretch Sheets |10-38-228571|
#      | (Obsolete)Purple SoftStretch Sheets |10-38-228471|
#      | (Obsolete)Purple SoftStretch Sheets |10-38-228331|
#      | (Obsolete)Purple SoftStretch Sheets |10-38-228431|
      | The Purple Sheets                  | 10-38-12762 |
      | The Purple Sheets                  | 10-38-12847 |
      | The Purple Sheets                  | 10-38-12830 |
      | The Purple Sheets                  | 10-38-12848 |
#      | The Purple Sheets | 10-38-12779 |->unpublished
      | The Purple Sheets                  | 10-38-12823 |
      | The Purple Sheets                  | 10-38-12816 |
      | The Purple Sheets                  | 10-38-12849 |
      | The Purple Sheets                  | 10-38-12786 |
      | The Purple Sheets                  | 10-38-12809 |
      | The Purple Sheets                  | 10-38-12793 |
      | The Purple Sheets                  | 10-38-12850 |
      | The Purple Sheets                  | 10-38-12790 |
      | The Purple Sheets                  | 10-38-12787 |
      | The Purple Sheets                  | 10-38-12788 |
      | The Purple Sheets                  | 10-38-12789 |
      | The Purple Pillow                  | 10-31-12863 |
#      | MPOS Test Product (2) | 11-24-11242 |-> not existed
      | Purple Duvet                       | 10-38-13021 |
      | Purple Duvet                       | 10-38-13026 |
      | Purple Duvet                       | 10-38-13031 |
      | Bearaby Weighted Blanket           | 10-38-13051 |
      | Platform Base Replacement Hardware | 10-38-12897 |
      | Platform Base Replacement Hardware | 10-38-12896 |
#      | The Purple Face Mask 2 Pack| 10-47-20000|
      | Kid Purple Mattress                | 10-21-60524 |
      | Foldaway Seat Cushion              | 10-41-12574 |
      | Purple SoftStretch Pillowcases     | 10-38-22862 |
      | Purple SoftStretch Pillowcases     | 10-38-22861 |
      | Purple SoftStretch Pillowcases     | 10-38-22860 |
      | Purple SoftStretch Pillowcases     | 10-38-22863 |
      | Purple SoftStretch Pillowcases     | 10-38-22864 |
      | Purple SoftStretch Pillowcases     | 10-38-22865 |
      | Purple SoftStretch Pillowcases     | 10-38-22868 |
      | Purple SoftStretch Pillowcases     | 10-38-22866 |
#      | Purple SoftStretch Pillowcases | 10-38-22869 |
      | Purple SoftStretch Pillowcases     | 10-38-22867 |
      | Purple SoftStretch Pillowcases     | 10-38-22870 |
      | Purple SoftStretch Pillowcases     | 10-38-22871 |
      | Purple Cloud Pillow                | 10-31-12921 |
      | Purple Cloud Pillow                | 10-31-12922 |
      | Premium Sleep Mask                 | 10-21-68268 |
      | Replacement Covers                 | 40-21-42018 |
      | Replacement Covers                 | 40-21-42748 |
      | Replacement Covers                 | 40-21-42025 |
      | Replacement Covers                 | 40-21-42032 |
      | Replacement Covers                 | 40-21-42060 |
      | Replacement Covers                 | 40-21-42150 |
      | Replacement Covers                 | 40-21-42155 |
      | Replacement Covers                 | 40-21-42160 |
      | Replacement Covers                 | 40-21-42170 |
      | Replacement Covers                 | 40-21-42180 |
      | Replacement Covers                 | 40-21-42190 |
      | Replacement Covers                 | 40-21-42195 |
      | Replacement Covers                 | 40-21-42200 |
      | Replacement Covers                 | 40-21-42210 |
      | Replacement Covers                 | 40-21-42220 |
      | Replacement Covers                 | 40-21-42230 |
      | Replacement Covers                 | 40-21-42235 |
      | Replacement Covers                 | 40-21-42240 |
      | Replacement Covers                 | 40-21-42250 |
      | Replacement Covers                 | 40-21-42260 |
      | Purple Foundation                  | 10-38-45862 |
      | Purple Foundation                  | 10-38-45868 |
      | Purple Foundation                  | 10-38-45863 |
      | Purple Foundation                  | 10-38-45869 |
      | Purple Foundation                  | 10-38-45864 |
      | Purple Foundation                  | 10-38-45870 |
      | Purple Foundation                  | 10-38-45865 |
      | Purple Foundation                  | 10-38-45871 |
      | Purple Foundation                  | 10-38-45866 |
      | Purple Foundation                  | 10-38-45872 |
      | Purple Foundation                  | 10-38-45867 |
      | Purple Foundation                  | 10-38-45873 |
      | Precious Dreams Donation           | 15819       |

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