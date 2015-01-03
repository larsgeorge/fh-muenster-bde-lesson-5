## Kommandos

Hier die Kommandos welche während der Übung durchgeführt wurden. Zuerst muss die HBase Shell innerhalb einer Terminal Sitzung gestartet werden:

```
[cloudera@quickstart fh-muenster-bde-lesson-5]$ hbase shell
2015-01-02 12:01:55,351 INFO [main] Configuration.deprecation: hadoop.native.lib is deprecated. Instead, use io.native.lib.available
HBase Shell; enter 'help<RETURN>' for list of supported commands.
Type "exit<RETURN>" to leave the HBase Shell
Version 0.98.6-cdh5.2.0, rUnknown, Sat Oct 11 15:15:15 PDT 2014
```

Das “help” Kommando zeigt alle möglichen weiteren Kommandos an:

```
hbase(main):001:0> help
HBase Shell, version 0.98.6-cdh5.2.0, rUnknown, Sat Oct 11 15:15:15 PDT 2014
Type 'help "COMMAND"', (e.g. 'help "get"' -- the quotes are necessary) for help on a specific command.
Commands are grouped. Type 'help "COMMAND_GROUP"', (e.g. 'help "general"') for help on a command group.

COMMAND GROUPS:
Group name: general
Commands: status, table_help, version, whoami

Group name: ddl
Commands: alter, alter_async, alter_status, create, describe, disable, disable_all, drop, drop_all, enable, enable_all, exists, get_table, is_disabled, is_enabled, list, show_filters

Group name: namespace
Commands: alter_namespace, create_namespace, describe_namespace, drop_namespace, list_namespace, list_namespace_tables

Group name: dml
Commands: append, count, delete, deleteall, get, get_counter, incr, put, scan, truncate, truncate_preserve

Group name: tools
Commands: assign, balance_switch, balancer, catalogjanitor_enabled, catalogjanitor_run, catalogjanitor_switch, close_region, compact, flush, hlog_roll, major_compact, merge_region, move, split, trace, unassign, zk_dump

Group name: replication
Commands: add_peer, disable_peer, enable_peer, list_peers, list_replicated_tables, remove_peer, set_peer_tableCFs, show_peer_tableCFs

Group name: snapshots
Commands: clone_snapshot, delete_snapshot, list_snapshots, rename_snapshot, restore_snapshot, snapshot

Group name: quotas
Commands: list_quotas, set_quota

Group name: security
Commands: grant, revoke, user_permission

Group name: visibility labels
Commands: add_labels, clear_auths, get_auths, set_auths, set_visibility

SHELL USAGE:
Quote all names in HBase Shell such as table and column names. Commas delimit
command parameters. Type <RETURN> after entering a command to run it.
Dictionaries of configuration used in the creation and alteration of tables are
Ruby Hashes. They look like this:

{'key1' => 'value1', 'key2' => 'value2', ...}

and are opened and closed with curley-braces. Key/values are delimited by the
'=>' character combination. Usually keys are predefined constants such as
NAME, VERSIONS, COMPRESSION, etc. Constants do not need to be quoted. Type
'Object.constants' to see a (messy) list of all constants in the environment.

If you are using binary keys or values and need to enter them in the shell, use
double-quote'd hexadecimal representation. For example:

hbase> get 't1', "key\x03\x3f\xcd"
hbase> get 't1', "key\003\023\011"
hbase> put 't1', "test\xef\xff", 'f1:', "\x01\x33\x40"

The HBase shell is the (J)Ruby IRB with the above HBase-specific commands added.
For more on the HBase Shell, see http://hbase.apache.org/docs/current/book.html
```

Als erstes muss eine Tabelle erstellt werden. HBase braucht keine grosse Schema Definition ausser mindestens einer Spaltenfamilie (Column Family). Die Voreinstellung für die Anzahl an Versionen pro Zelle ist seit HBase 0.98 auf “1” gesetzt. Um die Versionierung zu testen, erstellen wir hier eine Tabelle mit drei Versionen pro Zelle:

