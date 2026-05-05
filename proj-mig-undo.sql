set define "&"
define repo=&1
define schema=&2

whenever sqlerror continue
set verify off
drop view  &schema..databasechangelog_details;
drop table &schema..databasechangelog_actions purge;
drop table &schema..databasechangeloglock purge;
drop table &schema..databasechangelog purge;
set verify on

cd ..
!rm -fdr &repo
