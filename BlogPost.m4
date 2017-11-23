% How to write XML-rpc clients
% Alec Clews
% November 2017

m4_changequote([[, ]])

# Introduction

The XML-RPC network protocol is a popular, small lightweight, network protocol for
clients to make function calls to a server and receive the results.

The [specification](http://XMLrpc.scripting.com/spec.html) has been around since 1999.
New servers will probably offer remote procedure calls based in more modern
technology, for example [gRPC](https://grpc.io/).
However it's very possible you will still need to write or support an XML-RPC client
to access an existing server.
Here are at [PaperCut](https://papercut.com) we are embracing newer
network RPC protocols, but we still support a number of legacy APIs that use XML-RPC.

I hope these notes will be useful enough to get you started if you have never used XML-RPC before.
Of particular interest to XML-RPC novices will be using curl to see the raw XML
in the function calls, and the troubleshooting tips at the end.

The XML-RPC model is very simple -- you make a call and you wait to get a single response.
There is no asynchronous model, no streaming and no security.
Note that there are some XML-RPC libraries which extend this model,
but we don't discuss them further.

# How does XML-RPC work technically?

That question is best answered by reading the specification. But the short answer is

![The XML-RPC call sequence](diagram.png)

1. The client sends an XML document, using a HTTP(S) POST request, to the server.
The XML schema is simple -- refer to the specification for details

<!-- end of list -->

4. HTTP status and an XML payload containing return values *OR*
5. HTTP status and a fault, also delivered in an XML document. 
The schema is equally simply and you can find examples below.

# What does this look like?

The easiest way to understand this is to send XML-RPC requests using `curl`
on the command line.
You can then see the response details,
which are often hidden when you program using
nice helpful libraries that handle the low level specifics.

If you are using Linux or macOS then you already have curl installed,
otherwise you will need to [install](https://curl.haxx.se/download.html) it for yourself.

If you want to follow on with these examples the code is on
[GitHub](https://github.com/PaperCutSoftware/howto-xmlrpc-clients)

I've written a very simple XML-RPC server in Python 3 that supports the following method calls:

m4_syscmd([[for i in $(sed -nEe '/server.register_function/s/^.+server.register_function\(([^)]+)\)/\1/p' server/server.py) ; do echo '* `'$i'()`' -- $(python3 -c "import server.server;print(server.server.$i.__doc__)");done]])

It's all a bit simplistic, but hopefully enough for us to understand how to write clients.

So I can start up the `server.py` program and it will serve requests on http://localhost:8080/users.

Once the server is running then we can start to experiment from the command line.
First create the request payload in a file called `simpleExample1.xml`
(it can be called anything, this is just the name I am using).

```xml
m4_include(xml/simpleExample1.xml)
```

Now I can run the following command to test the connection

`curl -v http://localhost:8080/users --data @simpleExample1.xml`

and hopefully get something like this

```
m4_syscmd(curl --stderr - -sv http://localhost:8080/users --data @xml/simpleExample1.xml)
```

Notice that this simple example is actually not that simple. The `getUserAllDetails()`
returns a struct that contains different types (strings and a boolean).

So now you can start to experiment and see whats happens when you get the URL wrong
(the HTTP status changes), when you send ill formed XML and when you try and call method
that does not exist.
I'm not going to go through all these examples here but for instance what happens
when we ask for the UUID of a non existent user?

If we create another payload file with the following content

```
m4_include(xml/simpleExample2.xml)

```
To understand the specifics of the various XML elements refer to the XML-RPC specification.

The response from the server is 

```
m4_syscmd(curl --stderr - -sv http://localhost:8080/users --data @xml/simpleExample2.xml)
```

Notice that the HTTP response is still 200, but the XML payload now contains a \<fault> element,
instead of a \<params> element.
It will depend on the library functions you use as to how the details of this work
in your client code. For instance in Python the caller gets a `Fault` exception, but
in Java it's part of the `xmlRpcExcetion` (which also handles the HTTP exceptions)

I recommend you experiment further with this technique both as learning tool and a
debugging tool.

I have also included a sample XML payload that shows what happens when you call
a method with the wrong paramters.

# Using a real programming language.

Working at the XML level is very educational, but writing shell scripts is not
a very practical way to write a high performance, robust, client.
So what tools do you need?

1. Your favourite programming language:
The good news is that you have lots of choices because XML-RPC is language agnostic.
The rest if this post will use Python3 to illustrate the concepts,
but I have provided some equivalent examples in
[Java](https://github.com/PaperCutSoftware/howto-xmlrpc-clients/tree/master/java) and
[Go](https://github.com/PaperCutSoftware/howto-xmlrpc-clients/tree/master/go).
2. An XML-RPC specific library that handles all of the hard work around method names, arguments and responses from the server.
There are sometimes multiple options for a specific environment so you may need to do some investigation to see what works best
for you.

Here is a list of the libraries that we have used here at PaperCut.

|Language | Library|
|---------|--------|
| Java    | org.apache.xmlrpc|
| Go      | gorilla-xmlrpc |
| .NET    | Cook Computing XML-RPC.NET|
| Python3 | xmlrpc.client| 
| Python2 | xmlrpclib|
| Perl    | RPC::XML::Client|

You can find other suggestions on the XML-RPC
[website](http://www.xmlrpc.com/directory/1568/implementations).

I'll use the same Python server and create a Python client using the `xmlrpc.client` library.

Please note that all this examples are very simplistic and are designed to 
illustrate the basic process of making XML-RPC calls and handling the responses.

In production code you will probably want to provide an application wrapper to map
between domain structures or objects and the data structures supported by the
XML-RPC library you are using.

(for example of this wrapper approach please see the
[complex](https://github.com/PaperCutSoftware/howto-xmlrpc-clients/blob/master/go/complexExampleWithProxy.go)
Go example)

Most XML-RPC libraries work in a similar fashion

1. Create some form of proxy structure. Note that this is internal to the client only,
no connection is started with the server.
2. Make method calls via the proxy.
3. Check the results and handle any exceptions.

So now you can start to explore how to use code to call your XML-RPC server.

So in Python:

```python
m4_esyscmd([[sed -ne '/import xmlrpc.client/,/proxy/p' python3/simpleExample1.py]])
```

Now we have a proxy object "connected" to the correct URL. But remember nothing
has happened on the network yet, we've just set up a data structure.

Let's actually try and make a procedure call across the network:

```python
m4_esyscmd([[sed -ne '/getUserAllDetails/,+3p' python3/simpleExample1.py]])
```

Straight away we are working at a much higher level.

* We are not handling raw XML
* Information is stored in native Python data structures

However tihngs can go wrong and we we can use standard Python exception mechanisms to manage any errors.

A more complete version of the above example would be

```python
m4_esyscmd([[sed -ne '/try:/,$p' python3/simpleExample1.py]])
```

and when we run it we get the following output

```
m4_esyscmd([[python3/simpleExample1.py]])
```

By contrast if we get the user name wrong for instance we get an exception.

```
m4_esyscmd([[sed -e 's/alec/anotherUser/' python3/simpleExample1.py|python3|fold -w 60]])
```

I have included the full code to this example (`simpleExample1.py`),
you can run these various examples to see what happens when things goes wrong.
To get you started I created a program called `simpleExampleWithErrors1.py`

# Security

XML-RPC provides no security security mechanisms and so
it's up to the server developer to provide security for client requests.

At the very minimum all method calls and responses should be sent via HTTPS.
However the specific HTTPS mechanisms will vary depending on the XML-RPC library
you are using. Please refer to the documentation for the appropriate library.

Additional security options include:

1. [TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security)
2. [JWT](https://jwt.io/)
3. username/password authentication (can also be used with JWT and shared secret)
4. Shared secret, provided via an additional method parameter. This is the approach
used by PaperCut as it easy for client developers to use.

## Client Authentication

As the protocol has no built in security,
server developers should add additional authentication layers in their methods.
One technique that we use at PaperCut is
to require clients to provide a shared secret on each method call. In addition
all remote clients must have their IP addresses white listed in the server.

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
This is the approach as I showed at the start of the post and
I used this technique to debug some problems with the test server
I wrote for this article.

If it succeeds then there is a bug in my client and if the call fails
then I've made an incorrect assumption about how the server works.

