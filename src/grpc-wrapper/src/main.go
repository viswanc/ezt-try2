package main

import (
	"github.com/gin-gonic/gin"
	"fmt"
	"io/ioutil"
	"net/http"
	"log"
	"os"
	"time"

	"golang.org/x/net/context"
	"google.golang.org/grpc"
	pb "google.golang.org/grpc/examples/helloworld/helloworld"
)

// Data
var Routes = map[string]string{
	"a": "ra",
	"b": "rb",
}

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
	r.GET("/dynamic/:route", func(c *gin.Context) {
		route := c.Params.ByName("route")
		value, ok := Routes[route]

		if ok {

			c.JSON(200, gin.H{"route": route, "value": value})

		} else {

			c.JSON(200, gin.H{"route": route, "status": "no value"})
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

	r.POST("/grpc/greet", func(c *gin.Context) { // #Note: POST is used to closely resemble a gRPC request.

		address := "localhost:9000"
		conn, err := grpc.Dial(address, grpc.WithInsecure())
		if err != nil {
		log.Fatalf("did not connect: %v", err)
		}
		defer conn.Close()
		c1 := pb.NewGreeterClient(conn)

		ctx, cancel := context.WithTimeout(context.Background(), time.Second)
		defer cancel()

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
	port := "8080"
	if len(os.Args) > 1 {
		port = os.Args[1]
	}
	// r.Run("0.0.0.0:" + port) // Listen and Serve on 0.0.0.0:port
	r.Run("127.0.0.1:" + port)
}
