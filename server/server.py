#!/usr/bin/env python3

# Adapted from https://docs.python.org/3/library/xmlrpc.server.html#xmlrpc.server.SimpleXMLRPCServer

# Provide a test for valid username
# Provide a "database" lookup from username to user UUID (and status)

userDatabase = {
        "ahmed": {"UUID": "1111111", "activeStatus" : True },
        "jane":  {"UUID": "1111112", "activeStatus" : False },
        "alec": {"UUID": "1111113", "activeStatus" : True },
        }

from xmlrpc.server import SimpleXMLRPCServer
from xmlrpc.server import SimpleXMLRPCRequestHandler
from xmlrpc.client import Fault

def userExists(u):
    """Does a user exist?"""
    return (u in userDatabase)

def getActiveUserUUID(u):
    """Get the UUID for given active user"""
    return getUserUUIDbyState(u, "active")

def getUserUUIDbyStatus(u, s):
    """Get the UUID for a given user, any status"""
    if userExists(u) and userDatabase[u]["activeStatus"] == s:
        return {"user": u, "UUID": userDatabase[u]["UUID"]}
    else:
        raise Fault(1, "No {status} user {user} found".format(status = "active" if s else "inactive", user=u))

def getUserAllDetails(u):
    """Get all the user details for a given user"""
    if userExists(u):
        result = userDatabase[u]
        result.update({"user": u})
        return result
    else:
        raise Fault(1, "No user {} found".format(u))

def getAllUsersByStatus(s):
    """List all the users, filtered by their active status"""
    # NOTE: Normally it's bad practice to return a potentially huge list.
    result = []
    for user, info in userDatabase.items():
        if info["activeStatus"] == s:
            info.update({"user": user})
            result.append(info)

    if len(result) == 0:
        raise Fault(2, "No users found with active status of {}".format(s))

    return result

if __name__ == "__main__":
    class RequestHandler(SimpleXMLRPCRequestHandler):
        rpc_paths = ('/users',)

    # Create server
    with SimpleXMLRPCServer(("localhost", 8080),
                requestHandler=RequestHandler) as server:

        server.register_introspection_functions()
        server.register_function(userExists)
        server.register_function(getActiveUserUUID)
        server.register_function(getUserUUIDbyStatus)
        server.register_function(getUserAllDetails)
        server.register_function(getAllUsersByStatus)

        # Run the server's main loop
        server.serve_forever()

