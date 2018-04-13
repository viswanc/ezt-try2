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
	pb "google.golang.org/grpc/examples/helloworld/helloworld"
)

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

func makeRequest(conn *grpc.ClientConn, name string) {

	c := pb.NewGreeterClient(conn)

	ctx, cancel := context.WithTimeout(context.Background(), time.Second) // Contact the server and print out its response.
	defer cancel()

	r, err := c.SayHello(ctx, &pb.HelloRequest{Name: name})
	if err != nil {
		log.Fatalf("Could not greet: %v", err)
	}

	fmt.Printf("Greeting: %s\n", r.Message)
}

// Structures
type ReqParams struct {

  Address string
  Name string
}

// Tasks
func SingleRequest(rp ReqParams) {

	conn := getConnection(rp.Address)

	makeRequest(conn, rp.Name)

	conn.Close()
}

func Uniplex(rp ReqParams) {

	for index := 0; index < 100; index++ {

		SingleRequest(rp)
	}
}

func Multiplex(rp ReqParams) {

	conn := getConnection(rp.Address)
	defer conn.Close()

	for index := 0; index < 100; index++ {

		c := pb.NewGreeterClient(conn)

		// Contact the server and print out its response.
		ctx, cancel := context.WithTimeout(context.Background(), time.Second)
		defer cancel()

		r, err := c.SayHello(ctx, &pb.HelloRequest{Name: rp.Name})
		if err != nil {
			log.Fatalf("Could not greet: %v", err)
		}

		fmt.Printf("Greeting: %s", r.Message)
	}
}

func KeepAlive(rp ReqParams) {

	conn := getConnection(rp.Address)

	repeat(func() { makeRequest(conn, rp.Name) }, 5, 1)

  conn.Close()
}
