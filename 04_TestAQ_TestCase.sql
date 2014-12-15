/* -----------------------------------------------------------
 * 04_TestAQ_TestCase.sql : test case.
 *
 * Author: Francisco Saucedo (http://fcosfc.wordpress.com)
 *
 * Versioning:
 *
 *    v1.0, 14-12-2014: Initial version.
 *
 * License: GNU GPL (http://www.gnu.org/licenses/gpl-3.0.html)
 * ----------------------------------------------------------- */
 
set serveroutput on

declare
  QUEUE_MESSAGE       constant varchar2(20) := 'Queue test message';
  TOPIC_MESSAGE       constant varchar2(20) := 'Topic test message';
  NUM_TEST_MESSAGES   constant number(2) := 25;
    
  procedure check_num_messages (p_queue             in varchar2, 
                                p_content           in varchar2,
                                p_expected_messages in number)
  as
    l_received_messages number(2) := 0;
  begin
    select count(*)
      into l_received_messages
    from received_messages
    where content = p_content;
    
    if l_received_messages = p_expected_messages then
      dbms_output.put_line (p_queue || ': test passed');      
    else
      dbms_output.put_line (p_queue || ': test failed. Received: ' || 
                            l_received_messages ||
                            ', expected: ' ||
                            p_expected_messages);
    end if;
  exception
    when no_data_found then
      dbms_output.put_line (p_queue || ': test failed. Received: 0' || 
                            l_received_messages ||
                            ', expected: ' ||
                            p_expected_messages);
  end check_num_messages;
begin
  -- Enqueue some test messages
  for i in 1..NUM_TEST_MESSAGES
  loop
    test_p.send_message ('test_queue', QUEUE_MESSAGE);
  end loop;  
  commit;
  
  
  for i in 1..NUM_TEST_MESSAGES
  loop
    test_p.send_message ('test_topic', TOPIC_MESSAGE);
  end loop;  
  commit;
    
  -- Give the system time to process  
  dbms_lock.sleep(5);
  
  -- Verify the results
  check_num_messages ('test_queue', QUEUE_MESSAGE, NUM_TEST_MESSAGES);
  check_num_messages ('test_topic', TOPIC_MESSAGE, NUM_TEST_MESSAGES);
end;
/
