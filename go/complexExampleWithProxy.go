// Show how to create and use a xml-rpc proxy
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

type userRecord struct { //Magic. All fields are exported for xml-rpc lib
	User         string
	UUID         string
	ActiveStatus bool
}

type XMLclient struct {
	host string
	port string
}

// Make the RPC call
func xmlRpcCall(c XMLclient, method string, args interface{}, reply interface{}) error {
	buf, _ := xml.EncodeClientRequest(method, args)
	response, err := http.Post("http://"+c.host+":"+c.port+"/users", "text/xml", bytes.NewBuffer(buf))
	if err != nil {
		return err
	}
	defer response.Body.Close() // Can't defer until we know we have a response
	err = xml.DecodeClientResponse(response.Body, reply)
	return err
}

func Connect(address, port string) (connection XMLclient) {
	return XMLclient{address, port}
}

// XML-RPX call
func (c XMLclient) userExists(userName string) (bool, error) {

	var args interface{}

	args = &struct { // Magic Data Structure
		UserName string // All members are exported
	}{
		userName,
	}

	var reply struct{ ReturnValue bool }
	err := xmlRpcCall(c, "userExists", args, &reply)
	return reply.ReturnValue, err
}

// XML-RPX call
func (c XMLclient) getAllUsersByStatus(s bool) ([]userRecord, error) {

	var args interface{}

	args = &struct { // Magic Data Structure
		Status bool // All members are exported
	}{
		s,
	}

	var reply struct{ ReturnValue []userRecord }
	err := xmlRpcCall(c, "getAllUsersByStatus", args, &reply)
	return reply.ReturnValue, err
}

func main() {

	client := XMLclient{host, port}

	if userExists, err := client.userExists(testUser); err != nil {
		fmt.Printf("call to userExists() failed %v\n", err)
	} else {
		fmt.Printf("Result from call  to userExists() %v\n", userExists)
	}

	if userList, err := client.getAllUsersByStatus(true); err != nil {
		fmt.Printf("call to getAllUsersByStatus() failed %v\n", err)
	} else {
		fmt.Printf("Result from call to getAllUsersByStatus() %v\n", userList)
	}

}
