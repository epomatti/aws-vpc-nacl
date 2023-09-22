package main

import (
	"database/sql"
	"fmt"
	"log"
	"main/utils"
	"net/http"

	"github.com/go-sql-driver/mysql"
)

func main() {
	port := utils.GetPort()

	http.HandleFunc("/", ok)
	http.HandleFunc("/health", ok)
	http.HandleFunc("/mysql", mysqlConnect)

	addr := fmt.Sprintf(":%d", port)
	log.Printf("String server on port %v", port)
	http.ListenAndServe(addr, nil)
}

func ok(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "OK\n")
}

// MySQL

func mysqlConnect(w http.ResponseWriter, r *http.Request) {
	params := utils.GetParameters()

	addr := fmt.Sprintf("%s:3306", params.AuroraEndpoint)
	log.Printf("Connecting to MySql at %s", addr)

	var db *sql.DB

	var dsn = mysql.Config{
		User:   params.AuroraUsername,
		Passwd: params.AuroraPassword,
		Net:    "tcp",
		Addr:   addr,
		// DBName: "sakila",
	}

	var err error
	db, err = sql.Open("mysql", dsn.FormatDSN())
	if err != nil {
		log.Fatal(err)
	}

	pingErr := db.Ping()
	if pingErr != nil {
		log.Fatal(pingErr)
	}

	log.Println("Connected!")
	fmt.Fprint(w, "Connected!\n")
}
