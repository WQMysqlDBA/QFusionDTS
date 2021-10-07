
DELIMITER //
CREATE TRIGGER demo BEFORE DELETE
ON chtest FOR EACH ROW
BEGIN
INSERT INTO logs VALUES(NOW());
INSERT INTO logs VALUES(NOW());
END
//
DELIMITER ;


delimiter $$
create procedure in_param(in p_in int)
begin
　　select p_in;
　　set p_in=2;
   select P_in;
end$$
delimiter ;
 
set @p_in=1;
 
call in_param(@p_in);



DELIMITER $$
DROP FUNCTION IF EXISTS genPerson$$
CREATE FUNCTION genPerson(name varchar(20)) RETURNS varchar(50)
BEGIN
  DECLARE str VARCHAR(50) DEFAULT '';
  SET @tableName=name;
  SET str=CONCAT('create table ', @tableName,'(id int, name varchar(20));');
  return str;
END $$
DELIMITER ;



CREATE EVENT IF NOT EXISTS e_test
ON SCHEDULE EVERY 1 SECOND
ON COMPLETION PRESERVE
DO CALL e_test();



DELIMITER ||
CREATE TRIGGER demo BEFORE DELETE
ON users FOR EACH ROW
BEGIN
INSERT INTO logs VALUES(NOW());
INSERT INTO logs VALUES(NOW());
END
||

DELIMITER ;





test1.chtest-schema.sql
test1.chtest-schema-triggers.sql
test1.myview-schema.sql
test1.myview-schema-view.sql
test1-schema-create.sql
test1-schema-post.sql



apple store 查看订单状态







CHANGE MASTER TO
  MASTER_HOST='10.129.24.35',
  MASTER_USER='qfdts4533',
  MASTER_PASSWORD='qfdtspwd-1',
  MASTER_PORT=4533,
  MASTER_AUTO_POSITION=1,
  MASTER_CONNECT_RETRY=10;


CHANGE MASTER TO
  MASTER_HOST='10.133.103.13',
  MASTER_USER='qfdts4706',
  MASTER_PASSWORD='qfdtspwd-1',
  MASTER_PORT=4706,
  MASTER_AUTO_POSITION=1,
  MASTER_CONNECT_RETRY=10;



CHANGE MASTER TO
  MASTER_HOST='10.129.24.11',
  MASTER_USER='qfdts4482',
  MASTER_PASSWORD='qfdtspwd-1',
  MASTER_PORT=4482,
  MASTER_AUTO_POSITION=1,
  MASTER_CONNECT_RETRY=10;

