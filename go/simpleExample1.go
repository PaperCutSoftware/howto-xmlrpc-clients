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

	buf, _ := xml.EncodeClientRequest("userExist", args)
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
		fmt.Printf("Error %v\n", err)
		return
	}

	fmt.Printf("Return data is %v\n", reply.Present)
}
