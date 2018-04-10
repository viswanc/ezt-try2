/*
 *
 * Copyright 2015 gRPC authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

package main

import (
	"log"
	"os"
	"time"
	"fmt"

	"golang.org/x/net/context"
	"google.golang.org/grpc"
	pb "google.golang.org/grpc/examples/helloworld/helloworld"
)

const (
	defaultAddress    = "localhost:8080"
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

func getConnection() *grpc.ClientConn {

	conn, err := grpc.Dial(getAddress(), grpc.WithInsecure())
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}

	return conn
}

func makeRequest() {

	// Set up a connection to the server.
	conn := getConnection()
	c := pb.NewGreeterClient(conn)

	// Contact the server and print out its response.
	name := defaultName
	if len(os.Args) > 2 {
		name = os.Args[2]
	}
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()

	r, err := c.SayHello(ctx, &pb.HelloRequest{Name: name})
	if err != nil {
		log.Fatalf("Could not greet: %v", err)
	}

	fmt.Printf("Greeting: %s", r.Message)

	conn.Close()
}

// Tasks
func uniplex() {

	for index := 0; index < 100; index++ {

		makeRequest()
	}
}

func multiplex() {

	conn := getConnection()
	defer conn.Close()

	name := defaultName
	if len(os.Args) > 2 {
		name = os.Args[2]
	}

	for index := 0; index < 100; index++ {

		c := pb.NewGreeterClient(conn)

		// Contact the server and print out its response.
		ctx, cancel := context.WithTimeout(context.Background(), time.Second)
		defer cancel()

		r, err := c.SayHello(ctx, &pb.HelloRequest{Name: name})
		if err != nil {
			log.Fatalf("Could not greet: %v", err)
		}

		fmt.Printf("Greeting: %s", r.Message)
	}
}

func main() {

	if len(os.Args) == 1 {

		fmt.Println("Ex: $ go run <script> [ip:port] [m|u]")

	} else if len(os.Args) > 2 {

		f := os.Args[2]

		if f == "u" {

			uniplex()

		} else {

			multiplex()
		}

	} else {

		makeRequest()
	}

}
