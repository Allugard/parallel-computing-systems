#include <iostream>
#include "windows.h"

using std::cout;
using std::endl;

const int n=4;
const int p=4;
const int h=n/p;

int MA [n][n];
int MZ [n][n];
int MO [n][n];
int MT [n][n];
int MR [n][n];
int d;
int z=INT_MIN;

HANDLE S1=CreateSemaphore(NULL,0,3,NULL);
HANDLE S2=CreateSemaphore(NULL,0,3,NULL);
HANDLE S3=CreateSemaphore(NULL,0,3,NULL);
HANDLE S4=CreateSemaphore(NULL,0,3,NULL);

HANDLE M1=CreateMutex(NULL,FALSE,NULL);

CRITICAL_SECTION section;

HANDLE E1in=CreateEvent(NULL, true, false, NULL);
HANDLE E3in=CreateEvent(NULL, true, false, NULL);
HANDLE E4in=CreateEvent(NULL, true, false, NULL);

HANDLE E2out=CreateEvent(NULL, false, false, NULL);
HANDLE E3out=CreateEvent(NULL, false, false, NULL);
HANDLE E4out=CreateEvent(NULL, false, false, NULL);

HANDLE inputEvents [3]={E1in, E3in, E4in};
HANDLE outputEvents [3]={E2out, E3out, E4out};

void inputMatrix (int matrix[n][n]){
    for (int i = 0; i <n; ++i) {
        for (int j = 0; j <n; ++j) {
            matrix [i][j]=1;
        }
    }
}

void outputMatrix (int matrix[n][n]){
    if(n<10)
    for (int i = 0; i <n; ++i) {
        for (int j = 0; j <n; ++j) {
            cout<<matrix[i][j]<<" ";
        }
        cout<<endl;
    }
}

void mulMatrXNumber(int z, int Matr[n][n], int begin, int end){
    for (int i = begin; i <end; ++i) {
        for (int j = 0; j <n; ++j) {
            Matr[i][j]=Matr[i][j]*z;
        }
    }
}

void mulMatrXMatr(int M1[n][n], int M2[n][n], int begin, int end) {
    int m[n][n];
    for (int i = begin; i <end; ++i) {
        for (int j = 0; j <n; ++j) {
            m[i][j]=0;
            for (int k = 0; k <n; ++k) {
                m[i][j]=m[i][j]+M1[i][k]*M2[k][j];
            }
        }
        for (int l = 0; l <n; ++l) {
            M1[i][l]=m[i][l];
        }
    }
}

void add(int M1[n][n],int M2[h][n],int begin,int end,int MA[n][n]){
    for (int i = begin; i <end; ++i) {
        for (int j = 0; j <n; ++j) {
            MA[i][j]=M1[i][j]+M2[i][j];
        }
    }
}

int findMax(int Matr[n][n],int begin, int end){
    int z=INT_MIN;
    for (int i = begin; i <end; ++i) {
        for (int j = 0; j <n; ++j) {
            if(z<Matr[i][j]){
                z=Matr[i][j];
            }
        }
    }
    return z;
}

void function(int MA[n][n], int MO [n][n], int z, int d, int MT[n][n], int MR[n][n], int begin, int end){
    mulMatrXNumber(z,MO,begin,end);
    mulMatrXMatr(MT,MR,begin,end);
    mulMatrXNumber(d,MT,begin,end);
    add(MO,MT,begin,end,MA);
}

void task1 (){
    cout << "Task 1 started"<<endl;
//    input
    inputMatrix(MZ);
    MZ[1][0]=5;
//    sending a signal to T2,T3,T4
    SetEvent(E1in);
//    waiting for signal from T3,T4
    WaitForMultipleObjects(3, inputEvents,true,INFINITE );
//  z1=MAX(MZh)
    int z1=findMax(MZ,0,h);
//  z=MAX(z,z1)
    WaitForSingleObject(M1,INFINITE);
    if(z<z1) z=z1;
    ReleaseMutex(M1);
//  sending a signal to T2,T3,T4
    ReleaseSemaphore(S1,3,NULL);
//    waiting for signal from T2,T3,T4
    WaitForSingleObject(S2,INFINITE);
    WaitForSingleObject(S3,INFINITE);
    WaitForSingleObject(S4,INFINITE);
//  copy z
    WaitForSingleObject(M1,INFINITE);
    z1=z;
    ReleaseMutex(M1);

    int MR1[n][n];
    int d1;
//  copy d, MR
    EnterCriticalSection(&section);
    d1=d;
    memcpy(MR1,MR, sizeof(MR));
    LeaveCriticalSection(&section);
//  account
    function(MA,MO,z1,d1,MT,MR1,0,h);
//  waiting for signal from T2,T3,T4
    WaitForMultipleObjects(3,outputEvents,true,INFINITE);
//  output
    outputMatrix(MA);

    cout << "Task 1 finished"<<endl;

}

