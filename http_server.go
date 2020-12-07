package main

import (
	"fmt"
	"net/http"
	"os"
)

func hello(w http.ResponseWriter, req *http.Request) {

	fmt.Fprintf(w, "hello\n")

	fo, err := os.Create("hello.txt")
	if err != nil {
		panic(err)
	}
	str := "Hello"
	if _, err := fo.WriteString(str); err != nil {
		panic(err)
	}

}
func bye(w http.ResponseWriter, req *http.Request) {

	fmt.Fprintf(w, "bye\n")
}
func gocd(w http.ResponseWriter, req *http.Request) {

	fmt.Fprintf(w, "hello GOCD\n")
}

func headers(w http.ResponseWriter, req *http.Request) {

	for name, headers := range req.Header {
		for _, h := range headers {
			fmt.Fprintf(w, "%v: %v\n", name, h)
		}
	}
}

func main() {

	http.HandleFunc("/hello", bye)
	http.HandleFunc("/headers", headers)
	http.HandleFunc("/gocd", gocd)

	http.ListenAndServe(":8090", nil)
}
