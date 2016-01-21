# FH Münster - Big Data Engineering

## Code für Übung Nummer 5

Dieses Repository enthaelt das Material fuer Vorlesung und Uebung 5.

## Hush

Hush ist eine Beispiel Anwendung, welche HBase als Speicher benutzt. Dazu wird die ganze Handhabung der Schemaverwaltung, Erstellung der HBase Tabellen und so weiter automatisiert. Hush hat einen Schema Manager der diese Aufgabe übernimmt, des Weiteren wird die Kommunikation mit HBase durch eine (DAO = Data Access Objects) Abstraktionsebene vereinfacht und dadurch lose gekoppelt. Insgesamt ist Hush ein fast komplette Anwendung oberhalb von HBase als dauerhafter Speicher. Hush steht für HBase Url SHorthener und bietet einen wie aus dem Internet bekannten URL Kürzungsdienst an (vgl. Bit.ly). Nutzung des Dienst wird protokoliert und Statistiken in HBase Tabellen gespeichert, dazu wird das Time-to-Live (TTL) Merkmal von HBase genutzt. 

### Project Build

Zuerst muss das Repository gecloned und übersetzt werden:

```
$ git clone https://github.com/larsgeorge/fh-muenster-bde-lesson-5.git
$ cd fh-muenster-bde-lesson-5
$ mvn clean package
```

Hush benutzt intern die URL “hba.se”, welche in die `/etc/hosts` Datei in der VM eingetragen werden muss und auf `localhost` (also 127.0.0.1) zeigt:

```
[cloudera@quickstart fh-muenster-bde-lesson-5]$ sudo vim /etc/hosts
[cloudera@quickstart fh-muenster-bde-lesson-5]$ cat /etc/hosts
127.0.0.1 quickstart.cloudera localhost localhost.domain
127.0.0.1 hba.se
```

Dann kann die Hush Anwendung gestartet werden. Während des Starts werden die Tabellen angelegt und der eingebettete Jetty Server gestartet: 

