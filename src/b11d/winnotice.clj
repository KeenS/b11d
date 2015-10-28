(ns b11d.winnotice
  (:require [clojure.core.async :refer [go]]
            [b11d.config :refer :all]
            [b11d.db :refer :all]))

(defn do-winnotice [{impid "impid" price "price" is_click "is_click" :as winnotice} {sponsor-id :sponsor-id}]
  (go (save-winnotice (db-connection) sponsor-id winnotice))
  {:status 204})