```
hbase(main):002:0> create "test", { NAME => "cf1", VERSIONS => 3 }
0 row(s) in 3.0290 seconds

=> Hbase::Table - test

hbase(main):003:0> describe "test"
DESCRIPTION ENABLED
'test', {NAME => 'cf1', DATA_BLOCK_ENCODING => 'NONE', BLOOMFILTER => 'ROW', REPLICATION_SCOPE = true
> '0', VERSIONS => '3', COMPRESSION => 'NONE', MIN_VERSIONS => '0', TTL => 'FOREVER', KEEP_DELET
ED_CELLS => 'false', BLOCKSIZE => '65536', IN_MEMORY => 'false', BLOCKCACHE => 'true'}
1 row(s) in 0.0860 seconds
```

Als nächstes speichern wir einige Werte in der neuen Tabelle und fragen diese wieder ab: 

```
hbase(main):004:0> put "test", "row1", "cf1:col1", "val1"
0 row(s) in 0.1960 seconds

hbase(main):005:0> put "test", "row2", "cf1:col1", "val2"
0 row(s) in 0.0120 seconds

hbase(main):007:0> scan "test"
ROW COLUMN+CELL
row1 column=cf1:col1, timestamp=1420229228506, value=val1
row2 column=cf1:col1, timestamp=1420229236035, value=val2
2 row(s) in 0.0550 seconds
```

Die Daten werden in HBase zuerst in einem binären Log gespeichert und im Speicher sortiert abgelegt. Erst nach einiger Zeit oder einer bestimmten Anzahl von Daten werden diese in einer eigenen Datei angelegt. Dies kann man auch prüfen, indem man sich das Verzeichnis in HDFS anschaut:

```
[cloudera@quickstart fh-muenster-bde-lesson-5]$ hdfs dfs -ls -R /hbase/data/default/test
...
drwxr-xr-x - hbase supergroup 0 2015-01-02 12:04 /hbase/data/default/test/3dcaa290885425e35c62676562f86143/cf1
```

Um die Speicherung in einer eigenen Datei zu erzwingen kann man das “flush” Kommando benutzen. Danach ist eine Datei im Verzeichnis verfügbar:

```
hbase(main):008:0> flush "test"
0 row(s) in 0.3980 seconds

[cloudera@quickstart fh-muenster-bde-lesson-5]$ hdfs dfs -ls -R /hbase/data/default/test
...
drwxr-xr-x - hbase supergroup 0 2015-01-02 12:10 /hbase/data/default/test/3dcaa290885425e35c62676562f86143/cf1
-rw-r--r-- 1 hbase supergroup 1033 2015-01-02 12:10 /hbase/data/default/test/3dcaa290885425e35c62676562f86143/cf1/ae773e6ed5114c9e936a5374d0acfae0
```

Siehe “HFile Informationen” unten für weitere Möglichkeiten der Analyse der HBase Dateien.

Als nächstes prüfen wir die Versionierung von Zellen. Dazu überschreiben wir einen vorher gespeicherten Wert mit einem neuen und holen dann den aktuellen, und dann alle möglichen Werte ab:

```
hbase(main):009:0> put "test", "row1", "cf1:col1", "val2"
0 row(s) in 0.0270 seconds

hbase(main):010:0> get "test", "row1"
COLUMN CELL
cf1:col1 timestamp=1420229819276, value=val2
1 row(s) in 0.0470 seconds

hbase(main):002:0> get "test", "row1", { COLUMN => "cf1:col1", VERSIONS => 3 }
COLUMN CELL
cf1:col1 timestamp=1420229819276, value=val2
cf1:col1 timestamp=1420229228506, value=val1
2 row(s) in 0.0170 seconds
```

Jetzt können wir einen speziellen Wert, also eine spezielle Zelle, zum Beispiel löschen und dann versuchen abzufragen:

```
hbase(main):003:0> delete "test", "row1", "cf1:col1", 1420229228506
0 row(s) in 0.1220 seconds

hbase(main):004:0> get "test", "row1", { COLUMN => "cf1:col1", VERSIONS => 3 }
COLUMN CELL
cf1:col1 timestamp=1420229819276, value=val2
1 row(s) in 0.0380 seconds

hbase(main):005:0> get "test", "row1", { COLUMN => "cf1:col1", TIMESTAMP => 1420229228506 }
COLUMN CELL
0 row(s) in 0.0090 seconds
```

