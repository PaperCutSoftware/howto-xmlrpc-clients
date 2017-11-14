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

	buf, _ := xml.EncodeClientRequest("userExists", args)
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
				fmt.Printf("Error on functions userExists(\"%v\") returns %v\n", testUser, err)
			} else {
				fmt.Printf("Return on functions userExists(\"%v\") data is %v\n", testUser, reply.Present)
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

	buf, _ = xml.EncodeClientRequest("userExists", args)
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
				fmt.Printf("Error on functions userExists(\"%v\") returns %v\n", testUser, err)
			} else {

				fmt.Printf("Return on functions userExists(\"%v\") data is %v\n", testUser, reply.Present)
			}
		}
	}

	for _, u := range []string{testUser, "noOne"} {

		args = &struct { // Magic Data Structure
			Name string // All members are exported
		}{
			u,
		}

		buf, _ = xml.EncodeClientRequest("userExists", args)
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
					fmt.Printf("Error on functions userExists(\"%v\") returns %v\n", testUser, err)
				} else {
					fmt.Printf("Return on functions userExists(\"%v\") data is %v\n", testUser, reply.Present)
				}
			}
		}
	}
}
