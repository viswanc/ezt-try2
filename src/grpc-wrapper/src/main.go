package main

// Params:
// 	- Address to listen.
// 	-	address to route gRPC requests.

import (
	"github.com/gin-gonic/gin"
	"fmt"
	"io/ioutil"
	"net/http"
	"log"
	"os"
	"time"
	"net/url"

	"golang.org/x/net/context"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc"
	pb "google.golang.org/grpc/examples/helloworld/helloworld"
)

// Data
// None.

// Helpers
func request(url string) string {

	response, err := http.Get(url)

	if err != nil {

		fmt.Printf("%s", err)

	} else {

		defer response.Body.Close()
		contents, err := ioutil.ReadAll(response.Body)

		if err != nil {
			fmt.Printf("%s", err)
		}

		return string(contents)
	}

	return ""
}

// Routes
func setupRouter() *gin.Engine {

	r := gin.Default()

	// Ping test
	r.GET("/ping", func(c *gin.Context) {
		c.String(200, "pong")
	})

	// Dynamic routing.
	r.GET("/dynamic/:urls", func(c *gin.Context) {
		urlToCall, err := url.QueryUnescape(c.Params.ByName("urls"))

		if err != nil {

			log.Fatalf("Failed to escape: %v", err)
			c.String(503, "Failed to escape :()")

		} else {

			log.Printf("Calling %s", urlToCall)
			c.String(200, request(urlToCall))
		}
	})

	r.GET("/recurse/:route", func(c *gin.Context) {
		route := c.Params.ByName("route")

		i := len(route)
		prefix := route[0:1]
		var res string

		if i > 1 {

			res = request("http://grpc-wrapper:8080/recurse/" + route[1:])

		} else {

			res = "|"
		}

		c.String(200, prefix + "-" + res)
	})

	r.GET("/grpc/greet", func(c *gin.Context) {

		address := "localhost:9000"
		if len(os.Args) > 2 {
			address = os.Args[2]
		}

		conn, err := grpc.Dial(address, grpc.WithInsecure())
		if err != nil {
		log.Fatalf("did not connect: %v", err)
		}
		defer conn.Close()
		c1 := pb.NewGreeterClient(conn)

		ctx, cancel := context.WithTimeout(context.Background(), time.Second)
		defer cancel()

		// #ToDo: Find a better way to propagate headers.

		HeadersTpPropogate := [6]string{"X-Request-Id", "X-B3-TraceId", "X-B3-SpanId", "X-B3-ParentSpanId", "X-B3-Sampled", "X-B3-Flags"}

		for _, key := range HeadersTpPropogate {

			val := c.GetHeader(key)

			if val != "" {

				ctx = metadata.AppendToOutgoingContext(ctx, key, val)
			}
		}

		log.Printf("Calling: %s", address)
		r, err := c1.SayHello(ctx, &pb.HelloRequest{Name: "World"})
		if err != nil {
			log.Fatalf("could not greet: %v", err)
		}
		log.Printf("Greeting: %s", r.Message)

		c.String(200, r.Message)
	})

	return r
}

func main() {
	r := setupRouter()
	address := "127.0.0.1:8080"
	if len(os.Args) > 1 {
		address = os.Args[1]
	}

	r.Run(address)
}
