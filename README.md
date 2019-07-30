# Strichliste

This is a already set up, ready to go docker container for the strichliste service (https://www.strichliste.org/) using a MariaDB database.
The container uses the strichliste-backend (https://github.com/strichliste/strichliste-backend) and strichliste-web-frontend (https://github.com/strichliste/strichliste-web-frontend) repositories.

The Dockerfile as well as the configuration files are taken/based on the docker branch of sti-ip (https://github.com/stp-ip/server).

## Quick setup

This repository was created to be cloned and run with only minimal configuration needed.

### Get the Repo
To get started you simply clone this repository,
```git clone https://github.com/strichliste/strichliste-docker.git```
and go into the strichliste directory.

### Configure env Variables
The docker.env file contains environment variables necessary to run the service. Inside these files you need to change/set the MYSQL_ROOT_PASSWORD and MYSQL_PASSWORD variables to a new value.
You also need to change {user_pwd} inside the DATABASE_URL variable to your corresponding password set in MYSQL_PASSWORD.
The same change is necessary in config/default.conf:33 where the same DATABASE_URL variable is also set (i have not found a way to use the environment variable for this so this extra step is needed).

### Setup initial database
After configuring the environment variables you can start the container by executing:
```docker-compose up -d```
After the containers are started you need to jump into the container by running the following command:
```docker-compose exec strichliste bash```
Inside the container you need to run the following command to create the inital database schema:
```./../bin/console doctrine:schema:create```
(you might need to wait a bit for the database to start up, the command will tell you if it succeeded or not)
After creating the schema you can ```exit``` the container and the setup is done.

If you migrate from an older version of this repository you might need to rebuild the container to be able to use the new features:
```docker-compose up --build -d```

As default the service is running on localhost:8080

## Traefik configuration
To use traefik (https://traefik.io/) the docker-compose file has comments for the necessary configuration which should make it easy to setup.

## Migrating data from <= 1.4.1 to a newer version
To migrate your data from the old sqlite database to the new MariaDB you need a few manual steps. This is probably not the best/most elegant solution but it worked for my production environment.

### Save the data from sqlite3
Before starting make sure to stop the container.
First we need to save the sqlite table contents into a file. For this the following tutorial is sufficent: http://www.sqlitetutorial.net/sqlite-tutorial/sqlite-export-csv/
Ideally you want 3 different files for the three database tables (user, article and transactions).

### Edit the CSV Files
Since the sqlite csv dump produces empty cells for non existant values we need to replace these empty cells with NULL. To achieve that i used the following command in vim (any other find and replace will do the same job):
```:%s/,,/,NULL,/gc```
In this moment make sure the amount of columns in the file matches the first line (which repesents the names of the columns).

### Mount the files into the container
To make the csv files accessible from inside the container we need to mount them as volumes.
To do that you would add the following line for each of the 3 files to the volumes section inside the docker-compose.yml under the service strichliste (line 22):
```- ./path/to/csv/file.csv:/source/var/file.csv```

### Start the container, connect to it and setup inital database schema
(see Setup inital database)

### Load csv data into tables
To load the csv data into the database tables you need to connect to the database with the following command (while still inside the strichliste container):
```mysql -u strichliste -p -h strichliste_db strichliste```
You will be prompted to supply your choosen MYSQL_PASSWORD.
After connecting to the database we can finally load the data inside the tables:
```LOAD DATA LOCAL INFILE '/source/var/file.csv' INTO TABLE user CHARSET 'utf8' FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n';```
That will load the contents of /source/var/file.csv into the table 'user'.

NOTE: Some lines might not be able to be loaded since some constraints can not be resolved, in my production environment that only happend in case of an user to user payment. Since the users amount is stored in the user table and not calculated, this did not pose a big problem and we proceeded without these transactions (~100 entries of ~1500).
