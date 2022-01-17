package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"

	"github.com/coreos/ignition/v2/config"
	currentIgnVersion "github.com/coreos/ignition/v2/config/v3_4_experimental"
	currentIgnVersionTypes "github.com/coreos/ignition/v2/config/v3_4_experimental/types"
)

type flagStringArray []string

func (f *flagStringArray) String() string {
	return ""
}

func (f *flagStringArray) Set(s string) error {
	*f = append(*f, s)
	return nil
}

type Opts struct {
	IgnitionFiles flagStringArray
	OutputFile    string
}

func main() {
	var o Opts
	flag.Var(&o.IgnitionFiles, "i", "Ignition files to merge, first is base, others are merged 'on top' ")
	flag.StringVar(&o.OutputFile, "o", "", "Where to write the output. If ommitted, outputs to stdout")
	flag.Parse()

	var lastIgnition *currentIgnVersionTypes.Config

	for _, ignFile := range o.IgnitionFiles {
		// read in the raw ignition from each file
		ignRaw, err := ioutil.ReadFile(ignFile)
		parsedIgnition, _, err := config.Parse(ignRaw)
		if err != nil {
			log.Fatalf("Failed to parse ignition: %s", err)
		}

		// If this is the first time, nothing to merge
		if lastIgnition == nil {
			lastIgnition = &parsedIgnition
		} else {
			// Merge the rest one at a time
			*lastIgnition = currentIgnVersion.Merge(*lastIgnition, parsedIgnition)
		}

	}

	// Pretty print the result
	j, _ := json.MarshalIndent(lastIgnition, "", "  ")
	if o.OutputFile != "" {
		err := ioutil.WriteFile(o.OutputFile, j, 0644)
		if err != nil {
			log.Fatalf("Failed to write output: %s", err)
		}
	} else {
		fmt.Printf("%s\n", j)
	}

}
