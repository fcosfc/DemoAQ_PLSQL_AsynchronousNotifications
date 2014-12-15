/* -----------------------------------------------------------
 * 01_Sys_Setup.sql : setup the environment for the test.
 *
 * Author: Francisco Saucedo (http://fcosfc.wordpress.com)
 *
 * Versioning:
 *
 * v1.0, 14-12-2014: Initial version.
 *
 * License: GNU GPL (http://www.gnu.org/licenses/gpl-3.0.html)
 * ----------------------------------------------------------- */

-- Create a test user with the proper permissions
create user testaq
identified by test1234
default tablespace users
quota unlimited on users;

grant create session   to testaq;
grant create table     to testaq;
grant create procedure to testaq;

grant execute on dbms_aqadm to testaq;
grant execute on dbms_aq    to testaq;
-- This permission is needed for the test case
grant execute on dbms_lock  to testaq;

-- ########################################
-- Auxiliar objects in testaq schema
-- ########################################

-- Create the type for the messages payload.
create or replace type testaq.messages_t 
as object (message varchar2(100 char));
/

-- Create a table to store the received messages.
create table testaq.received_messages (
  received_message_id number              primary key,
  received_timestamp  timestamp           default systimestamp,
  content             varchar2(100 char));

-- Create a sequence for id generation.
create sequence testaq.received_messages_id_s;

-- Create a package with procedures to enqueue and dequeue messages.
create package testaq.test_p
as
  procedure receive_message_callback (
    context   raw,
    reginfo   sys.aq$_reg_info,
    descr     sys.aq$_descriptor,
    payload   raw,
    payloadl  number);
  
  procedure send_message (
    queue           in varchar,
    message_content in clob);
end;
/

-- Create a package with procedures to enqueue and dequeue messages.
create package body testaq.test_p
as
  procedure receive_message_callback (
    context   raw,
    reginfo   sys.aq$_reg_info,
    descr     sys.aq$_descriptor,
    payload   raw,
    payloadl  number)
  is
    r_dequeue_options    dbms_aq.dequeue_options_t;
    r_message_properties dbms_aq.message_properties_t;
    v_message_handle     raw(26);
    o_payload            messages_t;
  begin
    r_dequeue_options.msgid         := descr.msg_id;
    r_dequeue_options.consumer_name := descr.consumer_name;
    dbms_aq.dequeue(queue_name         => descr.queue_name,
                    dequeue_options    => r_dequeue_options,
                    message_properties => r_message_properties,
                    payload            => o_payload,
                    msgid              => v_message_handle);

    insert into received_messages
      (received_message_id, content)
    values (received_messages_id_s.nextval, o_payload.message);    
    commit;
  exception
    when others then
      rollback;
  end receive_message_callback;
  
  procedure send_message (
    queue           in varchar,
    message_content in clob)
  is
    enq_msgid raw(16);
    eopt      dbms_aq.enqueue_options_t;
    mprop     dbms_aq.message_properties_t;
  begin
    dbms_aq.enqueue(queue_name         => queue,
                    enqueue_options    => eopt,
                    message_properties => mprop,
                    payload            => messages_t(message_content),
                    msgid              => enq_msgid);
  end send_message;
end;
/
