/* -----------------------------------------------------------
 * 03_TestAQ_TopicExample.sql : topic example.
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
  -- It's a topic, so multiple_consumers parameter is specified.
  dbms_aqadm.create_queue_table (queue_table        => 'topics_qt',
                                 queue_payload_type => 'TESTAQ.MESSAGES_T',
                                 multiple_consumers => true);

  -- Create a test topic
  dbms_aqadm.create_queue (queue_name  => 'test_topic',
                           queue_table => 'topics_qt');
                           
  -- Start the topic for enqueuing and dequeuing messages.                           
  dbms_aqadm.start_queue (queue_name => 'test_topic');    
  
  -- Configure the demo subscriber.
  dbms_aqadm.add_subscriber (queue_name => 'test_topic',
                             subscriber => sys.aq$_agent(name     => 'demo_subscriber',
                                                         address  => null,
                                                         protocol => 0));
                                                         
  -- Register the procedure for dequeuing the messages received.
  dbms_aq.register(
    sys.aq$_reg_info_list(
      sys.aq$_reg_info('TESTAQ.TEST_TOPIC:DEMO_SUBSCRIBER',
                       dbms_aq.namespace_aq, 
                       'plsql://TESTAQ.TEST_P.RECEIVE_MESSAGE_CALLBACK',
                       hextoraw('FF'))
                      ),
      1);
end;
/
