package main

import (
	"net/http"
	"github.com/pin/tftp"
)

func main() {
	http.HandleFunc("/ping", handlePing)
	http.ListenAndServe(":8080", nil)
}

func handlePing(w http.ResponseWriter, r *http.Request) {
	c, err := tftp.NewClient("localhost:69")
	if err != nil {
		w.WriteHeader(500)
		return
	}
	wt, err := c.Receive("ping", "octet")
	if err != nil {
		w.WriteHeader(500)
		return
	}
	w.WriteHeader(200)
	wt.WriteTo(w)
}
