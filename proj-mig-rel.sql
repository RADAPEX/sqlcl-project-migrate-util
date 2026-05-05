prompt 
prompt **************************************
prompt **                                  **
prompt **      (c) RADAPEX 2026            **
prompt **                                  **
prompt ** This script merges a fresh SQLcl **
prompt **   `project` to the main branch   **
prompt **     as brought to Peer Review    **
prompt **     by @proj-mig-init script.    **
prompt **                                  **
prompt **************************************
prompt
prompt


prompt Liquibase has a problem with parallel dml, so you should use the _LOW connection, but for safety:
prompt ALTER SESSION DISABLE PARALLEL DML;
alter session disable parallel dml;

prompt Commit the migration back to main
!git checkout main
!git merge sqlcl-project-migration

-- project verify -verbose

prompt Finalise the migration into a release, and commit further files back to git
project release -version 1.0
!git add .
!git commit -m 'Baseline `project export` Release 1.0'

prompt
prompt
prompt #################################################
prompt ##                                             ##
prompt ##  The migration is now ready to be deployed! ##
prompt ##                                             ##
prompt ##      If this is just a changelog-sync,      ##
prompt ##      as setup by @proj-mig-init script,     ##
prompt ##      it will just create/retro-populate     ##
prompt ##      the Liquibase audit tables:            ##
prompt ##                                             ##
prompt ##         >   DATABASECHANGELOG               ##
prompt ##         >   DATABASECHANGELOGLOCK           ##
prompt ##                                             ##
prompt ##       This artifact is in ./artifact        ##
project gen-artifact -force
prompt ##                                             ##
prompt ##      Deploy it on the target db with:       ##
prompt ##                                             ##
prompt ##    SQL> project deploy /path/to/artifact    ##
prompt ##                                             ##
prompt #################################################
prompt
prompt
