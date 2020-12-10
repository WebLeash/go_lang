package main

func add(x int, y int) int {

	out := x + y
	return out
}

func changeValue(str *string) {
	*str = "changed!"
}
func changeValue2(str string) {
	str = ""
}
func main() {

	num1 := 5
	num2 := 6
	toChange := "hello"
	changeValue(&toChange)
	result := add(num1, num2)
}
