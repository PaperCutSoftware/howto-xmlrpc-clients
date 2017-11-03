#!/usr/bin/env python3

import xmlrpc.client

host = "localhost"
port = "8080"
urlEndPoint="http://"+host+":"+port+"/users"

proxy = xmlrpc.client.ServerProxy(urlEndPoint) 

testUser = "alec" # valid test data

try:
    result = proxy.userExist(testUser)
    print("\nCalled userExist() on user {}, result {}".format(
        testUser, result))
    result = proxy.getUserAllDetails(testUser)
    print("Called getUser() on user {}, UUID is {}, status is {}".format(
        testUser, result["UUID"], result["status"]))

except xmlrpc.client.Fault as error:
    print("\nCalled users API on user {} failed! reason {}".format(
        testUser, error.faultString))

except xmlrpc.client.ProtocolError as error:
    print("\nA protocol error occurred\nURL: {}\nHTTP/HTTPS headers: {}\n" +
          "Error code: {}\nError message: {}".format(
        error.url, error.headers, error.errcode, error.errmsg))

