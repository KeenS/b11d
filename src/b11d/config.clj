(ns b11d.config
  (:import [com.mchange.v2.c3p0 ComboPooledDataSource]))

(def schema "http")
(def hostname "localhost")
(def currency "JPY")

(def mysql-db {:subprotocol "mysql"
               :subname "//127.0.0.1:3306/b11d"
               :user "b11d_app"
               :password "blackenedgold"})
(defn winnotice-url [sponsor-id]
  (str schema "://" hostname "/api/rtb/1.0.0/winnotice/" sponsor-id))


(defn pool
  [spec]
  (let [cpds (doto (ComboPooledDataSource.)
               (.setDriverClass (:classname spec)) 
               (.setJdbcUrl (str "jdbc:" (:subprotocol spec) ":" (:subname spec)))
               (.setUser (:user spec))
               (.setPassword (:password spec))
               ;; expire excess connections after 30 minutes of inactivity:
               (.setMaxIdleTimeExcessConnections (* 30 60))
               ;; expire connections after 3 hours of inactivity:
               (.setMaxIdleTime (* 3 60 60)))] 

    {:datasource cpds}))

(def pooled-connection (pool mysql-db))


(defn db-connection [] pooled-connection)

(def adomain ["1" "2"])
