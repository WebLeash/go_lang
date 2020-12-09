package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"math/rand"
	"net/http"
	"net/url"
	"os"
	"time"
)

func output(text string, ErrLevel int) {

	if ErrLevel == 9 {
		fmt.Println("ERROR:- " + text)
	} else {
		fmt.Println("Info :-" + text)
	}
	return
}
func GetToken(username, password string) {
	client := &http.Client{}
	data := url.Values{}

	data.Set("client_id", "61ffa794-b674-4278-9bf1-2016d9d738f1")
	data.Add("response_type", "id_token")
	data.Add("grant_type", "password")
	data.Add("scope", "openid")
	data.Add("username", username)
	data.Add("password", password)

	req, err := http.NewRequest("POST", "https://login.microsoftonline.com/fdb0e18a-61f3-49e2-891f-ce2def987b59/oauth2/v2.0/token", bytes.NewBufferString(data.Encode()))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded; param=value")

	if err != nil {
		log.Println(err)
	}
	resp, err := client.Do(req)
	f, err := ioutil.ReadAll(resp.Body)
	resp.Body.Close()
	fmt.Println(string(f))
	// req.Header.Set("application", "x-www-form-urlencoded")
	fmt.Print(req)
}

func main() {

	requestID := rand.Intn(10000-1) + 1
	fmt.Println(requestID)
	host := os.Args[1]
	project := os.Args[2]
	repository := os.Args[3]
	version := os.Args[4]
	MaxCount := os.Args[5]
	Freq := os.Args[6]
	username := os.Args[7]
	password := os.Args[8]

	fmt.Println(host)
	fmt.Println(project)
	fmt.Println(repository)
	fmt.Println(version)
	fmt.Println(MaxCount)
	fmt.Println(Freq)
	fmt.Println(username)
	fmt.Println(password)

	currentTime := time.Now()
	fmt.Println(currentTime)
	start := "Starting Scan :"
	ct := currentTime.String()
	pass := start + ct
	output(pass, 1)
	GetToken(username, password)

}
