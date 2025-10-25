*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String

*** Variables ***
${BASE_URL}    https://simple-books-api.click
${CLIENT_NAME}    mohamed adel
${CLIENT_EMAIL}    robot.test@example.com
${TOKEN}    
${ORDER_ID}  

*** Test Cases ***
Test API Status
   
    Create Session    api_session    ${BASE_URL}
    ${response}=    GET On Session    api_session    /status
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${json['status']}    OK

Get List Of Books
    
    Create Session    api_session    ${BASE_URL}
    ${response}=    GET On Session    api_session    /books
    Should Be Equal As Strings    ${response.status_code}    200
    ${books}=    Set Variable    ${response.json()}
    Should Not Be Empty    ${books}
    Log Many    @{books}

Get List Of Fiction Books With Limit
    [Documentation]    الحصول على كتب الخيال مع حد أقصى
    Create Session    api_session    ${BASE_URL}
    ${params}=    Create Dictionary    type=fiction    limit=4
    ${response}=    GET On Session    api_session    /books    params=${params}
    Should Be Equal As Strings    ${response.status_code}    200
    ${books}=    Set Variable    ${response.json()}
    ${length}=    Get Length    ${books}
    Should Be True    ${length} <= 4
    

Get Single Book Details

    Create Session    api_session    ${BASE_URL}
    ${response}=    GET On Session    api_session    /books/1
    Should Be Equal As Strings    ${response.status_code}    200
    ${book}=    Set Variable    ${response.json()}
    Should Contain    ${book}    id
    Should Contain    ${book}    name
    Should Contain    ${book}    author
    Should Contain    ${book}    available

Register API Client and take the token 
    
    Create Session    api_session    ${BASE_URL}
   
    ${timestamp}=    Get Time    epoch
    ${unique_email}=    Set Variable    mohamed.test.${timestamp}@yahoo.com
    ${client_data}=    Create Dictionary    clientName=${CLIENT_NAME}    clientEmail=${unique_email}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    POST On Session    api_session    /api-clients/    json=${client_data}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    201
    ${json}=    Set Variable    ${response.json()}
    Should Contain    ${json}    accessToken
    Set Suite Variable    ${TOKEN}    ${json['accessToken']}
    Log    Token received: ${TOKEN}

Submit Book Order
   
    [Tags]    authenticated
    Skip If    '${TOKEN}' == ''   must have token 
    Create Session    api_session    ${BASE_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}    Content-Type=application/json
    ${order_data}=    Create Dictionary    bookId=1    customerName=mohamed adel tester
    ${response}=    POST On Session    api_session    /orders    json=${order_data}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    201
    ${json}=    Set Variable    ${response.json()}
    Should Contain    ${json}    orderId
    Set Suite Variable    ${ORDER_ID}    ${json['orderId']}
    Log    Order created with ID: ${ORDER_ID}

Get All Orders

    [Tags]    authenticated
    Skip If    '${TOKEN}' == ''   must have token 
    Create Session    api_session    ${BASE_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}
    ${response}=    GET On Session    api_session    /orders    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${orders}=    Set Variable    ${response.json()}
    Log Many    @{orders}

Get Single Order
    
    [Tags]    authenticated
    Skip If    '${TOKEN}' == '' or '${ORDER_ID}' == ''   must have token and order id first
    Create Session    api_session    ${BASE_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}
    ${response}=    GET On Session    api_session    /orders/${ORDER_ID}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${order}=    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${order['id']}    ${ORDER_ID}
    Should Contain    ${order}    bookId
    Should Contain    ${order}    customerName

Update Order
    [Documentation]   
    [Tags]    authenticated
    Skip If    '${TOKEN}' == '' or '${ORDER_ID}' == ''   must have token and order id first
    Create Session    api_session    ${BASE_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}    Content-Type=application/json
    ${update_data}=    Create Dictionary    customerName=youssef 
    ${response}=    PATCH On Session    api_session    /orders/${ORDER_ID}    json=${update_data}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    204

Verify Order Updated
   
    [Tags]    authenticated
    Skip If    '${TOKEN}' == '' or '${ORDER_ID}' == ''   must have token and order id first and updated  
    Create Session    api_session    ${BASE_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}
    ${response}=    GET On Session    api_session    /orders/${ORDER_ID}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${order}=    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${order['customerName']}    youssef

Delete Order
    
    [Tags]    authenticated
    Skip If    '${TOKEN}' == '' or '${ORDER_ID}' == ''   must have token and order id first and deleted
    Create Session    api_session    ${BASE_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}
    ${response}=    DELETE On Session    api_session    /orders/${ORDER_ID}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    204

Verify Order Deleted
   
    [Tags]    authenticated
    Skip If    '${TOKEN}' == '' or '${ORDER_ID}' == ''   must have token and order id first and deleted
    Create Session    api_session    ${BASE_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}
    ${response}=    GET On Session    api_session    /orders/${ORDER_ID}    headers=${headers}    expected_status=404
    Should Be Equal As Strings    ${response.status_code}    404

Test Invalid Book ID
    
    Create Session    api_session    ${BASE_URL}
    ${response}=    GET On Session    api_session    /books/999999    expected_status=404
    Should Be Equal As Strings    ${response.status_code}    404

Test Unauthorized Access
    
    Create Session    api_session    ${BASE_URL}
    ${response}=    GET On Session    api_session    /orders    expected_status=401
    Should Be Equal As Strings    ${response.status_code}    401

