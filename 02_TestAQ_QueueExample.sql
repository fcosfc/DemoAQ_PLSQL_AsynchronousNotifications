/* -----------------------------------------------------------
 * 02_TestAQ_QueueExample.sql : queue example.
 *
 * Author: Francisco Saucedo (http://fcosfc.wordpress.com)
 *
 * Versioning:
 *
 *    v1.0, 14-12-2014: Initial version.
 *
 * License: GNU GPL (http://www.gnu.org/licenses/gpl-3.0.html)
 * ----------------------------------------------------------- */
 
begin
  -- Create a table for queues of the type defined in 01_System_Setup.sql
  dbms_aqadm.create_queue_table (queue_table        => 'queues_qt',
                                 queue_payload_type => 'TESTAQ.MESSAGES_T');

  -- Create a test queue
  dbms_aqadm.create_queue (queue_name  => 'test_queue',
                           queue_table => 'queues_qt');
                           
  -- Start the queue for enqueuing and dequeuing messages.                           
  dbms_aqadm.start_queue (queue_name => 'test_queue');    
  
  -- Register the procedure for dequeuing the messages received.
  -- No subscriber is needed
  dbms_aq.register(
    sys.aq$_reg_info_list(
      sys.aq$_reg_info('TESTAQ.TEST_QUEUE',
                       dbms_aq.namespace_aq, 
                       'plsql://TESTAQ.TEST_P.RECEIVE_MESSAGE_CALLBACK',
                       hextoraw('FF'))
                      ),
      1);
end;
/
