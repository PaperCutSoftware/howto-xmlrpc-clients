# HOW TO XML-RPC Clients

CURRENT STATUS:  DRAFT!!!!

This is a small repo that contained the supporting material for a recent
post on the PaperCut Developer blog


.
├── BlogPost.m4 - article spource
├── LICENSE
├── Makefile  -- Build the output. Need pandoc, m4 etc
├── README.md
├── go  -- Simple examples in Go lang
│   ├── simpleExample1.go
│   └── simpleExampleWithErrors1.go
├── java  -- Simple examples in Java
│   ├── build
│   │   ├── classes
│   │   │   └── java
│   │   │       └── main
│   │   │           ├── App.class
│   │   │           ├── SimpleExample1.class
│   │   │           └── SimpleExampleWithErrors1.class
│   │   ├── distributions
│   │   │   ├── howtoxmlrpcclients.tar
│   │   │   └── howtoxmlrpcclients.zip
│   │   ├── libs
│   │   │   └── howtoxmlrpcclients.jar
│   │   ├── scripts
│   │   │   ├── howtoxmlrpcclients
│   │   │   └── howtoxmlrpcclients.bat
│   │   └── tmp
│   │       ├── compileJava
│   │       └── jar
│   │           └── MANIFEST.MF
│   ├── build.gradle
│   ├── gradle
│   │   └── wrapper
│   │       ├── gradle-wrapper.jar
│   │       └── gradle-wrapper.properties
│   ├── gradlew
│   ├── gradlew.bat
│   ├── settings.gradle
│   └── src
│       └── main
│           └── java
│               ├── App.java
│               ├── SimpleExample1.java
│               └── SimpleExampleWithErrors1.java
├── python3 -- Simple examples in Python 3, start here
│   ├── simpleExample1.py
│   └── simpleExampleWithErrors1.py
├── server  -- Simple server to run the example clients
│   └── server.py
└── xml  -- Real low level XML examples
    ├── simpleExample1.xml
    └── simpleExample2.xml

20 directories, 30 files
