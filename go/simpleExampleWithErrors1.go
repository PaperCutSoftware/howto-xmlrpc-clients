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

	urlEndPoint := "http://" + host + ":" + port + "/users"
	wrongUrlEndPoint := "http://" + host + ":" + port + "/notcorrect"

	var args interface{}

	args = &struct { // Magic Data Structure
		Name string // All members are exported
	}{
		testUser,
	}

	buf, _ := xml.EncodeClientRequest("userExist", args)
	response, err := http.Post(wrongUrlEndPoint, "text/xml", bytes.NewBuffer(buf))

	if err != nil {
		fmt.Printf("Post Error %v\n", err)
	} else {
		defer response.Body.Close() // Can't defer until we know we have a response

		if response.StatusCode != http.StatusOK {
			fmt.Printf("Error status %v\n", response.Status)
		} else {

			var reply struct{ Present bool } // Magic data strcuture
			err = xml.DecodeClientResponse(response.Body, &reply)
			if err != nil {
				fmt.Printf("Error %v\n", err)
			} else {
				fmt.Printf("Return data is %v\n", reply.Present)
			}
		}
	}

	// Pass incorrect arguments to remote procedure

	args = &struct { // Magic Data Structure
		Name     string // All members are exported
		WrongArg int
	}{
		testUser,
		21,
	}

	buf, _ = xml.EncodeClientRequest("userExist", args)
	response, err = http.Post(urlEndPoint, "text/xml", bytes.NewBuffer(buf))

	if err != nil {
		fmt.Printf("Post Error %v\n", err)
	} else {
		defer response.Body.Close() // Can't defer until we know we have a response

		if response.StatusCode != http.StatusOK {
			fmt.Printf("Error status %v\n", response.Status)
		} else {
			defer response.Body.Close() // Can't defer until we know we have a response

			var reply struct{ Present bool } // Magic data strcuture
			err = xml.DecodeClientResponse(response.Body, &reply)
			if err != nil {
				fmt.Printf("Error %v\n", err)
			} else {

				fmt.Printf("Return data is %v\n", reply.Present)
			}
		}
	}

	for _, u := range []string{testUser, "noOne"} {

		args = &struct { // Magic Data Structure
			Name string // All members are exported
		}{
			u,
		}

		buf, _ = xml.EncodeClientRequest("userExist", args)
		response, err = http.Post(urlEndPoint, "text/xml", bytes.NewBuffer(buf))

		if err != nil {
			fmt.Printf("Post Error %v\n", err)
		} else {
			defer response.Body.Close() // Can't defer until we know we have a response

			if response.StatusCode != http.StatusOK {
				fmt.Printf("Error status %v\n", response.Status)
			} else {

				var reply struct{ Present bool } // Magic data strcuture
				err = xml.DecodeClientResponse(response.Body, &reply)
				if err != nil {
					fmt.Printf("Error %v\n", err)
				} else {
					fmt.Printf("Return data is %v\n", reply.Present)
				}
			}
		}
	}
}
