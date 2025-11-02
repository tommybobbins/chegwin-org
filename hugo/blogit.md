$ influx config list
Active	Name		URL										Org
*	default		http://localhost:8086	bobbins

$ influx config create --config-name prd1 --host-url https://randomprd1strings.timestream-influxdb.eu-west-2.on.aws:8086 --token <influxv2token> --org bobbins --active

Active	Name	URL										Org
*	prd1	https://randomprd1strings.timestream-influxdb.eu-west-2.on.aws:8086	bobbins
$ influx v1 shell


tng@Tims-MacBook-Air prd % influx backup --help
NAME:
    backup - Backup database

USAGE:
    backup [command options] path

DESCRIPTION:
   Backs up InfluxDB to a directory

Examples:
  # backup all data
  influx backup /path/to/backup


COMMON OPTIONS:
   --host value                     HTTP address of InfluxDB [$INFLUX_HOST]
   --skip-verify                    Skip TLS certificate chain and host name verification [$INFLUX_SKIP_VERIFY]
   --configs-path value             Path to the influx CLI configurations [$INFLUX_CONFIGS_PATH]
   --active-config value, -c value  Config name to use for command [$INFLUX_ACTIVE_CONFIG]
   --http-debug                     
   --token value, -t value          Token to authenticate request [$INFLUX_TOKEN]
   
OPTIONS:
   --org-id value            The ID of the organization [$INFLUX_ORG_ID]
   --org value, -o value     The name of the organization [$INFLUX_ORG]
   --bucket-id value         The ID of the bucket to backup
   --bucket value, -b value  The name of the bucket to backup
   --compression value       Compression to use for local backup files, either 'none' or 'gzip' (default: gzip)
   
$ influx bucket list  
ID			Name		Retention	Shard group duration	Organization ID		Schema Type
0fe316f76449a25a	data	        infinite	168h0m0s		2d3994e86e24883d	implicit
tng@Tims-MacBook-Air prd % influx backup --bucket-id 0fe316f76449a25a .          
2025/10/31 14:58:20 WARN: Couldn't parse version "dev" reported by server, assuming latest backup/restore APIs are supported
2025/10/31 14:58:20 INFO: Downloading metadata snapshot
Error: failed to backup metadata: failed to download metadata snapshot: 401 Unauthorized: read:authorizations is unauthorized

    AWS Secrets Manager >> Secrets >> READONLY-InfluxDB-auth-parameters-abcdef174


$ influx config set -n prd1 --username-password myifluxadmin:mypassword
Active	Name	URL										Org
*	prd1	https://randomprd1string-timestream-influxdb.eu-west-2.on.aws:8086	sense

$ influx bucket list

tng@macos prd % influx bucket list
ID			Name			Retention	Shard group duration	Organization ID		Schema Type
ed8e66aa1a6cce40	_monitoring		168h0m0s	24h0m0s			dd268695fbcf97af	implicit
6ccdac85ef33acf8	_tasks			72h0m0s		24h0m0s			dd268695fbcf97af	implicit
0fe316f76449a25a	data			8760h0m0s	168h0m0s		dd268695fbcf97af	implicit

% influx backup --bucket-id 0fe316f76449a25a .
2025/10/31 15:30:48 WARN: Couldn't parse version "dev" reported by server, assuming latest backup/restore APIs are supported
2025/10/31 15:30:48 INFO: Downloading metadata snapshot
2025/10/31 15:30:49 INFO: Backing up TSM for shard 1
2025/10/31 15:30:49 INFO: Backing up TSM for shard 2
2025/10/31 15:30:49 WARN: Shard 2 removed during backup
2025/10/31 15:30:49 INFO: Backing up TSM for shard 3
2025/10/31 15:30:49 WARN: Shard 3 removed during backup
2025/10/31 15:30:49 INFO: Backing up TSM for shard 4
2025/10/31 15:30:49 WARN: Shard 4 removed during backup
2025/10/31 15:30:49 INFO: Backing up TSM for shard 5
2025/10/31 15:30:49 INFO: Backing up TSM for shard 6
2025/10/31 15:30:49 INFO: Backing up TSM for shard 7
2025/10/31 15:30:49 INFO: Backing up TSM for shard 8
2025/10/31 15:30:49 INFO: Backing up TSM for shard 9
2025/10/31 15:30:49 INFO: Backing up TSM for shard 10
2025/10/31 15:30:50 INFO: Backing up TSM for shard 11


$ influx restore .
2025/10/31 15:54:57 INFO: Restoring bucket "0fe316f76449a25a" as "sense-data"
Error: failed to restore bucket "sense-data": 422 Unprocessable Entity: bucket with name sense-data already exists
tng@macos prd % influx restore .
2025/10/31 15:55:10 INFO: Restoring bucket "0fe316f76449a25a" as "sense-data"
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 49
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 50
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 51
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 52
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 53
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 54
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 55
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 56


$ influxd inspect export-lp --bucket-id fdfc5112c8a6a777 --output-path ./prd1-influx2-$(date +%F).lp
{"level":"info","ts":1761926299.37861,"caller":"export_lp/export_lp.go:219","msg":"exporting TSM files","tsm_dir":"/home/tng/.influxdbv2/engine/data/fdfc5112c8a6a777","file_count":8}
{"level":"info","ts":1761926300.2268832,"caller":"export_lp/export_lp.go:315","msg":"exporting WAL files","wal_dir":"/home/tng/.influxdbv2/engine/wal/fdfc5112c8a6a777","file_count":0}
{"level":"info","ts":1761926300.2269042,"caller":"export_lp/export_lp.go:204","msg":"export complete"}


export AUTH_TOKEN=apiv3_abcfdfgfgffgfdgfgdgdfgg
#!/bin/bash
#split -l80000 dev1-export-lp-2025-10-31.lp
for file in x??
do
    echo $file
    /usr/local/influxdb3/influxdb3 write -H "https://endpoint.on.aws:8181/api/v3/query_sql" -d sense-data --token $AUTH_TOKEN --file $file
sleep 2
done
~

tng@macos LP % ./import_prd1.sh 
xaa
success
xab
success
xac
success
xad
success
xae
success        
