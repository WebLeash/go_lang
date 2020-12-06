package main

import (
	"fmt"
	"time"

	"github.com/bndr/gojenkins"
)

func main() {
	jenkins := gojenkins.CreateJenkins(nil, "https://<user_name>:<api_token>@domain.name")
	_, err := jenkins.Init()
	if err != nil {
		panic(err)
	}

	buildID, err := jenkins.BuildJob("job_name", map[string]string{"git_branch": "20191010", "hostlist": "127.0.0.1", "status": "deploy"})
	if err != nil {
		panic(err)
	}
	fmt.Println("buildID:", buildID)

	job, err := jenkins.GetJob("job_name")
	if err != nil {
		panic(err)
	}
	fmt.Println("job:", job)

	build, err := job.GetLastBuild()
	if err != nil {
		panic(err)
	}
	fmt.Println("build:", build)

	var result string
	for i := 0; i < 60; i++ {
		result = build.GetResult()
		if result != "" {
			break
		}
		time.Sleep(time.Second)
	}
	fmt.Println("result:", result)

	if result == "FAILURE" {
		output := build.GetConsoleOutput()
		fmt.Println("output:", output)
	}
}
