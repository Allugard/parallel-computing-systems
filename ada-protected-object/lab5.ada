with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Synchronous_Task_Control;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Synchronous_Task_Control;

procedure Lab1 is

	n: integer:=8;
	p: integer:=4;
	h: integer:=n/p;

	type Vector is array (1..n) of integer;
	type Matrix is array (1..n) of Vector;
	
	B,C,Z: Vector;
	MA, MT, MO: Matrix;
	
	
	
	procedure Vector_Input(A: in out Vector) is
    	begin
     		for i in 1..N loop
    	  	      	A(i) := 1;
      		end loop;
  	end Vector_Input;
  	
  	function Vector_Input return Vector is
  		A: Vector;
  	begin
  		for i in 1..N loop
  			A(i) := 1;
  		end loop;
  		return A;
  	end Vector_Input;

	
	function Matrix_Input return Matrix is
		MA: Matrix;
	begin
		for i in 1..N loop
			for j in 1..N loop
				MA(i)(j):=1;
			end loop;
		end loop;
		return MA;
	end Matrix_Input;
	
	
	procedure Matrix_Input(MA: in out Matrix) is
	begin
		for i in 1..N loop
	   		for j in 1..N loop
	  	          MA(i)(j) := 1;
	        end loop;
	 	end loop;
	 end Matrix_Input;

	
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

	procedure add(MA,MB: in Matrix; b,e: in integer; MC: in out Matrix) is
	begin
		for i in b..e loop
    				for j in 1..n loop
    						MC(i)(j):=MA(i)(j)+MB(i)(j);
    				end loop;
    			end loop;
	end add;

	function mul(B, C: in Vector; beg,e: in integer) return integer is
		d: integer:=0;
	begin
		for i in beg..e loop
			d:=d+B(i)*C(i);
		end loop;
		return d;
	end mul;
	
	function find_max(Z: in Vector; b,e: in integer) return integer is
		d: integer:=-32767;
	begin
		for i in b..e loop
			if d<Z(i) then
				d:=Z(i);
			end if;
		end loop;
		return d;
	end find_max;
	
	procedure f(MA: in out Matrix ;MO, MT, MR: in Matrix; d, e, z, beg, en: integer) is
	l:integer;
	begin
		l:=e*z;
		add(mul(MO,d,beg,en), mul(mul(MT,MR,beg,en),l,beg,en), beg, en, MA);
	end f;
	
	protected Synchronized_Object is
		
		entry wait_input;
		entry wait_max_mul;
		entry wait_output;
		procedure signal_input;
		procedure signal_max_mul;
		procedure signal_output;
		
		private
		F1: integer:=0;
		F2: integer:=0;
		F3: integer:=0;
	end Synchronized_Object;
	
	protected body Synchronized_Object is
		
		entry wait_input when F1=3 is
		begin
			null;
		end wait_input;
		
		entry wait_max_mul when F2=4 is
		begin
			null;
		end wait_max_mul;
		
		entry wait_output when F3=3 is
		begin
			null;
		end wait_output;
		
		procedure signal_input is
		begin
			F1:=F1+1;
		end signal_input;
		
		procedure signal_max_mul is
		begin
			F2:=F2+1;
		end signal_max_mul;
		
		procedure signal_output is
		begin
			F3:=F3+1;
		end signal_output;
	
	end Synchronized_Object;
	
	protected Mutual_Exclusion_Object is 
	
		procedure set_e;
		function copy_e return integer;
		procedure set_max_z(x: in integer);
		function copy_z return integer;
		procedure add_d(x: in integer);
		function copy_d return integer;
		procedure set_MR;
		function copy_MR return Matrix;
		
		private 
		e: integer;
		z: integer:=-32767;
		d: integer:=0;
		MR: Matrix;
		
	end Mutual_Exclusion_Object;
	
	protected body Mutual_Exclusion_Object is 
		procedure set_e is
		begin
			e:=1;
		end set_e;
		
		function copy_e return integer is
		begin
			return e;
		end copy_e;
		
		procedure set_max_z(x: in integer) is
		begin
			if z<x then
				z:=x;
			end if;
		end set_max_z;
		
		function copy_z return integer is
		begin
			return z;
		end copy_z;
		
		procedure add_d(x: in integer) is
		begin
			d:=d+x;
		end add_d;
		
		function copy_d return integer is
		begin
			return d;
		end copy_d;
		
		procedure set_MR is
		begin
		for i in 1..N loop
	   		for j in 1..N loop
	  	          MR(i)(j) := 1;
	        end loop;
	 	end loop;
		end set_MR;
		
		function copy_MR return Matrix is
		begin
			return MR;
		end copy_MR;
		
	end Mutual_Exclusion_Object;
	
	procedure start_tasks is
		Task T1;
		Task T2;
		Task T3;
		Task T4;
		
		Task body T1 is
			MR1: Matrix;
			d1,e1,z1: integer;
		begin
			Z:=Vector_Input;
			MT:=Matrix_Input;
			Synchronized_Object.signal_input;
			Synchronized_Object.wait_input;
			
			d1:=mul(B,C, 1, H);
			z1:=find_max(Z, 1, H);
			
			Mutual_Exclusion_Object.set_max_z(z1);
			Mutual_Exclusion_Object.add_d(d1);
			
			Synchronized_Object.signal_max_mul;
			Synchronized_Object.wait_max_mul;
			
			MR1:=Mutual_Exclusion_Object.copy_MR;
			d1:=Mutual_Exclusion_Object.copy_d;
			z1:=Mutual_Exclusion_Object.copy_z;
			e1:=Mutual_Exclusion_Object.copy_e;
			
			f(MA, MO, MT, MR1, d1, e1, z1, 1, H);
			
			Synchronized_Object.signal_output;
			
		end T1;

		Task body T2 is
			MR2: Matrix;
			d2,e2,z2: integer;
		begin
			Synchronized_Object.wait_input;
			
			d2:=mul(B,C, H+1, 2*H);
			z2:=find_max(Z, H+1, 2*H);
			
			Mutual_Exclusion_Object.set_max_z(z2);
			Mutual_Exclusion_Object.add_d(d2);
			
			Synchronized_Object.signal_max_mul;
			Synchronized_Object.wait_max_mul;
			
			MR2:=Mutual_Exclusion_Object.copy_MR;
			d2:=Mutual_Exclusion_Object.copy_d;
			z2:=Mutual_Exclusion_Object.copy_z;
			e2:=Mutual_Exclusion_Object.copy_e;
			
			f(MA, MO, MT, MR2, d2, e2, z2, H+1, 2*H);
			
			Synchronized_Object.signal_output;
			
		end T2;

		Task body T3 is
			MR3: Matrix;
			d3,e3,z3: integer;
		begin
			C:=Vector_Input;
			MO:=Matrix_Input;
			Synchronized_Object.signal_input;
			Synchronized_Object.wait_input;
			
			d3:=mul(B,C, 2*H+1, 3*H);
			z3:=find_max(Z, 2*H+1, 3*H);
			
			Mutual_Exclusion_Object.set_max_z(z3);
			Mutual_Exclusion_Object.add_d(d3);
			
			Synchronized_Object.signal_max_mul;
			Synchronized_Object.wait_max_mul;
			
			MR3:=Mutual_Exclusion_Object.copy_MR;
			d3:=Mutual_Exclusion_Object.copy_d;
			z3:=Mutual_Exclusion_Object.copy_z;
			e3:=Mutual_Exclusion_Object.copy_e;
			
			f(MA, MO, MT, MR3, d3, e3, z3, 2*H+1, 3*H);
			
			Synchronized_Object.signal_output;
			
		end T3;
		
		Task body T4 is
			MR4: Matrix;
			d4,e4,z4: integer;
		begin
			Mutual_Exclusion_Object.set_e;
			Mutual_Exclusion_Object.set_MR;
			B:=Vector_Input;
			Synchronized_Object.signal_input;
			Synchronized_Object.wait_input;
			
			d4:=mul(B,C, 3*H+1, 4*H);
			z4:=find_max(Z, 3*H+1, 4*H);
			
			Mutual_Exclusion_Object.set_max_z(z4);
			Mutual_Exclusion_Object.add_d(d4);
			
			Synchronized_Object.signal_max_mul;
			Synchronized_Object.wait_max_mul;
			
			MR4:=Mutual_Exclusion_Object.copy_MR;
			d4:=Mutual_Exclusion_Object.copy_d;
			z4:=Mutual_Exclusion_Object.copy_z;
			e4:=Mutual_Exclusion_Object.copy_e;
			
			
			f(MA, MO, MT, MR4, d4, e4, z4, 3*H+1, 4*H);
			
			Synchronized_Object.wait_output;
			Output_Matrix(MA);
			
		end T4;


	begin
		null;
	end start_tasks;


begin
	put_line("Program started");
	start_tasks;
	put_line("Program finished");
end Lab1;
