-----------------------------------------------
--              Assignment #7                --
--             Randewoo in Ada               --
--                                           --
--        Student:    Sergei Vasilenko       --
--        Group:      IO-42                  --
--        Date:       18/02/2017             --
--                                           --
--        A = d*B+min(Z)*C*(MO*MK)           --
-----------------------------------------------
with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;

procedure Lab7 is
	n: integer:=8;
	p: integer:=8;
	h: integer:=n/p;
	type Vector is array (integer range <>) of integer;
	subtype VectorH is Vector (1..H);
	subtype Vector2H is Vector (1..2*H);
	subtype Vector3H is Vector (1..3*H);
	subtype Vector4H is Vector (1..4*H);
	subtype Vector5H is Vector (1..5*H);
	subtype Vector6H is Vector (1..6*H);
	subtype Vector7H is Vector (1..7*H);
	subtype VectorN is Vector (1..N);
	
	type Matrix is array (integer range <>) of VectorN;
	subtype MatrixH is Matrix (1 .. H);
	subtype Matrix2H is Matrix (1 .. 2*H);
	subtype Matrix3H is Matrix (1 .. 3*H);
	subtype Matrix4H is Matrix (1 .. 4*H);
	subtype Matrix5H is Matrix (1 .. 5*H);
	subtype Matrix6H is Matrix (1 .. 6*H);
	subtype Matrix7H is Matrix (1 .. 7*H);
	subtype MatrixN is Matrix (1 .. N);
	

	
	
	procedure Vector_Input(A: in out Vector) is
    	begin
     		for i in 1..N loop
    	  	      	A(i) := 1;
      		end loop;
  	end Vector_Input;
  	
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

	function mul(MA : in MatrixH; MB: in MatrixN) return MatrixH is
		MC: MatrixH;
	begin
		for i in 1..H loop
    			for j in 1..n loop
				MC(i)(j):=0;
    				for k in 1..n loop
    					MC(i)(j):=MC(i)(j)+MA(i)(k)*MB(k)(j);
  				end loop;
    			end loop;
    	  	end loop;
    		return MC;
	end mul;
	
	function mul(MA: in MatrixH; B: in VectorN) return VectorH is
		C: VectorH;
	begin
		for i in 1..H loop
			C(i):=0;
    			for k in 1..n loop
    				C(i):=C(i)+MA(i)(k)*B(k);
  			end loop;
    	  	end loop;
    		return C;
	end mul;
	
	
	function mul(A: in VectorH; f: in integer) return VectorH is
		C: VectorH;
	begin
		for i in 1..H loop
    			C(i):=A(i)*f;
    		end loop;
    		return C;
	end mul;

	function add(A,B: in VectorH) return VectorH is
		C: VectorH;
	begin
		for i in 1..H loop
    			C(i):=A(i)+B(i);
    		end loop;
    		return C;
	end add;
	
	
	function find_min(Z: in Vector) return integer is
		d: integer:=32767;
	begin
		for i in 1..H loop
			if d>Z(i) then
				d:=Z(i);
			end if;
		end loop;
		return d;
	end find_min;
	
	function f(MO: in MatrixH; MK: in MatrixN; B: in VectorH; C: in VectorN; d,z: in integer) return VectorH is
		A, buf, bufB: VectorH;
		bufM:MatrixH;
	begin
		bufB:=mul(B,d);
		bufM:=mul(MO, MK);
		buf:=mul(bufM, C);
		buf:=mul(buf, z);
		A:=add(bufB, buf);
    		--A:=add(mul(B, d), mul(mul(mul(MO, MK), C),z));
    		return A;	
	end f;

	procedure start_tasks is
		
		task T1 is
			entry recv_min_z(z: in integer);
			entry recv_from_t2(MO: in MatrixH; MK: in MatrixN; B: in VectorH; C: in VectorN);
		end T1;
    
    		task T2 is
    			entry recv_vec_z(VZ: in Vector7H);
    			entry recv_min_z(z: in integer);
    			entry recv_from_t1(d,z: in integer);
    			entry recv_from_t3(MK: in MatrixN; B: in Vector6H);
    			entry recv_send_t4(MO: in Matrix4H; MK: out MatrixN; B: out Vector4H;C: in VectorN; d,z: out integer);
    			entry recv_res_t1(A: in VectorH);
    			entry recv_res_t4(A: in Vector4H);    			
    		end T2;
    		
    		task T3 is
    			entry recv_vec_z(VZ: in Vector2H);
    			entry recv_min_z(z: in integer);
    			entry recv_from_t8(MK: in MatrixN; B: in Vector7H);
    			entry recv_from_t2(MO: in Matrix2H; C: in VectorN; d,z: in integer);
    			entry recv_res_t2(A: in Vector6H);
		end T3;
    
    		task T4 is
    			entry recv_vec_z(VZ: in Vector4H);
    			entry recv_min_z(z: in integer);
    			entry recv_from_t5(MO: in Matrix5H; C: in VectorN);
    			entry recv_res_t5(A: in Vector3H);
    		end T4;
    		
    		task T5 is
    			entry recv_vec_z(VZ: in Vector3H);
    			entry recv_min_z(z: in integer);
    			entry recv_from_t6(MO: in Matrix7H; C: in VectorN);
    			entry recv_from_t4(MK: in MatrixN; B: in Vector3H; d,z: in integer);
    			entry recv_res_t6(A: in VectorH);
    			entry recv_res_t7(A: in VectorH);
		end T5;
    
    		task T6 is
    			entry recv_vec_z(VZ: in VectorH);
    			entry recv_from_t5(MK: in MatrixN; B: in VectorH; d,z: in integer);
    		end T6;
    		
    		task T7 is
    			entry recv_vec_z(VZ: in VectorH);
    			entry recv_from_t5(MO: in MatrixH;MK: in MatrixN; B: in VectorH; C: in VectorN; d,z: in integer);
		end T7;
    
    		task T8 is
    			entry recv_vec_z(VZ: in VectorH);
    			entry recv_from_t3(MO: in MatrixH; C: in VectorN; d,z: in integer);
    			entry recv_res_t3(A: in Vector7H);
    		end T8;
    		
    		
    		
    		
    	
    		task body T1 is
    			Z, C1: VectorN;
    			B1, A1:VectorH;
    			MO1: MatrixH;
    			MK1: MatrixN; 
    			z1, d1: integer;
    		begin
    			put_line("T1 started");
    			
    			Vector_Input(Z);
    			d1:=1;
    			
    			T2.recv_vec_z(Z(H+1 .. N));
    			
    			z1:=find_min(Z);
    			
    			accept recv_min_z(z: in integer) do
    				if z<z1 then
    					z1:=z;
    				end if;
    			end recv_min_z; 
    			
    			T2.recv_from_t1(d1, z1);
    			
    			accept recv_from_t2(MO: in MatrixH; MK: in MatrixN; B: in VectorH; C: in VectorN) do
    				MO1(1 .. H) := MO;
    				MK1(1.. N) := MK;
    				B1(1 .. H) := B;
    				C1(1 .. N) := C;
    			end recv_from_t2;
    			
    			A1:=f(MO1, MK1, B1, C1, d1, z1);
    			
    			T2.recv_res_t1(A1(1..H));

			put_line("T1 finished");
    		end T1;
    		
    		task body T2 is
    			Z: Vector7H;
    			z2, d2: integer;
    			MK2: MatrixN;
    			MO2: Matrix4H;
    			C2: VectorN;
    			B2, A2: Vector6H;
    		begin
    			put_line("T2 started");
    			
    			accept recv_vec_z(VZ: in Vector7H) do
    				Z(1 .. 7*H):=VZ;
    			end recv_vec_z;
    			
    			T4.recv_vec_z(Z(H+1 .. 5*H));
    			T3.recv_vec_z(Z(5*H+1 .. 7*H));
    			
    			z2:=find_min(Z);
    			
    			accept recv_min_z(z: in integer) do
    				  if z<z2 then
    				  	z2:=z;
    				  end if;
    			end recv_min_z; 
    			
    			accept recv_min_z(z: in integer) do
    				  if z<z2 then
    				  	z2:=z;
    				  end if;
    			end recv_min_z; 
    			
    			T1.recv_min_z(z2);
    			
    			accept recv_from_t1(d,z: in integer) do
    				z2:=z;
    				d2:=d;
    			end recv_from_t1;   
    			

    			
    			accept recv_from_t3(MK: in MatrixN; B: in Vector6H) do
    				MK2(1 .. N):=MK;
    				B2(1 .. 6*H):=B;
    			end recv_from_t3;
    			
    			
    			accept recv_send_t4(MO: in Matrix4H; MK: out MatrixN; B: out Vector4H;C: in VectorN; d,z: out integer) do
    				MO2(1 .. 4*H):=MO;
    				MK:=MK2(1 .. N);
    				B:=B2(2*H+1 .. 6*H);
    				C2(1 .. N):=C;
    				d:=d2;
    				z:=z2;
    			end recv_send_t4;
    			

    			
    			T3.recv_from_t2(MO2(1 .. 2*H), C2(1 .. N), d2, z2);
    			T1.recv_from_t2(MO2(3*H+1 .. 4*H),MK2(1 .. N), B2(H+1 .. 2*H), C2(1 .. N));
    			
    			A2(1 .. H):=f(MO2(2*H+1 .. 3*H), MK2, B2(1 .. H), C2, d2, z2);
    			
    			accept recv_res_t1(A: in VectorH) do
    				A2(H+1 .. 2*H):=A;
    			end recv_res_t1;
    			
    			accept recv_res_t4(A: in Vector4H) do
    				A2(2*H+1 .. 6*H):=A;
    			end recv_res_t4;
    			
    			T3.recv_res_t2(A2(1..6*H));
    			
    			put_line("T2 finished");
    		end T2;
    		
    		task body T3 is
    			Z,B3, A3: Vector7H;
    			z3, d3: integer;
    			MK3: MatrixN;
    			MO3: Matrix2H;
    			C3: VectorN;
    		begin
    			put_line("T3 started");
    			
    			accept recv_vec_z(VZ: in Vector2H) do
    				Z(1 .. 2*H):=VZ;
    			end recv_vec_z;
    			
    			T8.recv_vec_z(Z(H+1 .. 2*H));
    			
    			z3:=find_min(Z); 
    			
    			accept recv_min_z(z: in integer) do
    				  if z<z3 then
    				  	z3:=z;
    				  end if;
    			end recv_min_z; 
    			
    			T2.recv_min_z(z3);

    			accept recv_from_t8(MK: in MatrixN; B: in Vector7H) do
    			
    				MK3(1 .. N):=MK;
    				B3(1 .. 7*H):=B;
    			end recv_from_t8;
    			
    			T2.recv_from_t3(MK3(1 .. N), B3(H+1 .. 7*H));
    			
    			accept recv_from_t2(MO: in Matrix2H; C: in VectorN; d,z: in integer) do
    				MO3(1 .. 2*H):=MO;
    				C3(1 .. N):=C;
    				d3:=d;
    				z3:=z;
    			end recv_from_t2;
    			
    			T8.recv_from_t3(MO3(1 .. H), C3(1 .. N), d3, z3); 
    			
    			A3(1 .. H):=f(MO3(H+1 .. 2*H), MK3, B3(1 .. H), C3, d3, z3);
    			
    			accept recv_res_t2(A: in Vector6H) do
    				A3(H+1 .. 7*H):=A;
    			end recv_res_t2;
    			
    			T8.recv_res_t3(A3(1 .. 7*H));

    			put_line("T3 finished");
    		end T3;
    		
    		task body T4 is
    			Z, B4, A4: Vector4H;
    			MO4: Matrix5H;
    			MK4:MatrixN;
    			C4: VectorN;
    			z4, d4: integer;
    		begin
    			put_line("T4 started");
    			
    			accept recv_vec_z(VZ: in Vector4H) do
    				Z(1 .. 4*H):=VZ;
    			end recv_vec_z;
    			
    			T5.recv_vec_z(Z(H+1 .. 4*H));
    			
    			z4:=find_min(Z); 
    			
    			accept recv_min_z(z: in integer) do
    				  if z<z4 then
    				  	z4:=z;
    				  end if;
    			end recv_min_z; 
    			
    			T2.recv_min_z(z4);
    			
    			accept recv_from_t5(MO: in Matrix5H; C: in VectorN) do
    				MO4(1 .. 5*H):=MO;
    				C4(1 .. N):=C;
    			end recv_from_t5;
    			
    			T2.recv_send_t4(MO4(1 .. 4*H), MK4, B4, C4(1 .. N), d4, z4);
    			
    			T5.recv_from_t4(MK4, B4(H+1 .. 4*H), d4, z4);

    			A4(1 .. H):=f(MO4(4*H+1 .. 5*H), MK4, B4(1 .. H), C4, d4, z4);
    			
    			accept recv_res_t5(A: in Vector3H) do
    				A4(H+1 .. 4*H):=A;
    			end recv_res_t5;
    			
    			T2.recv_res_t4(A4(1 .. 4*H));
    		
    			put_line("T4 finished");
    		end T4;    
    		
    		task body T5 is
    			Z, B5, A5: Vector3H;
    			z5, d5: integer;
    			MO5: Matrix7H;
    			C5: VectorN;
    			MK5: MatrixN;
    		begin
    			put_line("T5 started");
    			
    			accept recv_vec_z(VZ: in Vector3H) do
    				Z(1 .. 3*H):=VZ;
    			end recv_vec_z;
    			
    			T6.recv_vec_z(Z(H+1 .. 2*H));
    			T7.recv_vec_z(Z(2*H+1 .. 3*H));
    			
    			z5:=find_min(Z);
    			
    			accept recv_min_z(z: in integer) do
    				  if z<z5 then
    				  	z5:=z;
    				  end if;
    			end recv_min_z; 
    			
    			accept recv_min_z(z: in integer) do
    				  if z<z5 then
    				  	z5:=z;
    				  end if;
    			end recv_min_z; 
    			
    			T4.recv_min_z(z5);
    			
    			accept recv_from_t6(MO: in Matrix7H; C: in VectorN) do
    				MO5(1 .. 7*H):=MO;
    				C5(1 .. N):=C;
    			end recv_from_t6;
    			
    			T4.recv_from_t5(MO5(1 .. 5*H), C5(1 .. N));
    			       	
    			accept recv_from_t4(MK: in MatrixN; B: in Vector3H; d,z: in integer) do
    				MK5(1 .. N):=MK;
    				B5(1 .. 3*H):=B;
    				d5:=d;
    				z5:=z;
    			end recv_from_t4;
    			
    			T7.recv_from_t5(MO5(6*H+1 .. 7*H), MK5, B5(H+1 .. 2*H), C5(1 .. N), d5, z5);
    			T6.recv_from_t5(MK5, B5(2*H+1 .. 3*H), d5, z5);
    			
    			A5(1 .. H):=f(MO5(5*H+1 .. 6*H), MK5, B5(1 .. H), C5, d5, z5);
    			
    			accept recv_res_t6(A: in VectorH) do
    				A5(2*H+1 .. 3*H):=A;
    			end recv_res_t6;
    			
    			accept recv_res_t7(A: in VectorH) do
    				A5(H+1 .. 2*H):=A;
    			end recv_res_t7;
    			
    			T4.recv_res_t5(A5(1 .. 3*H));
    			
    			put_line("T5 finished");
    		end T5;
    		
    		task body T6 is
    			Z, B6, A6: VectorH;
    			C6: VectorN;
    			MK6: MatrixN;
    			MO6: MatrixN;
    			z6, d6: integer;
    		begin
    			put_line("T6 started");
    			
    			Vector_Input(C6);
    			Matrix_Input(MO6);
    			
    			accept recv_vec_z(VZ: in VectorH) do
    				Z(1..H):=VZ;
    			end recv_vec_z;
    			
    			z6:=find_min(Z); 

    			T5.recv_min_z(z6);
    			
    			T5.recv_from_t6(MO6(1 .. 7*H), C6(1 .. N));
    			
    			accept recv_from_t5(MK: in MatrixN; B: in VectorH; d,z: in integer) do
    				MK6(1 .. N):=MK;
    				B6(1 .. H):=B;
    				d6:=d;
    				z6:=z;
    			end recv_from_t5;
    			
    			A6(1 .. H):=f(MO6(7*H+1 .. N), MK6, B6(1 .. H), C6, d6, z6);
    			
    			T5.recv_res_t6(A6(1 .. H));
    			
    			put_line("T6 finished");
    		end T6;	
    		
    		task body T7 is
    			Z, B7, A7: VectorH;
    			C7: VectorN;
    			MK7: MatrixN;
    			MO7: MatrixH;
    			z7, d7: integer;
    		begin
    			put_line("T7 started");
    			
    			accept recv_vec_z(VZ: in VectorH) do
    				Z(1..H):=VZ;
    			end recv_vec_z;
    			
    			z7:=find_min(Z); 
    	
    			T5.recv_min_z(z7);
    			
    			accept recv_from_t5(MO: in MatrixH;MK: in MatrixN; B: in VectorH; C: in VectorN; d,z: in integer) do
    				MO7(1 .. H):=MO;
    				MK7(1 .. N):=MK;
    				B7(1 .. H):=B;
    				C7(1 .. n):=C;
    				d7:=d;
    				z7:=z;	
    			end recv_from_t5;
    			
    			A7(1 .. H):=f(MO7(1 .. H), MK7, B7(1 .. H), C7, d7, z7);
    			
    			T5.recv_res_t7(A7(1 .. H));

    			put_line("T7 finished");
    		end T7;	
    		
    		task body T8 is
    			Z: VectorH;
    			C8, A8: VectorN;
    			B8:VectorN;
    			MO8: MatrixH;
    			MK8: MatrixN;
    			z8, d8: integer;
    		begin
    			put_line("T8 started");
 
    			Vector_Input(B8);
    			B8(8):=9;
    			Matrix_Input(MK8);
    			   			
    			accept recv_vec_z(VZ: in VectorH) do
    				Z(1..H):=VZ;
    			end recv_vec_z;
    			
    			z8:=find_min(Z); 

    			T3.recv_min_z(z8);
    			
    			    			
    			
    			T3.recv_from_t8(MK8(1 .. N), B8(H+1 .. N));
    			
    			accept recv_from_t3(MO: in MatrixH; C: in VectorN; d,z: in integer) do
    				MO8(1 .. H):=MO;
    				C8(1 .. N):=C;
    				d8:=d;
    				z8:=z;
    			end recv_from_t3;
    			
    			A8(1 .. H):=f(MO8(1 .. H), MK8, B8(1 .. H), C8, d8, z8);
    			
    			accept recv_res_t3(A: in Vector7H) do
    				A8(H+1 .. N):=A;
    			end recv_res_t3;
    			
    			Output_Vector(A8);
    			
    			put_line("T8 finished");
    		end T8;		
    			

	begin
		null;
	end start_tasks;
	
begin
	put_line("Program started");
	start_tasks;
	put_line("Program finished");
end Lab7;
