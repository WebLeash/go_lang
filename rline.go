package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strings"
)

func main() {
	file, err := os.Open("/Users/nathanstott/go_lang/devops/settings-perf.templ")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	//var Myregex = `s/!!app!!/rspca/g`

	//var re = regexp.MustCompile(Myregex)
	// s := re.ReplaceAllString(originalString, "replaced")
	// fmt.Println(s)

	pii := os.Getenv(pii)
	tag := os.Getenv(tag)
	component := os.Getenv(component)
	group := os.Getenv(group)
	branch := os.Getenv(branch)
	project := os.Getenv(project)

	scanner := bufio.NewScanner(file)

	for scanner.Scan() {

		t := scanner.Text()

		//value := "cat"
		fmt.Println(t)

		// Replace the "cat" with a "calf."
		result := strings.Replace(t, "!!app!!", "rspca", -1)

		result := strings.Replace(t, "!!pii!!", pii, -1)
		result := strings.Replace(t, "!!tag!!", tag, -1)
		result := strings.Replace(t, "!!component!!", component, -1)
		result := strings.Replace(t, "!!appGroup", group, -1)
		result := strings.Replace(t, "!!branch!!", branch, -1)
		result := strings.Replace(t, "!!project!!", project, -1)
		result := strings.Replace(t, "!!tag_version!!", tag, -1)

		fmt.Println(result)

		//t := scanner.Text()
		//s := re.ReplaceAllString(t, "replaced")
		//fmt.Println()
		//fmt.Println("line %s", s)
		//fmt.Println(re.ReplaceAllString("!!app!!", "rspca"))

		//fmt.Println(scanner.ReplaceAllString("a peach", "<fruit>"))

	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}
}
