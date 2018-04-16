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
	"net/url"
	"strconv"

	. "../../grpc-service/lib/helloworldClient"
)

// Data
var HeadersToPropogate = []string{"X-Request-Id", "X-B3-TraceId", "X-B3-SpanId", "X-B3-ParentSpanId", "X-B3-Sampled", "X-B3-Flags"}

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

func getHeaderMap(c *gin.Context, Headers []string) map[string]string { // Returns the specified headers from the given Gin-context, as a map.

	Ret := map[string]string{}

	for _, key := range Headers {

		val := c.GetHeader(key)

		if (val != "") {

			Ret[key] = c.GetHeader(key)
		}
	}

	return Ret
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
			c.String(503, "Failed to escape :(")

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

	r.GET("/grpc/greet/:count", func(c *gin.Context) { // #Later: Phase the route out.

		address := "localhost:9000"
		if len(os.Args) > 2 {
			address = os.Args[2]
		}

		count, _ := strconv.Atoi(c.Params.ByName("count"))

		log.Printf("Calling: %s", address)
		log.Printf("Greeting: %d times.", count)

		options := ReqOptions {

			Address: address,
			Name: "world",
			RequestCount: count,
			Headers: getHeaderMap(c, HeadersToPropogate),
		}

		c.String(200, fmt.Sprintf("%sThrough: %s\n", SingleRequest(options), os.Getenv("POD_NAME")))
	})

	r.GET("/sayHello/:rType/:count", func(c *gin.Context) {

		address := "localhost:9000"
		if len(os.Args) > 2 {
			address = os.Args[2]
		}

		rType := c.Params.ByName("rType")
		count, _ := strconv.Atoi(c.Params.ByName("count"))

		log.Printf("Posting to %s", address)

		options := ReqOptions {

			Address: address,
			Name: "world",
			RequestCount: count,
			Headers: getHeaderMap(c, HeadersToPropogate),
		}

		buffer := ""

		switch rType {
			case "u":
				buffer = Uniplex(options)

			case "m":
				buffer = Multiplex(options)

			case "s":
				buffer = SingleRequest(options)

			case "k":
				buffer = KeepAlive(options)

			default:
				fmt.Println("No such option: ", os.Args[2])
		}


		c.String(200, fmt.Sprintf("%sThrough: %s\n", buffer, os.Getenv("POD_NAME")))
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
