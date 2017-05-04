--TRUE AND NULL is not truthy
SELECT 'SQL truthy' result
FROM dual
WHERE (1=1) AND (1=NULL);

--TRUE AND NULL is not truthy
SELECT 'SQL truthy' result
FROM dual
WHERE (1=NULL) AND (1=1);

--NULL OR TRUE is truthy
SELECT 'SQL truthy' result
FROM dual
WHERE (1=NULL) OR (1=1);

--TRUE OR NULL is truthy
SELECT 'SQL truthy' result
FROM dual
WHERE (1=1)  OR (1=NULL) ;

-- not NULL is not truthy
SELECT 'SQL truthy' result
FROM dual
WHERE not(NULL = 1);

-- proving that oracle's check constraints are looking for a FALSE condintion (as opposed to not TRUE).
CREATE TABLE null_unsafe_check_constraint (
  col1 VARCHAR2(4000)
, col2 VARCHAR2(4000)
, CONSTRAINT ck1 CHECK (col1 = col2 )
);

-- will go bang
INSERT INTO null_unsafe_check_constraint VALUES(
  '1'
, '2'
);

-- will work
INSERT INTO null_unsafe_check_constraint VALUES(
  '1'
, '1'
);

-- will work !!!
INSERT INTO null_unsafe_check_constraint VALUES(
  NULL
, '1'
);

-- some fun with the difference in lazy execution, PL/SQL executes differently if you run
-- an assignment or a predicate in an IF statement.
CREATE OR REPLACE  FUNCTION ret_null  RETURN BOOLEAN IS
  BEGIN
    dbms_output.put_line('ret_null run');
    RETURN NULL;
  END;

CREATE OR REPLACE  FUNCTION ret_true RETURN BOOLEAN IS
  BEGIN
    dbms_output.put_line('ret_true run');
    RETURN TRUE;
  END;

CREATE OR REPLACE FUNCTION ret_false RETURN BOOLEAN IS
  BEGIN
    dbms_output.put_line('ret_false run');
    RETURN FALSE;
  END;


CREATE OR REPLACE PROCEDURE print_boolean(bool BOOLEAN)  IS
  BEGIN
    dbms_output.put_line( CASE bool
                          WHEN TRUE THEN  'true'
                          WHEN FALSE THEN 'false'
                          ELSE 'null'
                          END);
  END;


-- lazy execution if (OR)
-- only the first is run as it's always going to be true
BEGIN
  dbms_output.put_line('true or null');
  IF ret_true() OR ret_null() THEN
    dbms_output.put_line('in TRUE part of IF');
  ELSE
    dbms_output.put_line('in FALSE part of IF');
  END IF;
END;

--lazy execution assignment (OR)
-- as the first function returns true then we don't need to check the second as it won't affect the result
DECLARE
  l_bool BOOLEAN;
BEGIN
  dbms_output.put_line('true or null');
  l_bool := ret_true() OR ret_null();
  print_boolean(l_bool);

END;



-- lazy execution if (AND)
-- as the IF expression can't be true, the second statement isn't executed
BEGIN
  dbms_output.put_line('null and true');
  IF ret_null() AND ret_true() THEN
    dbms_output.put_line('in TRUE part of IF');
  ELSE
    dbms_output.put_line('in FALSE part of IF');
  END IF;
END;

-- (not so) lazy execution assign (AND) !!!!
-- the second call to ret_true needs to be made to determine whether the result is NULL or FALSE
DECLARE
  l_bool BOOLEAN;
BEGIN
  dbms_output.put_line('null and true');
  l_bool := ret_null() AND ret_true();
  print_boolean(l_bool);
END;

