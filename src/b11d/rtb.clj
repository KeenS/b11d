(ns b11d.rtb
  (:require [clojure.math.numeric-tower :refer [expt]]
            [clojure.core.async :refer [go]]
            [ring.util.response :refer [response]]

            [b11d.config :refer :all]
            [b11d.db :refer :all])
  (:import  [java.net URL]))

(defn ngdomain-p [{ngdomains :ngdomains} page]
  (let [url    (URL. page)
        domain (.getHost url)]
    (some #(.endsWith domain %) ngdomains)))

(defn sigmoid [x]
  (/ 1 (+ 1 (expt 2 (* 7 (- 0.5 x))))))

(defn in-budget-p [{clicks :clicks budget :budget cpc :cpc :as sponsor}]
  (< (* clicks cpc) budget))

(def stat-ctrs (load-trainning-data (db-connection)))

(defn estimate-ctr [{sponsor-id :id}
                    {{siteid "id"} "site" {ua "ua"} "device"}]

  (sigmoid (or (stat-ctrs (str sponsor-id siteid ua))
               0.2)))

(defn calc-cpm [imp {cpc :cpc :as sponsor} request]
  (* cpc (estimate-ctr sponsor request) 1000))

(defn calc-bid [{{siteid "id" site-name "name" page "page" :as site} "site"
                 {user-agent "ua" device-type "devicetype" :as device} "device"
                 :as request}
                {impid "id" bidfloor "bidfloor" bidfloorcur "bidfloorcur" :as imp}
                sponsor]
  (assert bidfloorcur "JPY")
  (if (< (* (sponsor :clicks) (sponsor :cpc)) (sponsor :budget))
   (let [cpm (calc-cpm imp sponsor request)]
     (if (and (not (ngdomain-p sponsor page)) (> cpm bidfloor))
       {:id impid :impid impid :price cpm :adomain [(str (sponsor :id))] :nurl (winnotice-url (sponsor :id))}
       nil))
   nil))

(defn gen-do-imp [request sponsors]
  (fn [imp]
    (->> sponsors
         (map #(calc-bid request imp %))
         (filter identity)
         ((fn [l] (if (empty? l) () (apply max-key :price l)))))))

(defn get-response [{id "id" test "test" action-type "at" tmax "tmax"
                     imps "imp" site "site" device "device" :as request}]
  (assert action-type 2)
  (assert tmax 1000)
  (assert test 0)
  (let [sponsors (get-sponsors (db-connection))
        do-imp (gen-do-imp {"site" site "device" device} sponsors)
        bids (filterv identity (map do-imp imps))]
    {:id id :bidid "1" :cur currency :seatbid [{:bid bids :seat "1"}]}))

(defn do-rtb [body]
  (go (save-request (db-connection) body))
  (let [res (get-response body)]
    (go (save-response (db-connection) res))
    (response res)))
