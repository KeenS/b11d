(defproject b11d "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :min-lein-version "2.0.0"
  :resource-paths ["resources"]
  :dependencies [[org.clojure/clojure "1.6.0"]
                 [compojure "1.3.1"]
                 [ring/ring-defaults "0.1.2"]
                 [ring/ring-json "0.4.0"]
                 [cider/cider-nrepl "0.9.1"]
                 [org.clojure/java.jdbc "0.4.2"]
                 [org.clojure/core.async "0.1.346.0-17112a-alpha"]
                 [org.clojure/math.numeric-tower "0.0.4"]
                 [mysql/mysql-connector-java "5.1.9"]
                 [com.mchange/c3p0 "0.9.5.1"]]
  :plugins [[lein-ring "0.8.13"]]
  :ring {:handler b11d.handler/app}
  :profiles
  {:dev {:dependencies [[javax.servlet/servlet-api "2.5"]
                        [ring-mock "0.1.5"]]}})
