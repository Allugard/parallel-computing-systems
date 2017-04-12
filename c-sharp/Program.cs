using System;
using System.Collections.Generic;
using System.Threading;

namespace c_sharp
{
    internal class Program
    {

        private static int N = 5000;
        private static int P = 6;
        private static int H = N / P;

        private static int[,] MA = new int[N, N];
        private static int[,] MZ = new int[N, N];
        private static int[,] MO = new int[N, N];
        private static int[,] MT = new int[N, N];
        private static int[,] MR = new int[N, N];

        private static int z = int.MinValue;
        private static int d;

        private static EventWaitHandle E1in=new ManualResetEvent(false);
        private static EventWaitHandle E3in=new ManualResetEvent(false);
        private static EventWaitHandle E4in=new ManualResetEvent(false);

        private static EventWaitHandle[] inputEvents = {E1in, E3in, E4in};

        private static EventWaitHandle E2out=new AutoResetEvent(false);
        private static EventWaitHandle E3out=new AutoResetEvent(false);
        private static EventWaitHandle E4out=new AutoResetEvent(false);
        private static EventWaitHandle E5out=new AutoResetEvent(false);
        private static EventWaitHandle E6out=new AutoResetEvent(false);

        private static EventWaitHandle[] outputEvents = {E2out,E3out,E4out,E5out,E6out};

        private static Semaphore S1 = new Semaphore(0,6);
        private static Semaphore S2 = new Semaphore(0,6);
        private static Semaphore S3 = new Semaphore(0,6);
        private static Semaphore S4 = new Semaphore(0,6);
        private static Semaphore S5 = new Semaphore(0,6);
        private static Semaphore S6 = new Semaphore(0,6);

        public static Semaphore[] semaphores = {S1,S2,S3,S4,S5,S6};

        public static Mutex mutex = new Mutex(false);

        private static object section = new object();

        static void inputMatrix (int [,] matrix){
            for (int i = 0; i <N; ++i) {
                for (int j = 0; j <N; ++j) {
                    matrix [i,j]=1;
                }
            }
        }

        static void outputMatrix (int [,] matrix){
            if(N<10)
                for (int i = 0; i <N; ++i) {
                    for (int j = 0; j <N; ++j) {
                        Console.Write(matrix[i,j]+" ");
                    }
                    Console.WriteLine();
                }
        }

        static void mulMatrXNumber(int z, int [,] Matr, int begin, int end){
            for (int i = begin; i <end; ++i) {
                for (int j = 0; j <N; ++j) {
                    Matr[i,j]=Matr[i,j]*z;
                }
            }
        }

        static void mulMatrXMatr(int [,] M1, int [,] M2, int begin, int end) {
            int [,]m=new int[N,N];
            for (int i = begin; i <end; ++i) {
                for (int j = 0; j <N; ++j) {
                    m[i,j]=0;
                    for (int k = 0; k <N; ++k) {
                        m[i,j]=m[i,j]+M1[i,k]*M2[k,j];
                    }
                }
                for (int l = 0; l <N; ++l) {
                    M1[i,l]=m[i,l];
                }
            }
        }

        static void add(int [,] M1,int [,] M2,int begin,int end,int [,] MA){
            for (int i = begin; i <end; ++i) {
                for (int j = 0; j <N; ++j) {
                    MA[i,j]=M1[i,j]+M2[i,j];
                }
            }
        }

        static int findMax(int [,] Matr,int begin, int end){
            int z=int.MinValue;
            for (int i = begin; i <end; ++i) {
                for (int j = 0; j <N; ++j) {
                    if(z<Matr[i,j]){
                        z=Matr[i,j];
                    }
                }
            }
            return z;
        }

        static void function(int [,] MA, int [,] MO, int z, int d, int [,] MT, int [,] MR, int begin, int end){
            mulMatrXNumber(z,MO,begin,end);
            mulMatrXMatr(MT,MR,begin,end);
            mulMatrXNumber(d,MT,begin,end);
            add(MO,MT,begin,end,MA);
        }

        static void T1()
        {
            Console.WriteLine("Task 1 started");
//    input
            inputMatrix(MZ);
            MZ[1,0]=5;
//    sending a signal to T2,T3,T4,T5,T6
            E1in.Set();
//    waiting for signal from T3,T4
            EventWaitHandle.WaitAll(inputEvents);
//  z1=MAX(MZh)
            int z1=findMax(MZ,0,H);
//  z=MAX(z,z1)
            mutex.WaitOne();
            if(z<z1) z=z1;
            mutex.ReleaseMutex();
//  sending a signal to T2,T3,T4,T5,T6
            S1.Release(6);
//    waiting for signal from T2,T3,T4.T5.T6
            Semaphore.WaitAll(semaphores);
//  copy z
            mutex.WaitOne();
            z1=z;
            mutex.ReleaseMutex();

            int [,] MR1=new int[N,N];
            int d1;
//  copy d, MR
            lock (section)
            {
                d1=d;
                MR1 = MR;
            }
//  account
            function(MA,MO,z1,d1,MT,MR1,0,H);
//  waiting for signal from T2,T3,T4,T5,T6
            EventWaitHandle.WaitAll(outputEvents);
//  output
            outputMatrix(MA);
            Console.WriteLine("Task 1 finished");
        }

