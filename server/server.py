#!/usr/bin/env python3

# Adapted from https://docs.python.org/3/library/xmlrpc.server.html#xmlrpc.server.SimpleXMLRPCServer

# Provide a test for valid username
# Provide a "database" lookup from username to user UUID (and status)

userDatabase = {
        "ahmed": {"UUID": "1111111", "status" : "active" },
        "jane": {"UUID": "1111112", "status" : "inactive" },
        "alec": {"UUID": "1111113", "status" : "active" },
        }

from xmlrpc.server import SimpleXMLRPCServer
from xmlrpc.server import SimpleXMLRPCRequestHandler
from xmlrpc.client import Fault

# Restrict to a particular path.
class RequestHandler(SimpleXMLRPCRequestHandler):
    rpc_paths = ('/users',)

# Create server
with SimpleXMLRPCServer(("localhost", 8080),
                        requestHandler=RequestHandler) as server:
    server.register_introspection_functions()

    # Does a user exist?
    def userExist(u):
        if u in userDatabase:
            return True
        raise Fault(1 , "userExist(): User {} not found".format(u))
    server.register_function(userExist)

    # Get the UUID for a given user
    def getUserUUID(u):
        if userExist(u):
            return {"user": u, "UUID": userDatabase[u]["UUID"]}
        # else Fault is returned to client
    server.register_function(getUserUUID)

    # Get all the user details for a given user
    def getUserAllDetails(u):
        if userExist(u):
            return {"user": u, "UUID": userDatabase[u]["UUID"], "status": userDatabase[u]["status"]}
        # else Fault is returned to client
    server.register_function(getUserAllDetails)

    # Run the server's main loop
    server.serve_forever()

