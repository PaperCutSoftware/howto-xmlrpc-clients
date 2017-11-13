#!/usr/bin/env python3

import xmlrpc.client

host = "localhost"
port = "8080"

urlEndPoint="http://"+host+":"+port+"/users" # Correct endpoint

# Test with the incorrect end point
wrongURLEndPoint="http://"+host+":"+port+"/notcorrect"

testUser = "alec" # Test with valid data

try:
    proxy = xmlrpc.client.ServerProxy(wrongURLEndPoint)
    result = proxy.userExists(testUser)  # Call method with incorrect end point
    print("Called userExist() on user {}, result:\n{}".format(
        testUser, result))

except xmlrpc.client.Fault as error:
    print("called userExit with wrong end point.\nReturn fault is {}".format(
        error.faultString))

except xmlrpc.client.ProtocolError as error:
    print("""\nA protocol error occurred\nURL: {}\nHTTP/HTTPS headers: {}
Error code: {}\nError message: {}""".format(
        error.url, error.headers, error.errcode, error.errmsg))

except ConnectionError as error:
    print("\nConnection error. Is the server running? {}".format(error))


proxy = xmlrpc.client.ServerProxy(urlEndPoint) # Now use correct end point

# Pass incorrect arguments to remote procedure
try:
    # Call method with incorrect arguments
    result = proxy.userExists(testUser, 21)
    print("\nCalled userExist() on user {}, result {}".format(testUser, result))
except xmlrpc.client.Fault as error:
    print("\ncalled userExit with incorrect args.\nReturn fault is {}".format(
        error.faultString))
except xmlrpc.client.ProtocolError as error:
    print("""\nA protocol error occurred\nURL: {}\nHTTP/HTTPS headers: {}
          "Error code: {}\nError message: {}""".format(
        error.url, error.headers, error.errcode, error.errmsg))

# One valid request, one for non existant data
for testUser in  ["alec","noOne"]:
    try:
        result = proxy.userExists(testUser)
        print("\nCalled userExist() on user {}, result {}".format(
            testUser, result))
        result = proxy.getUserAllDetails(testUser)
        print("""Called getUserAllDetails() on user {},
UUID is {},
active status is {}""".format(
            testUser, result["UUID"], result["activeStatus"]))
    except xmlrpc.client.Fault as error:
        print("\nCalled users API on user {} failed!\nreason {}".format(
            testUser, error.faultString))
    except xmlrpc.client.ProtocolError as error:
        print("""\nA protocol error occurred
URL: {}\nHTTP/HTTPS headers: {}
Error code: {}\nError message: {}""".format(
            error.url, error.headers, error.errcode, error.errmsg))

