// A cli wrapper arround the client for the helloworld proto.

package main

import (
	"fmt"
	"log"
	"os"

	. "../lib/helloworldClient"
)

const (
	defaultAddress = "localhost:8080"
	defaultName = "world"
)

// Helpers
func getAddress() string {

	address := defaultAddress
	if len(os.Args) > 1 && address != "" {
		address = os.Args[1]
	}

	log.Printf("Address: %s", address)

	return address
}

func getName() string {

	name := defaultName
	if len(os.Args) > 3 {
		name = os.Args[3]
	}

	return name
}

// Main
func main() {

	argCount := len(os.Args)

	if argCount == 1 {

		fmt.Println("Ex: $ go run <script> [ip:port] [m|u|s|k] [options]")

	} else {

		options := ReqOptions {

			Address: getAddress(),
			Name: getName(),
			RequestCount: 100,
			Headers: nil,
		}

		if argCount > 2 {

			switch os.Args[2] {
			case "u":
				Uniplex(options)

			case "m":
				Multiplex(options)

			case "s":
				SingleRequest(options)

			case "k":
				options.RequestCount = 5
				KeepAlive(options)

			default:
				fmt.Println("No such option: ", os.Args[2])
			}

		} else {

			SingleRequest(options)
		}
	}
}
