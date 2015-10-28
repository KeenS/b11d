(ns b11d.importer
  (:require [compojure.core :refer :all]
            [cheshire.core :refer :all]

            [b11d.config :refer :all]
            [b11d.db :refer :all])
  (:gen-class))


(defn import-sponsors []
  (let [json (->> "advertisers.json"
                  clojure.java.io/resource
                  clojure.java.io/reader
                  parse-stream)]
    (doseq [s json]
      (save-sponsor (db-connection) s))))

(defn import-requests []
  (let [json (->> "generatedTrainBidRequests.json"
                  clojure.java.io/resource
                  clojure.java.io/reader
                  parse-stream)]
    (doseq [e json]
      (save-request (db-connection) (e "body")))))


(defn import-training-data []
  (let [json (->> "generatedTrainBidRequests.json"
                  clojure.java.io/resource
                  clojure.java.io/reader
                  parse-stream)]
    (doseq [e json]
      (save-trainning-data (db-connection) (e "body") (e "result")))))


(defn -main []
  (import-sponsors)
  (import-training-data))
