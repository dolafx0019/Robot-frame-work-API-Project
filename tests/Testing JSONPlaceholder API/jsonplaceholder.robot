*** Settings ***

Library          RequestsLibrary
Library          Collections

Suite Setup      Create Session    jsonplaceholder    https://jsonplaceholder.typicode.com

*** Test Cases ***
Test 01: Get All Posts
    ${response}=    GET On Session    jsonplaceholder    /posts
    Status Should Be    200
    ${posts}=    Set Variable    ${response.json()}
    Length Should Be    ${posts}    100

Test 02: Get Single Post
    ${response}=    GET On Session    jsonplaceholder    /posts/1
    Status Should Be    200
    ${post}=    Set Variable    ${response.json()}
    Should Be Equal As Integers    ${post}[id]    1
    Should Not Be Empty    ${post}[title]

Test 03: Create New Post
    &{data}=    Create Dictionary
    ...    title=hello world
    ...    body=today is a bautiful day
    ...    userId=1
    
    ${response}=    POST On Session    jsonplaceholder    /posts    json=${data}
    Status Should Be    201
    ${created}=    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${created}[title]    hello world

Test 04: Update Post
    &{data}=    Create Dictionary
    ...    id=1
    ...    title=bad world
    ...    body=dark day
    ...    userId=1
    
    ${response}=    PUT On Session    jsonplaceholder    /posts/1    json=${data}
    Status Should Be    200

Test 05: Delete Post
    ${response}=    DELETE On Session    jsonplaceholder    /posts/1
    Status Should Be    200

Test 06: Get Comments of Post
    ${response}=    GET On Session    jsonplaceholder    /posts/1/comments
    Status Should Be    200
    ${comments}=    Set Variable    ${response.json()}
    Should Not Be Empty    ${comments}

Test 07: Filter Posts By UserId
    ${response}=    GET On Session    jsonplaceholder     url=/posts?userId=1
    Status Should Be    200
    ${posts}=    Set Variable    ${response.json()}
    FOR    ${post}    IN    @{posts}
        Should Be Equal As Integers    ${post}[userId]    1
    END