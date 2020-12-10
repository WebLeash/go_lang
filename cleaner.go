package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

// Struct only need the key values.
// Pointer to a function jump table

type Message struct {
	Id    int64  `json:"id"`
	Name  string `json:"name"`
	State string `json: "state"`
}

type ProcessEvent func(string)

// curl localhost:8000/myhook -d '{"name":"Hello"}'

func jsonPrettyPrint(in string) string {
	var out bytes.Buffer
	err := json.Indent(&out, []byte(in), "", "\t")
	if err != nil {
		return in
	}
	return out.String()
}

func Cleaner(w http.ResponseWriter, resp *http.Request) {
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	log.Printf("invoke() --> Response\n%s\n", jsonPrettyPrint(string(body)))
	//log.Printf("invoke() --> Status '%s'\n", resp.Status)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}

	// Unmarshal
	var msg Message

	if msg.State == "Done" {
		fmt.Println("State Done!")
	}
	if msg.State == "Pending" {
		fmt.Println("State Pending!")
	}
	if msg.State == "processing" {
		fmt.Println("State processing!")
	}
	if msg.State == "finished" {
		fmt.Println("State finished!")
	}

	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}

	w.Header().Set("content-type", "application/json")
	w.Write(body)
}

func main() {
	http.HandleFunc("/myhook", Cleaner)
	address := ":8000"
	log.Println("Starting server on address", address)
	err := http.ListenAndServe(address, nil)
	if err != nil {
		panic(err)
	}
}