```
[cloudera@quickstart fh-muenster-bde-lesson-5]$ bin/start-hush.sh
Found development environment...
Adding libraries from cached file: /home/cloudera/fh-muenster-bde-lesson-5/bin/../target/cached_classpath.txt
=====================
Starting Hush...
=====================
Using classpath: ...
INFO [main] (HushMain.java:51) - Initializing HBase
INFO [main] (HushMain.java:54) - Creating/updating HBase schema
INFO [main] (Configuration.java:1022) - hadoop.native.lib is deprecated. Instead, use io.native.lib.available
WARN [main] (NativeCodeLoader.java:62) - Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
INFO [main] (RecoverableZooKeeper.java:119) - Process identifier=hconnection-0x6e233c17 connecting to ZooKeeper ensemble=localhost:2181
INFO [main] (Environment.java:100) - Client environment:zookeeper.version=3.4.5-cdh5.2.0--1, built on 10/11/2014 20:49 GMT
INFO [main] (Environment.java:100) - Client environment:host.name=quickstart.cloudera
INFO [main] (Environment.java:100) - Client environment:java.version=1.7.0_67
INFO [main] (Environment.java:100) - Client environment:java.vendor=Oracle Corporation
INFO [main] (Environment.java:100) - Client environment:java.home=/usr/java/jdk1.7.0_67-cloudera/jre
INFO [main] (Environment.java:100) - Client environment:java.class.path=...
INFO [main] (Environment.java:100) - Client environment:java.library.path=/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib
INFO [main] (Environment.java:100) - Client environment:java.io.tmpdir=/tmp
INFO [main] (Environment.java:100) - Client environment:java.compiler=<NA>
INFO [main] (Environment.java:100) - Client environment:os.name=Linux
INFO [main] (Environment.java:100) - Client environment:os.arch=amd64
INFO [main] (Environment.java:100) - Client environment:os.version=2.6.32-431.29.2.el6.x86_64
INFO [main] (Environment.java:100) - Client environment:user.name=cloudera
INFO [main] (Environment.java:100) - Client environment:user.home=/home/cloudera
INFO [main] (Environment.java:100) - Client environment:user.dir=/home/cloudera/fh-muenster-bde-lesson-5
INFO [main] (ZooKeeper.java:438) - Initiating client connection, connectString=localhost:2181 sessionTimeout=90000 watcher=hconnection-0x6e233c17, quorum=localhost:2181, baseZNode=/hbase
INFO [main-SendThread(quickstart.cloudera:2181)] (ClientCnxn.java:975) - Opening socket connection to server quickstart.cloudera/127.0.0.1:2181. Will not attempt to authenticate using SASL (unknown error)
INFO [main-SendThread(quickstart.cloudera:2181)] (ClientCnxn.java:852) - Socket connection established to quickstart.cloudera/127.0.0.1:2181, initiating session
INFO [main-SendThread(quickstart.cloudera:2181)] (ClientCnxn.java:1235) - Session establishment complete on server quickstart.cloudera/127.0.0.1:2181, sessionid = 0x14a5d590d590040, negotiated timeout = 40000
INFO [main] (SchemaManager.java:189) - Creating table surl...
INFO [main] (RecoverableZooKeeper.java:119) - Process identifier=catalogtracker-on-hconnection-0x6e233c17 connecting to ZooKeeper ensemble=localhost:2181
INFO [main] (ZooKeeper.java:438) - Initiating client connection, connectString=localhost:2181 sessionTimeout=90000 watcher=catalogtracker-on-hconnection-0x6e233c17, quorum=localhost:2181, baseZNode=/hbase
INFO [main-SendThread(quickstart.cloudera:2181)] (ClientCnxn.java:975) - Opening socket connection to server quickstart.cloudera/127.0.0.1:2181. Will not attempt to authenticate using SASL (unknown error)
INFO [main-SendThread(quickstart.cloudera:2181)] (ClientCnxn.java:852) - Socket connection established to quickstart.cloudera/127.0.0.1:2181, initiating session
INFO [main-SendThread(quickstart.cloudera:2181)] (ClientCnxn.java:1235) - Session establishment complete on server quickstart.cloudera/127.0.0.1:2181, sessionid = 0x14a5d590d590041, negotiated timeout = 40000
INFO [main-EventThread] (ClientCnxn.java:512) - EventThread shut down
INFO [main] (ZooKeeper.java:684) - Session: 0x14a5d590d590041 closed
INFO [main] (SchemaManager.java:191) - Table created
INFO [main] (SchemaManager.java:189) - Creating table url...
...
INFO [main] (SchemaManager.java:191) - Table created
INFO [main] (SchemaManager.java:189) - Creating table user...
...
INFO [main] (SchemaManager.java:191) - Table created
INFO [main] (SchemaManager.java:189) - Creating table sdom...
...
INFO [main] (SchemaManager.java:191) - Table created
INFO [main] (SchemaManager.java:189) - Creating table ldom...
...
INFO [main] (SchemaManager.java:191) - Table created
INFO [main] (SchemaManager.java:189) - Creating table user-surl...
...
INFO [main] (SchemaManager.java:191) - Table created
INFO [main] (SchemaManager.java:189) - Creating table hush...
INFO [main-EventThread] (ClientCnxn.java:512) - EventThread shut down
...
INFO [main] (SchemaManager.java:191) - Table created
INFO [main-EventThread] (ClientCnxn.java:512) - EventThread shut down
...
INFO [main] (DomainManager.java:42) - Creating test domains.
INFO [main] (UrlManager.java:59) - Short Id counter initialized.
INFO [main] (UserManager.java:71) - Admin user initialized.
INFO [main] (UserManager.java:129) - Admin statistics initialized.
INFO [main] (HushMain.java:84) - Web server setup.
INFO [main] (HushMain.java:105) - Configuring security.
INFO [main] (Server.java:271) - jetty-7.6.16.v20140903
INFO [main] (ContextHandler.java:750) - started o.e.j.w.WebAppContext{/,file:/home/cloudera/fh-muenster-bde-lesson-5/src/main/webapp/},src/main/webapp
INFO [main] (Slf4jLog.java:67) - Logging to org.slf4j.impl.Log4jLoggerAdapter(org.mortbay.log) via org.mortbay.log.Slf4jLog
INFO [main] (AbstractConnector.java:338) - Started SelectChannelConnector@0.0.0.0:8080
```

Jetzt kann die Hush UI über Firefox aufgerufen werden unter: http://hba.se:8080/.

![Hush UI](https://raw.github.com/larsgeorge/fh-muenster-bde-lesson-5/master/static/img/hush-ui.png)


Während des Starts legt Hush auch einen Administrator Konto an, welches mit dem Username “admin” und Passwort “admin” versehen ist. Damit kann man sich in Hush anmelden und sehen, welche Kürzel angelegt worden sind. 

#### Hinweise:

Es könnte sein das die HBase Prozesse noch nicht innerhalb der Cloudera QuickStart VM laufen (oder durch Speichermangel beendet wurden). Wenn dies der Fall ist sind auch die HBase UIs nicht verfügbar, was mit den gespeicherten Links in dem in der VM enthaltenen Firefox Browser geprüft werden kann. Die Prozesse können über die Kommandozeile einfach wieder gestartet werden:

```
[cloudera@quickstart fh-muenster-bde-lesson-5]$ sudo service hbase-master start
starting master, logging to /var/log/hbase/hbase-hbase-master-quickstart.cloudera.out
Started HBase master daemon (hbase-master):                [  OK  ]
[cloudera@quickstart fh-muenster-bde-lesson-5]$ sudo service hbase-regionserver start
Starting Hadoop HBase regionserver daemon: starting regionserver, logging to /var/log/hbase/hbase-hbase-regionserver-quickstart.cloudera.out
hbase-regionserver.
```

Viel Glück!

Lars George
