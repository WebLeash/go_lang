package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
)

func main() {
	var files []string

	root := "/Users/nathanstott/go_lang/devops"
	err := filepath.Walk(root, func(path string, info os.FileInfo, err error) error {

		if info.IsDir() && info.Name() == ".git" {
			return filepath.SkipDir
		}
		files = append(files, path)
		return nil
	})
	if err != nil {
		panic(err)
	}
	for _, file := range files {
		data, err := ioutil.ReadFile(file)
		if err != nil {
			fmt.Println(err)
		}

		fmt.Print(string(data))
		fmt.Println(file)
	}
}
