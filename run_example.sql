@01_Sys_Setup.sql
disconnect
connect testaq/test1234
@02_TestAQ_QueueExample.sql
@03_TestAQ_TopicExample.sql
@04_TestAQ_TestCase.sql
disconnect
prompt I need the password of the user system to release the resources
connect system
@05_System_CLEAN.sql
disconnect
exit