void task2 (){
    cout << "Task 2 started"<<endl;
//    waiting for signal from T1,T3,T4
    WaitForMultipleObjects(3, inputEvents,true,INFINITE );
//  z2=MAX(MZh)
    int z2=findMax(MZ,h,2*h);
//  z=MAX(z,z2)
    WaitForSingleObject(M1,INFINITE);
    if(z<z2) z=z2;
    ReleaseMutex(M1);
//  sending a signal to T1,T3,T4
    ReleaseSemaphore(S2,3,NULL);
//    waiting for signal from T1,T3,T4
    WaitForSingleObject(S1,INFINITE);
    WaitForSingleObject(S3,INFINITE);
    WaitForSingleObject(S4,INFINITE);
//      copy z
    WaitForSingleObject(M1,INFINITE);
    z2=z;
    ReleaseMutex(M1);

    int MR2[n][n];
    int d2;
//    copy d, MR
    EnterCriticalSection(&section);
    d2=d;
    memcpy(MR2,MR, sizeof(MR));
    LeaveCriticalSection(&section);
//    account
    function(MA,MO,z2,d2,MT,MR2,h,2*h);
//    sending a signal to T1
    SetEvent(E2out);

    cout << "Task 2 finished"<<endl;
}

void task3 (){
    cout << "Task 3 started"<<endl;
//    input
    inputMatrix(MO);
    inputMatrix(MR);
//    sending a signal to T1,T2,T4
    SetEvent(E3in);
//    waiting signal from T1,T4
    WaitForMultipleObjects(3, inputEvents,true,INFINITE );
//    z3=max(MZh)
    int z3=findMax(MZ,2*h,3*h);
//    z=max(z,z3)
    WaitForSingleObject(M1,INFINITE);
    if(z<z3) z=z3;
    ReleaseMutex(M1);
//    sending a signal to T1,T2,T4
    ReleaseSemaphore(S3,3,NULL);
//    waiting signal from T1,T2,T4
    WaitForSingleObject(S2,INFINITE);
    WaitForSingleObject(S1,INFINITE);
    WaitForSingleObject(S4,INFINITE);
//    copy z
    WaitForSingleObject(M1,INFINITE);
    z3=z;
    ReleaseMutex(M1);

    int MR3[n][n];
    int d3;
//    copy d,MR
    EnterCriticalSection(&section);
    d3=d;
    memcpy(MR3,MR, sizeof(MR));
    LeaveCriticalSection(&section);
//    account
    function(MA,MO,z3,d3,MT,MR3,2*h,3*h);
//    sending a signal to T1
    SetEvent(E3out);

    cout << "Task 3 finished"<<endl;
}

void task4 (){
    cout << "Task 4 started"<<endl;
//    input
    inputMatrix(MT);
    d=2;
//    sending a signal to T1,T2,T3
    SetEvent(E4in);
//    waiting for signal from T1,T3
    WaitForMultipleObjects(3, inputEvents,true,INFINITE );
//    z4=max(MZh)
    int z4=findMax(MZ,3*h,4*h);
//    z=max(z,z4)
    WaitForSingleObject(M1,INFINITE);
    if(z<z4) z=z4;
    ReleaseMutex(M1);
//    sending a signal to T1,T2,T3
    ReleaseSemaphore(S4,3,NULL);
//    waiting for signal from T1,T2,T3
    WaitForSingleObject(S2,INFINITE);
    WaitForSingleObject(S3,INFINITE);
    WaitForSingleObject(S1,INFINITE);
//    copy z
    WaitForSingleObject(M1,INFINITE);
    z4=z;
    ReleaseMutex(M1);

    int MR4[n][n];
    int d4;
//    copy MR, D
    EnterCriticalSection(&section);
    d4=d;
    memcpy(MR4,MR, sizeof(MR));
    LeaveCriticalSection(&section);
//    account
    function(MA,MO,z4,d4,MT,MR4,3*h,4*h);
//    sending a signal to T1
    SetEvent(E4out);

    cout << "Task 4 finished"<<endl;
}

int main() {
    cout << "Program started" << endl;

    HANDLE T1 = CreateThread(NULL, NULL, (LPTHREAD_START_ROUTINE) task1, NULL, CREATE_SUSPENDED, NULL);
    HANDLE T2 = CreateThread(NULL, NULL, (LPTHREAD_START_ROUTINE) task2, NULL, CREATE_SUSPENDED, NULL);
    HANDLE T3 = CreateThread(NULL, NULL, (LPTHREAD_START_ROUTINE) task3, NULL, CREATE_SUSPENDED, NULL);
    HANDLE T4 = CreateThread(NULL, NULL, (LPTHREAD_START_ROUTINE) task4, NULL, CREATE_SUSPENDED, NULL);

    InitializeCriticalSection(&section);

    ResumeThread(T2);
    ResumeThread(T3);
    ResumeThread(T4);
    ResumeThread(T1);

    WaitForSingleObject(T1, INFINITE);
    WaitForSingleObject(T2, INFINITE);
    WaitForSingleObject(T3, INFINITE);
    WaitForSingleObject(T4, INFINITE);

    CloseHandle(T1);
    CloseHandle(T2);
    CloseHandle(T3);
    CloseHandle(T4);

    cout << "Program finished" << endl;

    return 0;
}