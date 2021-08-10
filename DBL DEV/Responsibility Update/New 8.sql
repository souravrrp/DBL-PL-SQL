CREATE OR REPLACE PACKAGE BODY emp_mgmt AS 
   tot_emps NUMBER; 
   tot_depts NUMBER; 
FUNCTION create_dept(department_id NUMBER, location_id NUMBER) 
   RETURN NUMBER IS 
      new_deptno NUMBER; 
   BEGIN 
      SELECT departments_seq.NEXTVAL 
         INTO new_deptno 
         FROM dual; 
      INSERT INTO departments 
         VALUES (new_deptno, 'department name', 100, 1700); 
      tot_depts := tot_depts + 1; 
      RETURN(new_deptno); 
   END; 
PROCEDURE increase_sal(employee_id NUMBER, salary_incr NUMBER) IS 
   curr_sal NUMBER; 
   BEGIN 
      SELECT salary INTO curr_sal FROM employees 
      WHERE employees.employee_id = increase_sal.employee_id; 
      IF curr_sal IS NULL 
         THEN RAISE no_sal; 
      ELSE 
         UPDATE employees 
         SET salary = salary + salary_incr 
         WHERE employee_id = employee_id; 
      END IF; 
   END;  
END emp_mgmt; 
/ 