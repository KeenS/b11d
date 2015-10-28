(ns b11d.handler
  (:require [compojure.core :refer :all]
            [compojure.handler :as handler]
            [compojure.route :as route]
            [ring.util.response :refer [response]]
            [ring.middleware.json :as middleware]

            [b11d.rtb :refer [do-rtb]]
            [b11d.winnotice :refer [do-winnotice]]))

(defroutes app-routes
  (GET "/" [] "Hello")
  (POST "/api/rtb/1.0.0/bid" {body :body} (do-rtb body))
  (POST "/api/rtb/1.0.0/winnotice/:sponsor-id" {body :body params :route-params} (do-winnotice body params))
  (route/not-found "Not Found"))

(def app
  (-> (handler/api app-routes)
      (middleware/wrap-json-body)
      (middleware/wrap-json-response)))
