-- mysql
DROP SCHEMA IF EXISTS b11d;
CREATE SCHEMA b11d DEFAULT CHARACTER SET utf8;
GRANT ALL ON b11d.* TO b11d_app IDENTIFIED BY "blackenedgold";
GRANT ALL ON b11d.* TO b11d_app@'localhost' IDENTIFIED BY "blackenedgold";
GRANT ALL ON b11d.* TO b11d_app@'127.0.0.1' IDENTIFIED BY "blackenedgold";
USE b11d;

CREATE TABLE sponsors (
  id INTEGER NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE ngdomains (
  sponsor_id INTEGER NOT NULL,
  ngdomain VARCHAR(255) NOT NULL,
  PRIMARY KEY(sponsor_id, ngdomain),
  FOREIGN KEY(sponsor_id) REFERENCES sponsors(id) ON UPDATE CASCADE
);

CREATE TABLE budgets (
  sponsor_id INTEGER NOT NULL,
  budget FLOAT NOT NULL,
  cpc FLOAT NOT NULL,
  PRIMARY KEY(sponsor_id),
  FOREIGN KEY(sponsor_id) REFERENCES sponsors(id) ON UPDATE CASCADE
);

CREATE TABLE requests (
  id VARCHAR(255) NOT NULL,
  test BOOLEAN NOT NULL,
  action_type ENUM('FIRST_PRICE', 'SECOND_PRICE') NOT NULL,
  tmax INTEGER NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE imps (
  id VARCHAR(255) NOT NULL,
  request_id VARCHAR(255) NOT NULL,
  bidfloor FLOAT NOT NULL,
  bidfloorcur VARCHAR(3) NOT NULL,
  PRIMARY KEY(id),
  FOREIGN KEY(request_id) REFERENCES requests(id) ON UPDATE CASCADE
);

CREATE TABLE sites (
  id VARCHAR(255) NOT NULL,
  site_name VARCHAR(65535) NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE pages (
  site_id VARCHAR(255) NOT NULL,
  page VARCHAR(65535) NOT NULL,
  PRIMARY KEY(site_id),
  FOREIGN KEY(site_id) REFERENCES sites(id) ON UPDATE CASCADE
);

CREATE TABLE request_site (
  request_id VARCHAR(255) NOT NULL,
  site_id VARCHAR(255) NOT NULL,
  PRIMARY KEY(request_id),
  FOREIGN KEY(request_id) REFERENCES requests(id) ON UPDATE CASCADE,
  FOREIGN KEY(site_id) REFERENCES sites(id) ON UPDATE CASCADE
);


CREATE TABLE devices (
  ua VARCHAR(255) NOT NULL,
  devicetype INTEGER NOT NULL,
  PRIMARY KEY(ua, devicetype)
);

CREATE TABLE request_device (
  request_id VARCHAR(255) NOT NULL,
  ua VARCHAR(255) NOT NULL,
  devicetype INTEGER NOT NULL,
  PRIMARY KEY(request_id),
  FOREIGN KEY(request_id) REFERENCES requests(id) ON UPDATE CASCADE,
  FOREIGN KEY(ua, devicetype) REFERENCES devices(ua, devicetype) ON UPDATE CASCADE
);

CREATE TABLE users (
  id VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE request_user (
  request_id VARCHAR(255) NOT NULL,
  user_id VARCHAR(255) NOT NULL,
  PRIMARY KEY(request_id),
  FOREIGN KEY(request_id) REFERENCES requests(id) ON UPDATE CASCADE,
  FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE
);

CREATE TABLE responses (
 id VARCHAR(255) NOT NULL,
 bidid VARCHAR(255) NOT NULL,
 cur VARCHAR(3) NOT NULL,
 PRIMARY KEY(id),
 FOREIGN KEY(id) REFERENCES requests(id) ON UPDATE CASCADE
);

CREATE TABLE seats (
  response_id VARCHAR(255) NOT NULL,
  seat VARCHAR(255) NOT NULL,
  PRIMARY KEY(response_id),
  FOREIGN KEY(response_id) REFERENCES responses(id) ON UPDATE CASCADE
);

CREATE TABLE bids (
  imp_id VARCHAR(255) NOT NULL,
  price FLOAT NOT NULL,
  adomain VARCHAR(255) NOT NULL,
  sponsor_id INTEGER NOT NULL,
  PRIMARY KEY(imp_id),
  FOREIGN KEY(imp_id) REFERENCES imps(id) ON UPDATE CASCADE,
  FOREIGN KEY(sponsor_id) REFERENCES sponsors(id) ON UPDATE CASCADE
);
 
CREATE TABLE winnotices (
  imp_id VARCHAR(255) NOT NULL,
  sponsor_id INTEGER NOT NULL,
  price FLOAT NOT NULL,
  is_click BOOLEAN NOT NULL,
  PRIMARY KEY(imp_id),
  KEY(is_click),
  FOREIGN KEY(imp_id) REFERENCES imps(id) ON UPDATE CASCADE,
  FOREIGN KEY(sponsor_id) REFERENCES sponsors(id) ON UPDATE CASCADE
);

CREATE TABLE trainning_data (
  id INTEGER NOT NULL AUTO_INCREMENT,
  sponsor_id INTEGER NOT NULL,
  site_id VARCHAR(255) NOT NULL,
  ua VARCHAR(255) NOT NULL,
  is_click BOOLEAN NOT NULL,
  PRIMARY KEY(id),
  KEY(sponsor_id,site_id, ua)
);