Weitere Informationen sind unten zu sehen, wo die Daten beider (nach einem weiteren “flush” Kommando) HFile Dateien ausgegeben sind. Man kann dort den alten Wert immer noch sehen, obwohl der Wert in der Shell nicht mehr abgefragt werden kann. Die “Tombstone” (siehe “DeleteColumn”) Markierung sorgt dafür, dass der Wert für Client Anwendungen nicht mehr sichtbar ist.


# HFile Informationen

```
[cloudera@quickstart fh-muenster-bde-lesson-5]$ hdfs dfs -ls /hbase/
Found 6 items
drwxr-xr-x - hbase supergroup 0 2015-01-02 11:55 /hbase/.tmp
drwxr-xr-x - hbase supergroup 0 2015-01-02 11:55 /hbase/WALs
drwxr-xr-x - hbase supergroup 0 2015-01-02 11:55 /hbase/data
-rw-r--r-- 1 hbase supergroup 42 2015-01-02 11:11 /hbase/hbase.id
-rw-r--r-- 1 hbase supergroup 7 2015-01-02 11:11 /hbase/hbase.version
drwxr-xr-x - hbase supergroup 0 2015-01-02 12:05 /hbase/oldWALs

[cloudera@quickstart fh-muenster-bde-lesson-5]$ hdfs dfs -ls /hbase/data/
Found 2 items
drwxr-xr-x - hbase supergroup 0 2015-01-02 12:04 /hbase/data/default
drwxr-xr-x - hbase supergroup 0 2015-01-02 11:55 /hbase/data/hbase

[cloudera@quickstart fh-muenster-bde-lesson-5]$ hdfs dfs -ls -R /hbase/data/default/test
drwxr-xr-x - hbase supergroup 0 2015-01-02 12:04 /hbase/data/default/test/.tabledesc
-rw-r--r-- 1 hbase supergroup 283 2015-01-02 12:04 /hbase/data/default/test/.tabledesc/.tableinfo.0000000001
drwxr-xr-x - hbase supergroup 0 2015-01-02 12:04 /hbase/data/default/test/.tmp
drwxr-xr-x - hbase supergroup 0 2015-01-02 12:04 /hbase/data/default/test/3dcaa290885425e35c62676562f86143
-rw-r--r-- 1 hbase supergroup 37 2015-01-02 12:04 /hbase/data/default/test/3dcaa290885425e35c62676562f86143/.regioninfo
drwxr-xr-x - hbase supergroup 0 2015-01-02 12:04 /hbase/data/default/test/3dcaa290885425e35c62676562f86143/cf1

[cloudera@quickstart fh-muenster-bde-lesson-5]$ hdfs dfs -ls -R /hbase/data/default/test
drwxr-xr-x - hbase supergroup 0 2015-01-02 12:04 /hbase/data/default/test/.tabledesc
-rw-r--r-- 1 hbase supergroup 283 2015-01-02 12:04 /hbase/data/default/test/.tabledesc/.tableinfo.0000000001
drwxr-xr-x - hbase supergroup 0 2015-01-02 12:04 /hbase/data/default/test/.tmp
drwxr-xr-x - hbase supergroup 0 2015-01-02 12:10 /hbase/data/default/test/3dcaa290885425e35c62676562f86143
-rw-r--r-- 1 hbase supergroup 37 2015-01-02 12:04 /hbase/data/default/test/3dcaa290885425e35c62676562f86143/.regioninfo
drwxr-xr-x - hbase supergroup 0 2015-01-02 12:10 /hbase/data/default/test/3dcaa290885425e35c62676562f86143/.tmp
drwxr-xr-x - hbase supergroup 0 2015-01-02 12:10 /hbase/data/default/test/3dcaa290885425e35c62676562f86143/cf1
-rw-r--r-- 1 hbase supergroup 1033 2015-01-02 12:10 /hbase/data/default/test/3dcaa290885425e35c62676562f86143/cf1/ae773e6ed5114c9e936a5374d0acfae0

[cloudera@quickstart fh-muenster-bde-lesson-5]$ hbase hfile
2015-01-02 12:12:50,736 INFO [main] Configuration.deprecation: hadoop.native.lib is deprecated. Instead, use io.native.lib.available
2015-01-02 12:12:51,069 INFO [main] util.ChecksumType: Checksum using org.apache.hadoop.util.PureJavaCrc32
2015-01-02 12:12:51,084 INFO [main] util.ChecksumType: Checksum can use org.apache.hadoop.util.PureJavaCrc32C
2015-01-02 12:12:53,566 INFO [main] Configuration.deprecation: fs.default.name is deprecated. Instead, use fs.defaultFS
usage: HFile [-a] [-b] [-e] [-f <arg>] [-k] [-m] [-p] [-r <arg>] [-s] [-v]
[-w <arg>]
-a,--checkfamily Enable family check
-b,--printblocks Print block index meta data
-e,--printkey Print keys
-f,--file <arg> File to scan. Pass full-path; e.g.
hdfs://a:9000/hbase/hbase:meta/12/34
-k,--checkrow Enable row order check; looks for out-of-order
keys
-m,--printmeta Print meta data of file
-p,--printkv Print key/value pairs
-r,--region <arg> Region to scan. Pass region name; e.g.
'hbase:meta,,1'
-s,--stats Print statistics
-v,--verbose Verbose output; emits file and meta data
delimiters
-w,--seekToRow <arg> Seek to this row and print all the kvs for this
row only

[cloudera@quickstart fh-muenster-bde-lesson-5]$ hbase hfile -m -s -f /hbase/data/default/test/3dcaa290885425e35c62676562f86143/cf1/ae773e6ed5114c9e936a5374d0acfae0
2015-01-02 12:14:10,126 INFO [main] Configuration.deprecation: hadoop.native.lib is deprecated. Instead, use io.native.lib.available
2015-01-02 12:14:10,490 INFO [main] util.ChecksumType: Checksum using org.apache.hadoop.util.PureJavaCrc32
2015-01-02 12:14:10,493 INFO [main] util.ChecksumType: Checksum can use org.apache.hadoop.util.PureJavaCrc32C
2015-01-02 12:14:13,009 INFO [main] Configuration.deprecation: fs.default.name is deprecated. Instead, use fs.defaultFS
2015-01-02 12:14:13,314 INFO [main] hfile.CacheConfig: Allocating LruBlockCache with maximum size 393.4 M
Block index size as per heapsize: 392
reader=/hbase/data/default/test/3dcaa290885425e35c62676562f86143/cf1/ae773e6ed5114c9e936a5374d0acfae0,
compression=none,
cacheConf=CacheConfig:enabled [cacheDataOnRead=true] [cacheDataOnWrite=false] [cacheIndexesOnWrite=false] [cacheBloomsOnWrite=false] [cacheEvictOnClose=false] [cacheCompressed=false][prefetchOnOpen=false],
firstKey=row1/cf1:col1/1420229228506/Put,
lastKey=row2/cf1:col1/1420229236035/Put,
avgKeyLen=23,
avgValueLen=4,
entries=2,
length=1033
Trailer:
fileinfoOffset=260,
loadOnOpenDataOffset=150,
dataIndexCount=1,
metaIndexCount=0,
totalUncomressedBytes=940,
entryCount=2,
compressionCodec=NONE,
uncompressedDataIndexSize=36,
numDataIndexLevels=1,
firstDataBlockOffset=0,
lastDataBlockOffset=0,
comparatorClassName=org.apache.hadoop.hbase.KeyValue$KeyComparator,
majorVersion=2,
minorVersion=3
Fileinfo:
BLOOM_FILTER_TYPE = ROW
DELETE_FAMILY_COUNT = \x00\x00\x00\x00\x00\x00\x00\x00
EARLIEST_PUT_TS = \x00\x00\x01J\xACB7\xDA
KEY_VALUE_VERSION = \x00\x00\x00\x01
LAST_BLOOM_KEY = row2
MAJOR_COMPACTION_KEY = \x00
MAX_MEMSTORE_TS_KEY = \x00\x00\x00\x00\x00\x00\x00\x00
MAX_SEQ_ID_KEY = 4
TIMERANGE = 1420229228506....1420229236035
hfile.AVG_KEY_LEN = 23
hfile.AVG_VALUE_LEN = 4
hfile.LASTKEY = \x00\x04row2\x03cf1col1\x00\x00\x01J\xACBUC\x04
Mid-key: \x00\x04row1\x03cf1col1\x00\x00\x01J\xACB7\xDA\x04
Bloom filter:
BloomSize: 4
No of Keys in bloom: 2
Max Keys for bloom: 3
Percentage filled: 67%
Number of chunks: 1
Comparator: RawBytesComparator
Delete Family Bloom filter:
Not present
Stats:
Key length:
min = 23.00
max = 23.00
mean = 23.00
stddev = 0.00
median = 23.00
75% <= 23.00
95% <= 23.00
98% <= 23.00
99% <= 23.00
99.9% <= 23.00
count = 2
Row size (bytes):
min = 35.00
max = 35.00
mean = 35.00
stddev = 0.00
median = 35.00
75% <= 35.00
95% <= 35.00
98% <= 35.00
99% <= 35.00
99.9% <= 35.00
count = 2
Row size (columns):
min = 1.00
max = 1.00
mean = 1.00
stddev = 0.00
median = 1.00
75% <= 1.00
95% <= 1.00
98% <= 1.00
99% <= 1.00
99.9% <= 1.00
count = 2
Val length:
min = 4.00
max = 4.00
mean = 4.00
stddev = 0.00
median = 4.00
75% <= 4.00
95% <= 4.00
98% <= 4.00
99% <= 4.00
99.9% <= 4.00
count = 2
Key of biggest row: row1

[cloudera@quickstart fh-muenster-bde-lesson-5]$ hbase hfile -p -f /hbase/data/default/test/3dcaa290885425e35c62676562f86143/cf1/ae773e6ed5114c9e936a5374d0acfae0
2015-01-02 14:21:13,106 INFO [main] Configuration.deprecation: hadoop.native.lib is deprecated. Instead, use io.native.lib.available
2015-01-02 14:21:13,498 INFO [main] util.ChecksumType: Checksum using org.apache.hadoop.util.PureJavaCrc32
2015-01-02 14:21:13,502 INFO [main] util.ChecksumType: Checksum can use org.apache.hadoop.util.PureJavaCrc32C
2015-01-02 14:21:15,994 INFO [main] Configuration.deprecation: fs.default.name is deprecated. Instead, use fs.defaultFS
2015-01-02 14:21:16,296 INFO [main] hfile.CacheConfig: Allocating LruBlockCache with maximum size 393.4 M
K: row1/cf1:col1/1420229228506/Put/vlen=4/mvcc=0 V: val1
K: row2/cf1:col1/1420229236035/Put/vlen=4/mvcc=0 V: val2
Scanned kv count -> 2

[cloudera@quickstart fh-muenster-bde-lesson-5]$ hbase hfile -p -f /hbase/data/default/test/3dcaa290885425e35c62676562f86143/cf1/1755649973414c4ba5135efa91a7d3ab
2015-01-02 14:22:18,785 INFO [main] Configuration.deprecation: hadoop.native.lib is deprecated. Instead, use io.native.lib.available
2015-01-02 14:22:19,126 INFO [main] util.ChecksumType: Checksum using org.apache.hadoop.util.PureJavaCrc32
2015-01-02 14:22:19,135 INFO [main] util.ChecksumType: Checksum can use org.apache.hadoop.util.PureJavaCrc32C
2015-01-02 14:22:21,903 INFO [main] Configuration.deprecation: fs.default.name is deprecated. Instead, use fs.defaultFS
2015-01-02 14:22:22,213 INFO [main] hfile.CacheConfig: Allocating LruBlockCache with maximum size 393.4 M
K: row1/cf1:col1/1420229819276/Put/vlen=4/mvcc=0 V: val2
K: row1/cf1:col1/1420229228506/DeleteColumn/vlen=0/mvcc=0 V:
Scanned kv count -> 2
```
