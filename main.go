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
	var outstr string
	asList := false
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
		// check the last part for []
		lastPartIdx := len(parts) - 1
		lastPart := parts[lastPartIdx]
		lastPartLen := len(lastPart)
		if strings.HasSuffix(lastPart, "[]") {
			asList = true
			parts[lastPartIdx] = lastPart[:lastPartLen-2]
		}
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
			// now that we have an object in current, do we ask for it in [] mode?
			if asList {
				// first try a slice, then a map
				outslice := []string{}
				v, ok := current.([]interface{})
				if !ok {
					v, ok := current.(map[interface{}]interface{})
					if !ok {
						log.Fatal("Unknown format")
					}
					for _, value := range v {
						outslice = append(outslice, value.(string))
					}
				} else {
					outslice = []string{}
					for _, value := range v {
						outslice = append(outslice, value.(string))
					}
				}
				outstr = strings.Join(outslice, "\n")
			} else {
				out, err := yaml.Marshal(current)
				if err != nil {
					log.Fatalf("error creating output %v", err)
				}
				outstr = string(out)
			}
			fmt.Println(outstr)
		}
	}
}