        static void T2()
        {
            Console.WriteLine("Task 2 started");

//    waiting for signal from T1,T3,T4
            EventWaitHandle.WaitAll(inputEvents);
//  z2=MAX(MZh)
            int z2=findMax(MZ,H,2*H);
//  z=MAX(z,z2)
            mutex.WaitOne();
            if(z<z2) z=z2;
            mutex.ReleaseMutex();
//  sending a signal to T2,T3,T4
            S2.Release(6);
//    waiting for signal from T2,T3,T4,T5,T6
            Semaphore.WaitAll(semaphores);
//  copy z
            mutex.WaitOne();
            z2=z;
            mutex.ReleaseMutex();

            int [,] MR2=new int[N,N];
            int d2;
//  copy d, MR
            lock (section)
            {
                d2=d;
                MR2 = MR;
            }
//  account
            function(MA,MO,z2,d2,MT,MR2,H,2*H);
//    sending a signal to T1
            E2out.Set();
            Console.WriteLine("Task 2 finished");
        }

        static void T3()
        {
            Console.WriteLine("Task 3 started");
//    input
            inputMatrix(MO);
            inputMatrix(MR);
//    sending a signal to T1,T2,T4,T5,T6
            E3in.Set();
//    waiting for signal from T1,T4
            EventWaitHandle.WaitAll(inputEvents);
//  z3=MAX(MZh)
            int z3=findMax(MZ,2*H,3*H);
//  z=MAX(z,z3)
            mutex.WaitOne();
            if(z<z3) z=z3;
            mutex.ReleaseMutex();
//  sending a signal to T2,T3,T4,T5,T6
            S3.Release(6);
//    waiting for signal from T2,T3,T4,T5,T6
            Semaphore.WaitAll(semaphores);
//  copy z
            mutex.WaitOne();
            z3=z;
            mutex.ReleaseMutex();

            int [,] MR3=new int[N,N];
            int d3;
//  copy d, MR
            lock (section)
            {
                d3=d;
                MR3 = MR;
            }
//  account
            function(MA,MO,z3,d3,MT,MR3,2*H,3*H);
//    sending a signal to T1
            E3out.Set();
            Console.WriteLine("Task 3 finished");
        }

        static void T4()
        {
            Console.WriteLine("Task 4 started");
//    input
            inputMatrix(MT);
            d = 1;
//    sending a signal to T1,T2,T4,T5,T6
            E4in.Set();
//    waiting for signal from T1,T3
            EventWaitHandle.WaitAll(inputEvents);
//  z4=MAX(MZh)
            int z4=findMax(MZ,3*H,4*H);
//  z=MAX(z,z1)
            mutex.WaitOne();
            if(z<z4) z=z4;
            mutex.ReleaseMutex();
//  sending a signal to T2,T3,T4
            S4.Release(6);
//    waiting for signal from T2,T3,T4
            Semaphore.WaitAll(semaphores);
//  copy z
            mutex.WaitOne();
            z4=z;
            mutex.ReleaseMutex();

            int [,] MR4=new int[N,N];
            int d4;
//  copy d, MR
            lock (section)
            {
                d4=d;
                MR4 = MR;
            }
//  account
            function(MA,MO,z4,d4,MT,MR4,3*H,4*H);
//    sending a signal to T1
            E4out.Set();
            Console.WriteLine("Task 4 finished");
        }

        static void T5()
        {
            Console.WriteLine("Task 5 started");

//    waiting for signal from T1,T3,T4
            EventWaitHandle.WaitAll(inputEvents);
//  z5=MAX(MZh)
            int z5=findMax(MZ,4*H,5*H);
//  z=MAX(z,z5)
            mutex.WaitOne();
            if(z<z5) z=z5;
            mutex.ReleaseMutex();
//  sending a signal to T2,T3,T4
            S5.Release(6);
//    waiting for signal from T2,T3,T4,T5,T6
            Semaphore.WaitAll(semaphores);
//  copy z
            mutex.WaitOne();
            z5=z;
            mutex.ReleaseMutex();

            int [,] MR5=new int[N,N];
            int d5;
//  copy d, MR
            lock (section)
            {
                d5=d;
                MR5 = MR;
            }
//  account
            function(MA,MO,z5,d5,MT,MR5,4*H,5*H);
//    sending a signal to T1
            E5out.Set();
            Console.WriteLine("Task 5 finished");
        }

        static void T6()
        {
            Console.WriteLine("Task 6 started");

//    waiting for signal from T1,T3,T4
            EventWaitHandle.WaitAll(inputEvents);
//  z6=MAX(MZh)
            int z6=findMax(MZ,5*H,6*H);
//  z=MAX(z,z6)
            mutex.WaitOne();
            if(z<z6) z=z6;
            mutex.ReleaseMutex();
//  sending a signal to T2,T3,T4
            S6.Release(6);
//    waiting for signal from T2,T3,T4,T5,T6
            Semaphore.WaitAll(semaphores);
//  copy z
            mutex.WaitOne();
            z6=z;
            mutex.ReleaseMutex();

            int [,] MR6=new int[N,N];
            int d6;
//  copy d, MR
            lock (section)
            {
                d6=d;
                MR6 = MR;
            }
//  account
            function(MA,MO,z6,d6,MT,MR6,5*H,6*H);
//    sending a signal to T1
            E6out.Set();
            Console.WriteLine("Task 6 finished");
        }


        public static void Main(string[] args)
        {
            Console.WriteLine("Program started");

            Thread t1 = new Thread(T1);
            Thread t2 = new Thread(T2);
            Thread t3 = new Thread(T3);
            Thread t4 = new Thread(T4);
            Thread t5 = new Thread(T5);
            Thread t6 = new Thread(T6);

            t1.Start();
            t2.Start();
            t3.Start();
            t4.Start();
            t5.Start();
            t6.Start();

            t1.Join();
            Console.WriteLine("Program finished");

        }
    }
}

