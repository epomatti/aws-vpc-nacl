package main

import (
	"fmt"
	"log"
	"main/utils"
	"net/http"
)

func main() {
	port := utils.GetPort()

	http.HandleFunc("/", ok)
	http.HandleFunc("/health", ok)
	http.HandleFunc("/mysql", mysql)

	addr := fmt.Sprintf(":%d", port)
	log.Printf("String server on port %v", port)
	http.ListenAndServe(addr, nil)
}

func ok(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "OK\n")
}

func mysql(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "OK\n")
}
