package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
)

type Message struct {
	Id   int64  `json:"id"`
	Name string `json:"name"`
}

// curl localhost:8000 -d '{"name":"Hello"}'

func hello(w http.ResponseWriter, req *http.Request) {

	// Read body
	b, err := ioutil.ReadAll(req.Body)
	defer req.Body.Close()
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	fmt.Println(string(b))
	var msg Message
	err = json.Unmarshal(b, &msg)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}

	output, err := json.Marshal(msg)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	w.Header().Set("content-type", "application/json")
	w.Write(output)

	fmt.Fprintf(w, "HARBOR\n")

	fo, err := os.Create("Harbor.txt")
	if err != nil {
		panic(err)
	}
	str := "Harbor"
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

	http.HandleFunc("/hello", hello)
	http.HandleFunc("/headers", headers)
	http.HandleFunc("/gocd", gocd)

	http.ListenAndServe(":8090", nil)
}
