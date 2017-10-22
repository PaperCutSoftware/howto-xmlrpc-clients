#!/usr/bin/env python3

import xmlrpc.client

host = "localhost"
port = "8080"

urlEndPoint="http://"+host+":"+port+"/users" # Correct endpoint

wrongURLEndPoint="http://"+host+":"+port+"/notcorrect" # Test with the incorrect end point

proxy = xmlrpc.client.ServerProxy(wrongURLEndPoint)

testUser = "alec" # Test with valid data

try:
    result = proxy.userExist(testUser)  # Call method with incorrect end point
    print("Called userExist() on user {}, result {}".format(testUser, result))
except xmlrpc.client.Fault as error:
    print("called userExit with wrong end point. Return fault is {}".format(error.faultString))
except xmlrpc.client.ProtocolError as error:
    print("A protocol error occurred\nURL: {}\nHTTP/HTTPS headers: {}\nError code: {}\nError message: {}".format(
        error.url, error.headers, error.errcode, error.errmsg))

proxy = xmlrpc.client.ServerProxy(urlEndPoint) # Now use correct end point

# Pass incorrect arguments to remote procedure
try:
    result = proxy.userExist(testUser, 21)  # Call method with incorrect arguments
    print("\nCalled userExist() on user {}, result {}".format(testUser, result))
except xmlrpc.client.Fault as error:
    print("\ncalled userExit with incorrect args. Return fault is {}".format(error.faultString))
except xmlrpc.client.ProtocolError as error:
    print("\nA protocol error occurred\nURL: {}\nHTTP/HTTPS headers: {}\nError code: {}\nError message: {}".format(
        error.url, error.headers, error.errcode, error.errmsg))

for testUser in  ["alec","noOne"]:  # One valid request, one for non existant data
    try:
        result = proxy.userExist(testUser)
        print("\nCalled userExist() on user {}, result {}".format(testUser, result))
        result = proxy.getUserAllDetails(testUser)
        print("Called getUser() on user {}, UUID is {}, status is {}".format(testUser, result["UUID"], result["status"]))
    except xmlrpc.client.Fault as error:
        print("\nCalled users API on user {} failed! reason {}".format(testUser, error.faultString))
    except xmlrpc.client.ProtocolError as error:
        print("\nA protocol error occurred\nURL: {}\nHTTP/HTTPS headers: {}\nError code: {}\nError message: {}".format(
            error.url, error.headers, error.errcode, error.errmsg))

