(ns b11d.db
  (:require [clojure.java.jdbc :as j]

            [b11d.config :refer :all]))


(defn save-ngdomains [db sponsor-id ns]
  (doseq [n ns]
    (j/insert! db :ngdomains
               ["sponsor_id" "ngdomain"]
               [sponsor-id n])))
(defn save-budgets [db s b]
  (j/insert! db :budgets
             ["sponsor_id" "budget"   "cpc"]
             [(s "id") b (s "cpc")]))

(defn save-sponsor [db s]
  (j/with-db-transaction [trx db]
    (j/insert! trx :sponsors
               ["id"]
               [(s "id")])
    (save-ngdomains trx (s "id") (s "ng"))
    (save-budgets trx s (s "budget"))))

(defn save-imp [db request-id i]
  (j/insert! db :imps
             ["id" "request_id" "bidfloor" "bidfloorcur"]
             [(i "id") request-id (i "bidfloor") (i "bidfloorcur")]))

(defn save-pages [db site-id p]
  (j/execute! db
             ["INSERT IGNORE INTO pages (site_id, page) VALUES (?, ?)" site-id p]))

(defn save-site [db s]
  (j/execute! db
              ["INSERT IGNORE INTO sites (id, site_name) VALUES (?, ?)"
               (s "id") (s "name")])
  (save-pages db (s "id") (s "page")))

(defn save-request-site [db request-id s]
  (j/insert! db :request_site
             ["request_id" "site_id"]
             [request-id (s "id")]))

(defn save-device [db d]
  (j/execute! db
              ["INSERT IGNORE INTO devices (ua, devicetype) VALUES (?, ?)"
               (d "ua") (d "devicetype")]))

(defn save-request-device [db request-id d]
  (j/insert! db :request_device
             ["request_id" "ua" "devicetype"]
              [request-id (d "ua") (d "devicetype")]))

(defn save-user [db u]
  (j/execute! db
            ["INSERT IGNORE INTO users (id) VALUES (?)" (u "id")]))

(defn save-request-user [db request-id u]
  (j/insert! db :request_user
            ["request_id" "user_id"]
            [request-id (u "id")]))

(defn save-request [db r]
  (j/with-db-transaction [trx db]
    (j/insert! trx :requests
               ["id" "test" "action_type" "tmax"]
               [(r "id") (r "test") (r "at") (r "tmax")])
    (let [id (r "id")]
      
      (doseq [i (r "imp")]
        (save-imp trx id i))
      (save-site trx (r "site"))
      (save-request-site trx id (r "site"))
      (save-device trx (r "device"))
      (save-request-device trx id (r "device"))
      (save-user trx (r "user"))
      (save-request-user trx id (r "user")))))


(defn save-winnotice [db sponsor-id w]
  (j/insert! db :winnotices
             ["imp_id" "sponsor_id" "price" "is_click"]
             [(w "impid") sponsor-id (w "price") (w "is_click")]))


(defn get-sponsors [db]
  (->>
   (j/query db ["
SELECT id, ngdomain as ngdomains, budget, cpc, IFNULL(w.clicks, 0) AS clicks
FROM sponsors
INNER JOIN budgets
        ON sponsors.id = budgets.sponsor_id
LEFT JOIN ngdomains
       ON sponsors.id = ngdomains.sponsor_id
LEFT JOIN (SELECT sponsor_id, COUNT(*) as clicks FROM winnotices WHERE is_click = true GROUP BY sponsor_id) AS w 
        ON w.sponsor_id = sponsors.id
"])
   (partition-by :id)
   (map (fn [e] (reduce (fn [acc e] (update-in e [:ngdomains] cons (acc :ngdomains))) {:ngdomains ()} e)))))

(defn save-trainning-data [db {{ua "ua"} "device" {site-id "id"} "site" :as request} response]
  (j/insert! db :trainning_data
             ["sponsor_id" "site_id" "ua" "is_click"]
             [0 site-id ua (response 0)]
             [1 site-id ua (response 1)]
             [2 site-id ua (response 2)]
             [3 site-id ua (response 3)]
             [4 site-id ua (response 4)]))

(defn load-trainning-data [db]
  (let [to-map (fn [records] (reduce (fn [acc e] (merge acc {(e :k) (e :c)})) {} records))
        base    (to-map (j/query db ["SELECT CONCAT(sponsor_id, site_id, ua) AS k, COUNT(*) AS c FROM trainning_data GROUP BY sponsor_id, site_id, ua"]))
        clicked (to-map (j/query db ["SELECT CONCAT(sponsor_id, site_id, ua) AS k, COUNT(*) AS c FROM trainning_data WHERE is_click = true GROUP BY sponsor_id, site_id, ua"]))]
    (merge-with / clicked base)))

(defn save-seatbid [db response-id s]
  (j/insert! db :seats
             ["response_id" "seat"]
             [response-id (s :seat)]))


(defn save-bid [db response-id seat-id b]
  (let [sponsor-id-of (fn [nurl] (subs nurl (+ 1 (java.lang.String/.lastIndexOf nurl "/"))))]
   (j/insert! db :bids
              ["imp_id" "price" "adomain" "sponsor_id"]
              [(b :id) (b :price) (str (b :adomain)) (Integer. (sponsor-id-of (b :nurl)))])))

(defn save-response [db r]
  (j/with-db-transaction [trx db]
    (j/insert! trx :responses
               ["id" "bidid" "cur"]
               [(r :id) (r :bidid) (r :cur)])
    (let [id (r :id)]
      (doseq [s (r :seatbid)]
        (save-seatbid trx id s)
        (doseq [b (s :bid)]
          (save-bid trx id (s :seat) b))))))
