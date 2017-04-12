-----------------------------------------------
--              Assignment #1                --
--            Semaphores in Ada              --
--                                           --
--        Student:    Sergei Vasilenko       --
--        Group:      IO-42                  --
--        Date:       18/02/2017             --
--                                           --
--        F = MB*MC+MO*MT-e*MZ               --
-----------------------------------------------
with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Synchronous_Task_Control;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Synchronous_Task_Control;

procedure Lab1 is

	n: integer:=1000;
	p: integer:=2;
	h: integer:=n/p;
	
	type Vector is array (1..n) of integer;
	type Matrix is array (1..n) of Vector;
	
	MA, MB, MC, MO, MT, MZ: Matrix;
	e: integer;
	
	S1, S2, Su1, Su2, Su3: Suspension_Object;	

	procedure Output_Vector(A: in Vector) is
        begin
            for i in 1..N loop
                put(A(i));
            end loop;
            New_Line;
        end Output_Vector;

	procedure Output_Matrix(MA: in Matrix) is
        begin
			if n<10 then
            			for i in 1..N loop
              				Output_Vector(MA(i));
           			end loop;
			end if;
        end Output_Matrix;

	function mul(MA, MB: in Matrix; b,e: in integer) return Matrix is
		MC: Matrix;
	begin
		for i in b..e loop
    				for j in 1..n loop
					MC(i)(j):=0;
    					for k in 1..n loop
    					MC(i)(j):=MC(i)(j)+MA(i)(k)*MB(k)(j);
    					end loop;
    				end loop;
    			end loop;
    	return MC;
	end mul;
	
	function mul(MA: in Matrix; f,b,e: in integer) return Matrix is
		MC: Matrix;
	begin
		for i in b..e loop
    				for j in 1..n loop
    						MC(i)(j):=MA(i)(j)*f;
    				end loop;
    			end loop;
    	return MC;
	end mul;

	function add(MA,MB: in Matrix; b,e: in integer) return Matrix is
		MC: Matrix;
	begin
		for i in b..e loop
    				for j in 1..n loop
    						MC(i)(j):=MA(i)(j)+MB(i)(j);
    				end loop;
    			end loop;
    	return MC;
	end add;
	
	procedure sub(MA,MB: in Matrix; b,e: in integer; MC: in out Matrix)  is
	begin
		for i in b..e loop
    				for j in 1..n loop
    						MC(i)(j):=MA(i)(j)-MB(i)(j);
    				end loop;
    			end loop;
	end sub;
	
	procedure f(MA: in out Matrix; MB,MC,MO,MT,MZ: in Matrix; k,b,e:integer) is
	begin
    		sub(add(mul(MB,MC,b,e),mul(MO,MT,b,e),b,e),mul(MZ,k,b,e),b,e,MA);	
	end f;

	procedure start_tasks is
		
		task T1;
    
    		task T2;
    	
    		task body T1 is
    			MC1, MT1: Matrix;
    			e1: integer;
    		begin
    			put_line("T1 started");
    			
    			--input
    			e:=2;
    			for i in 1..n loop
    				for j in 1..n loop
    				MB(i)(j):=1;
    				MC(i)(j):=1;
    				MO(i)(j):=1;
    				MT(i)(j):=1;
    				MZ(i)(j):=1;
    				end loop;
    			end loop;
    			
    			--sending a signal to T2 
    			set_true(S1);
    			
    			--copy MC
    			suspend_until_true(Su1);
    			MC1:=MC;
    			set_true(Su1);
    			--copy MT
    			suspend_until_true(Su2);
    			MT1:=MT;
    			set_true(Su2);
    			--copy e
    			suspend_until_true(Su3);
    			e1:=e;
    			set_true(Su3);
    			
    			--account
    			f(MA,MB,MC1,MO,MT1,MZ,e,1,h);
    			
    			--waiting for signal from T2
    			suspend_until_true(S2);
    			
    			--output
    			Output_Matrix(MA);
			put_line("T1 finished");
    		end T1;
    		
    		task body T2 is
    			MC2, MT2: Matrix;
    			e2: integer;
    		begin
    			put_line("T2 started");
    			
    			--waiting for signal from T1
    			suspend_until_true(S1);
    			
    			--copy MC
    			suspend_until_true(Su1);
    			MC2:=MC;
    			set_true(Su1);
    			--copy MT
    			suspend_until_true(Su2);
    			MT2:=MT;
    			set_true(Su2);
    			--copy e
    			suspend_until_true(Su3);
    			e2:=e;
    			set_true(Su3);

    			--account
    			f(MA,MB,MC2,MO,MT2,MZ,e,h+1,n);
    			
    			--sending a signal to T1
    			set_true(S2);

    			put_line("T2 finished");
    		end T2;
    			

	begin
		put("");
	end start_tasks;
	
begin
	put_line("Program started");
	set_true(Su1);
	set_true(Su2);
	set_true(Su3);
	start_tasks;
	put_line("Program finished");
end Lab1;
