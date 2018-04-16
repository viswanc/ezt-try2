/*
 *
 * Copyright 2015 gRPC authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *		 http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

 package helloworldClient

import (
	"fmt"
	"log"
	"time"

	"golang.org/x/net/context"
	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"
	pb "google.golang.org/grpc/examples/helloworld/helloworld"
)


// Data
// None

// Structures
type ReqOptions struct {

	Address string
	Name string
	RequestCount int
	Headers map[string]string
}

// Helpers
func getConnection(address string) *grpc.ClientConn { // Sets up a connection to the server.

	conn, err := grpc.Dial(address, grpc.WithInsecure())
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}

	return conn
}

func schedule(what func(), delay time.Duration) chan bool {
	stop := make(chan bool)

	go func() {
	for {
		what()
		select {
		case <-time.After(delay):
		case <-stop:
			return
		}
	}
	}()

	return stop
}

func repeat(action func(), duration time.Duration, interval time.Duration) {

	stop := schedule(action, interval * time.Second)
	time.Sleep(duration * time.Second)
	stop <- true
}

func makeRequest(conn *grpc.ClientConn, options ReqOptions) string {

	buffer := ""
	c := pb.NewGreeterClient(conn)
	ctx, cancel := context.WithTimeout(context.Background(), time.Second) // Contact the server and print out its response.
	defer cancel()

	for key, val := range options.Headers {

		ctx = metadata.AppendToOutgoingContext(ctx, key, val)
	}

	for index := 0; index < options.RequestCount; index++ {

		resp, err := c.SayHello(ctx, &pb.HelloRequest{Name: options.Name})
		if err != nil {
			log.Fatalf("Could not greet: %v", err)
		}

		fmt.Printf("Greeting: %s\n", resp.Message)
		buffer = buffer + resp.Message + "\n"
	}

	return buffer
}

// Tasks
func Uniplex(options ReqOptions) string {

	count := options.RequestCount
	options.RequestCount = 1
	buffer := ""

	for index := 0; index < count; index++ {

		conn := getConnection(options.Address)
		buffer = buffer + makeRequest(conn, options)

		conn.Close()
	}

	return buffer
}

func Multiplex(options ReqOptions) string {

	conn := getConnection(options.Address)
	defer conn.Close()

	return makeRequest(conn, options)
}

func SingleRequest(options ReqOptions) string {

	options.RequestCount = 1

	return Uniplex(options)
}

func KeepAlive(options ReqOptions) string {

	conn := getConnection(options.Address)
	defer conn.Close()

	count := options.RequestCount - 1
  options.RequestCount = 1
	action := func() string { return makeRequest(conn, options) }
	buffer := action()

  repeat(func() { action() }, time.Duration(count), 1)

	return buffer
}
