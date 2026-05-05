set define "&"
define repo=&1
define schema=&2

prompt 
prompt *******************************************************
prompt **                                                   **
prompt **                 (c) RADAPEX 2026                  **
prompt **                                                   **
prompt **   This script initialises a new SQLcl `project`   **
prompt **        based on an existing db app/schema,        **
prompt **         leaving it ready for Peer Review.         **
prompt **                                                   **
prompt **                     USE CASE:                     **
prompt **    You have committed to a migration from your    **
prompt **     prior version control tool into `git` and     **
prompt **       SQLcl `project`,  which builds on the       **
prompt **      Liquibase changeset/log modus operandi.      **
prompt **                                                   **
prompt **                       USAGE                       **
prompt ** From the parent dir to sqlcl-project-migrate-util **
prompt **      @sqlcl-project-migrate-util/proj-init-mig\   **
prompt **        <your-new-migration-repo>\                 **
prompt **        <schema_to_migrate>                        **
prompt **                                                   **
prompt *******************************************************
prompt
pause Press a key to continue...

-- Confused.
-- SQLcl is leaving me in the directory this file is in, not my cwd, which should be the parent to that.
cd .

-- Contains some sql templates which we reference, as well as this script.
-- Assumes git repo cloned into a sibling-level folder to the new repo.
define tmplts="../sqlcl-project-migrate-util"
define customdir="./dist/releases/next/changes/sqlcl-project-migration/_custom"
prompt
prompt

prompt Liquibase has a problem with parallel dml, so you should use the _LOW connection, but for safety:
prompt ALTER SESSION DISABLE PARALLEL DML;
alter session disable parallel dml;

prompt
prompt Create the git repo and cd to it
!git init &repo --initial-branch main
cd &repo

pause

prompt
prompt Create the .gitignore from the template
!cp &tmplts/tmplt.gitignore .gitignore

-- No prompt needed here, it's clear enough anyway
-- prompt Initialise the SQLcl `project`
project init -name &repo -schemas &schema

prompt
prompt
prompt Copy in the project.sqlformat.xmlformat definition over the auto-generated one, and
prompt amend auto-gen'd project.config.json so schema names aren't prepended to object names:
!cp &tmplts/project.sqlformat.xml ./.dbtools
!sed -i '' -e 's/"emitSchema" : true,/"emitSchema" : false,/' .dbtools/project.config.json

prompt Commit the initial project files to git
!git add .
!git commit -m 'SQLcl Migration project initial files'

prompt
prompt EXPORT THE DATABASE CODEBASE (ignore warning: sqlcl.connectionName is not set)
prompt
project export -schemas &schema -verbose

prompt
prompt
prompt Commit the database export to a new migration branch
!git checkout -b sqlcl-project-migration
!git add .
!git commit -m 'Baseline SQLcl Migration project export files'

prompt
prompt
prompt `stage` a custom file into this release to set the schema appropriately
prompt at the outset, in case the schema passed is not the current user
prompt
project stage add-custom -file-name set_schema.sql
!cat &tmplts/set_schema.sql  >>  &customdir/set_schema.sql
!sed -i '' -e 's/sssss/&schema/' &customdir/set_schema.sql

prompt
prompt
prompt `stage`: Generate Liquibase changelogs and changesets for all source-object files 
prompt
project stage

prompt
prompt
prompt Amend `lb update` to `lb changelog-sync` (remove this step for schema deployment rather than migration).
prompt This causes the migration to just create the `databasechange*` tables so Liquibase is up to date.
prompt !sed -i '' -e 's/^lb update/lb changelog-sync/' ./dist/install.sql
!sed -i '' -e 's/^lb update/lb changelog-sync/' ./dist/install.sql

prompt
prompt
prompt Commit the Liquibase stuff to the new `project`
!git add .
!git commit -m 'Add SQLcl Migration project stage files'

prompt
prompt
prompt #################################################
prompt ##                                             ##
prompt ##    New repo/project exported and staged!    ##
prompt ##                                             ##
prompt ##         Note that ./dist/install.sql        ##
prompt ##        was amended during this script       ##
prompt ##                                             ##
prompt ##        lb update => lb changelog-sync       ##
prompt ##                                             ##
prompt ##   The new repo is ready for Peer Review.    ##
prompt ##                                             ##
prompt #################################################
prompt
prompt
