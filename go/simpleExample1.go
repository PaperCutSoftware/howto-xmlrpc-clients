package main

import (
	"bytes"
	"fmt"
	"net/http"

	"github.com/divan/gorilla-xmlrpc/xml"
)

const (
	host     = "localhost"
	port     = "8080"
	testUser = "alec"
)

func main() {

	var args interface{}

	args = &struct { // Magic Data Structure
		Name string // All members are exported
	}{
		testUser,
	}

	buf, _ := xml.EncodeClientRequest("userExists", args)
	response, err := http.Post("http://"+host+":"+port+"/users", "text/xml", bytes.NewBuffer(buf))

	if err != nil {
		fmt.Printf("Post Error %v\n", err)
		return
	}

	defer response.Body.Close() // Can't defer until we know we have a response

	if response.StatusCode != http.StatusOK {
		fmt.Printf("Error status %v, %v\n", response.Status)
		return
	}

	defer response.Body.Close() // Can't defer until we know we have a response

	var reply struct{ Present bool } // Magic data strcuture
	err = xml.DecodeClientResponse(response.Body, &reply)
	if err != nil {
		fmt.Printf("Error on functions userExists(\"%v\") returns %v\n", testUser, err)
		return
	}
	fmt.Printf("Return on functions userExists(\"%v\") data is %v\n", testUser, reply.Present)
}
