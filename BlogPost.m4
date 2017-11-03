% How to write xml-rpc clients
% Alec Clews
% November 2017

m4_changequote([[, ]])

# Introduction

The XML-RPC network protocol is small lightweight network protocol for software clients
to make function calls to server and receive the results.

The [specification](http://xmlrpc.scripting.com/spec.html) has been around since 1999.
New servers will probably want to offer remote procedure calls based in more modern
technology, for example [gRPC](https://grpc.io/).
However it's very possible you will still need to write or support an XML-RPC client
to access an existing server, and
I hope these notes will be useful enough to get you started if you have never used XML-RPC before.

The XML-RPC model is very simple -- you make a call and you wait to get a single response.
There is no asynchronous model, no streaming and no security.
Note that there are some XML-RPC libraries which extend this model,
but we don't discuss them here.

# How does XML-RPC work?

That question is best answered by reading the specification. But the short answer is

1. The client sends an xml document, using a HTTP(S) POST request, to the server.
The xml schema is simple -- refer to the specification for details

2. The HTTP response contains the HTTP status and an xml payload.
The xml returned is either the data requested or a fault.
More details on on the data layout below.

# What does this look like?

The easiest way to understand this is to send XML-RPC requests using curl.
You can then see the response details,
which are often hidden when you program using
nice helpful libraries to handle the low level specifics.

If you want to follow on with these examples the code is on
[GitHub](https://github.com/PaperCutSoftware/howto-xmlrpc-clients)

I've written a very simple XML-RPC server in Python 3 that supports four method calls:

1. `userExists` -- checks in the "database" (actually just a Python dictionary) to check the username
2. `getUserUUID`  -- which just returns the unique user identifying string for this user.
3. `getUserAllDetails`  -- which returns all the details for the given username (the username, the UUID and the status)

It's all a bit simplistic, but hopefully enough for us to understand how to write our clients.

So I can start up the `server.py` program and it will server requests on http://localhost:8080/users.

Once the server is running then we can start to experiment from the command line.
First create the request payload in a file called `simpleExample1.xml`
(it can be called anything, this is just the name I am using).

```xml
m4_include(xml/simpleExample1.xml)
```

Now I can run the following command to test the connection

`curl -v http://localhost:8080/users --data @data.xml`

and hopefully get something like this

```
m4_syscmd(curl --stderr - -sv http://localhost:8080/users --data @xml/simpleExample1.xml)
```

So now you can start to experiment and see whats happens when you get the URL wrong
(the HTTP status changes), when you send ill formed xml and when you try and call method
that does not exist.
I'm not going to go through all these examples here but for instance what happens
when we ask for the UUID of a non existant user?

If we create another payload file with the following content

```
m4_include(xml/simpleExample2.xml)

```

The response from the server is 

```
m4_syscmd(curl --stderr - -sv http://localhost:8080/users --data @xml/simpleExample2.xml)
```


Notice that the HTTP response is still 200, bit the XML payload now contains a \<fault>,
instead of a \<params>.
It will depend on the library functions you use as to how the details of this work
in your client code. For instance in Python the caller gets a `Fault` excepetion, but
in Java it's part of the xmlRpcExcetion (which also handles the HTTP excepetions)

I recommend you experiment further with this technique both as learning tool and a
debugging tool.

# Using a real programming language.

Working at the xml level is very educational, bit writing shell scripts is not
a very practical way to write a high performance, robust, client.
So what tools do you need?

1. Your favourite programming language:
The good news is that you have lots of choices because XML-RPC is language agnostic.
The rest if this post will use Python3 to illustrate the concepts,
but I will upload some equivalent examples in Java and Go programming languages 
2. An XML-RPC specific library that handles all of the hard work around method names, arguments and responses from the server.
There are sometimes multiple options for a specific environment so you may need to do some investigation to see what works best in your environment.

Here is a list of the libraries that we have used here at PaperCut.

|Language | Library|
|---------|--------|
| Java    | org.apache.xmlrpc|
| Go      | gorilla-xmlrpc |
| .NET    | Cook Computing XML-RPC.NET|
| Python3 | xmlrpc.client| 
| Python2 | xmlrpclib|
| Perl    | RPC::XML::Client|

You can find other suggestions on the xml-rpc
[website](http://www.xmlrpc.com/directory/1568/implementations)

I'll use the same Python server and create a Python client using the xmlrpc.client library.
Other language exmaples to follow are also provided.

Please note that all this examples are very simplistic and are designed to simply
illustreaite the basic process of makeing xml-rpc calls and handling the resonses.

In a producttion code you will probably want to provide an application wrapper to map
between domain structures or obejcts and the data structures supported by the
xmlrpc library you are using.

So straight away the xmlrpc library gives us a lot convicence.

1. No need to generate or parse xml payloads. We just use native Python data structures.
2. We can handle errors using the native exception handling in Python


Most XML-RPC libraries work in a similar fashion

1. Create some form of proxy structure. Note that this is internal to the client only,
no connection is started with the server.
2. Make method calls via the proxy.
3. Check the results and handle any exceptions.

So now you can start to explore how to use code to call your XML-RPC server.

So in Python

```python
m4_esyscmd([[sed -ne '/import xmlrpc.client/,/proxy/p' python3/simpleExample1.py]])
```

Now we have a proxy object "connected" to the correct URL. But remember nothing
has happened on the network yet, we've just set up a data structure.

Let's actually try and make a procedure call across the network

```python
m4_esyscmd([[sed -ne '/try:/,$p' python3/simpleExample1.py]])
```

Straight away we are working at a much higher level.

* We are not handling raw xml
* Information is stored in native Python data structures
* We can use standard Python exception mechanisms to manage any errors

I have included the full code to this example (`simpleExample1.py`),
you can run these various examples to see what happens when things goes wrong.
To get you started I created a program called `simpleExampleWithErrors1.py`

# Troubleshooting

So the Python client `simpleExampleWithErrors1.py` shows examples of a number of problems you can experience.
The way that the error is reported back to your client will depend the server and
the XML-RPC library you use.

Things to check are:

1. Are you using the correct URL endpoint?
2. Is the server running?
3. Is there a firewall or something else blocking network connections?
4. Does the server code have some additional security requirement you have not satisfied? (e.g. passing additional security parameters)
5. Are you using the correct method name?
6. Do you have the correct number of parameters?
7. Is each parameter of the correct type.

## Passing the correct parameter type

This problem can be hard to spot if your language has defaults about type.
For instance 3 is an integer and so will be passed as `<int>3</int>`,
but if the server is expecting a float then this will probably fail
with a type mismatch.

## Low level debugging

If you have checked all the above then I find the most productive approach
is to use curl to send the XML request I _think_ my code is sending.
This is same technique as I used at the start of the post.

If it succeeds then there is a bug in my client and if the call fails
then I've made an incorrect assumption about how the server works.

