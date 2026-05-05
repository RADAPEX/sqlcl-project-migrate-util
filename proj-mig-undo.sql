set define "&"
define repo=&1
define schema=&2

!cwd=`pwd`;cd ..;rm -fdr $cwd
cd ..
pwd

/*
cd ..
!rm -fdr &repo
!rm -fdr `pwd`

whenever sqlerror continue
set verify off
drop view  &schema..databasechangelog_actions;
drop table &schema..databasechangeloglock purge;
drop table &schema..databasechangelog purge;
set verify on
*/
