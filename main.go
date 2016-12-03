package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strings"

	"gopkg.in/yaml.v2"
)

func main() {
	var current interface{}
	bytes, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		log.Fatalf("could not read from stdin: %v", err)
	}
	data := make(map[interface{}]interface{})
	e := yaml.Unmarshal(bytes, &data)
	if e != nil {
		log.Fatalf("could not process yaml: %v", e)
	}

	// now what do we print out?
	args := os.Args[1:]
	if len(args) == 0 || args[0] == "." {
		fmt.Print(string(bytes))
	} else {
		// find the path
		parts := strings.Split(args[0], ".")
		failed := false
		current = data
		// start only with after the first .
		for _, part := range parts[1:] {
			// did we find our part?
			v, ok := current.(map[interface{}]interface{})
			if !ok {
				failed = true
				break
			}
			elm, exists := v[part]
			if !exists {
				failed = true
				break
			} else {
				current = elm
			}
		}
		if !failed {
			out, err := yaml.Marshal(current)
			if err != nil {
				log.Fatalf("error creating output %v", err)
			}
			fmt.Println(string(out))
		}
	}
}
