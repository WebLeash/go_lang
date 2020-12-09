package main

import (
	"context"
	"fmt"

	"github.com/beamly/go-gocd/gocd"
)

func main() {
	cfg := gocd.Configuration{
		Server:   "https://nathanstott.uk/go/",
		Username: "nathans",
		Password: "passwd1",
	}

	c := cfg.Client()

	// list all agents in use by the GoCD Server
	var a []*gocd.Agent
	var err error
	var r *gocd.APIResponse
	if a, r, err = c.Agents.List(context.Background()); err != nil {
		if r.HTTP.StatusCode == 404 {
			fmt.Println("Couldn't find agent")
		} else {
			panic(err)
		}
	}

	fmt.Println(a)
}
