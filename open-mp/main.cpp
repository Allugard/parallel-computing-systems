#include <stdio.h>
#include <omp.h>
#include <iostream>
#include <cstring>

using std::cout;
using std::endl;

//          Assignment #4
//    Student: Sergei Vasilenko
//    Group:   IO-42
//    Date:    06/04/2017
//
//   A = sort(Z)*e + d*S*(MO * MK)


const int n=1000;
const int p=8;
const int h=n/p;



int MO[n][n];
int MK[n][n];
int A[n];
int Z[n];
int Zh[n][h];
int Z2h[n/2][2*h];
int Z4h[n/4][4*h];
int S[n];
int d;
int e;
omp_lock_t csMK;


void vector_input(int vector[n],int value){
    for (int i = 0; i <n; ++i) {
        vector[i]=value;
    }
}

void matrix_input(int matrix[n][n]){
    for (int i = 0; i <n; ++i) {
        for (int j = 0; j <n; ++j) {
            matrix[i][j]=1;
        }
    }
}

void vector_output(int vector[n]){
    if(n<10){
        for (int i = 0; i < n; ++i) {
            cout<<vector[i]<<" ";
        }
        cout<<endl;
    }
}

void matrix_output(int matrix[n][n]){
    if(n<10)
        for (int i = 0; i <n; ++i) {
            for (int j = 0; j <n; ++j) {
                cout<<matrix[i][j]<<" ";
            }
            cout<<endl;
        }
}

void sort(int  v[n], int left, int right,int rv[h]){
    for (int i = left; i < right; i++) {
        for (int j = right-1; j > i; j--) {
            if (v[j] < v[j - 1]) {
                int t = v[j];
                v[j] = v[j - 1];
                v[j - 1] = t;
            }
        }
    }
    for (int i = 0; i <h; i++) {
        rv[i]=v[left];
        left++;
    }
}

void merge(int m, int n, int A[], int B[], int C[]) {
    int i, j, k;
    i = 0;
    j = 0;
    k = 0;
    while (i < m && j < n) {
        if (A[i] <= B[j]) {
            C[k] = A[i];
            i++;
        } else {
            C[k] = B[j];
            j++;
        }
        k++;
    }
    if (i < m) {
        for (int p = i; p < m; p++) {
            C[k] = A[p];
            k++;
        }
    } else {
        for (int p = j; p < n; p++) {
            C[k] = B[p];
            k++;
        }
    }
}

void scalar_vector(int v[n],int s){
    #pragma omp for
    for (int i = 0; i <n; ++i) {
        v[i]=v[i]*s;
    }
}



void sum_vectors(int v1[n],int v2[n],int res[n]){
#pragma omp for
    for (int i = 0; i <n; ++i) {
        res[i]=v1[i]+v2[i];
    }
}

void matrix_multiplication(int m1[n][n], int m2[n][n]) {
    int res[n][n];
#pragma omp for
    for (int i = 0; i <n; ++i){
        for (int j = 0; j <n; ++j){
            res[i][j]=0;
            for (int k = 0; k <n; ++k){
                res[i][j]+=m1[i][k]*m2[k][j];
            }
        }
        for (int j = 0; j <n; ++j){
            m1[i][j]=res[i][j];
        }
    }
}

void matrix_vector(int vector[n], int matrix[n][n]){
    int resV[n];
#pragma omp for
    for (int i = 0; i <n; ++i) {
        resV[i] = 0;
        for (int j = 0; j <n; ++j) {
            resV[i]=resV[i]+matrix[i][j]*vector[j];
        }
    }
#pragma omp for
    for (int i = 0; i <n; ++i) {
        vector[i]=resV[i];
    }
}

void function(int e, int d, int S[n], int MK[n][n]){
    scalar_vector(Z,e);
    matrix_multiplication(MO,MK);
    matrix_vector(S,MO);
    scalar_vector(S,d);
    sum_vectors(S,Z,A);

};

int main()
{
    omp_init_lock(&csMK);
    int di;
    int ei;
    int MKi[n][n];
    int Si[n];
    int id;
#pragma omp parallel num_threads(p) private(id) /*private(id,di,ei,MKi,Si)*/
    {

        id = omp_get_thread_num();

        printf(" Task %d started!\n", id);
//        input
        if(id==0){
            vector_input(Z,1);
            Z[1]=5;
            Z[0]=6;
            Z[6]=12;

        }

        if(id==3){
            vector_input(S,1);
            d=1;
            e=1;
        }

        if(id==5){
            matrix_input(MO);
            matrix_input(MK);
        }
        //sort
#pragma omp barrier (inputBarrier)

        sort(Z,id*h,(id+1)*h,Zh[id]);
#pragma omp barrier (zortZhBarrier)

        if(id<4){
            merge(h,h,Zh[id],Zh[id+4],Z2h[id]);
        }
#pragma omp barrier (zortZ2hBarrier)

        if(id<2){
            merge(2*h,2*h,Z2h[id],Z2h[id+2],Z4h[id]);
        }
#pragma omp barrier (zortZ4hBarrier)

        if(id==0){
            merge(4*h,4*h,Z4h[id],Z4h[id+1],Z);
        }

#pragma omp barrier (zortZBarrier)


        //copy
#pragma atomic (atomic)
        {
            di=d;
        };

#pragma omp critical (cs)
        {
        memcpy(Si,S,sizeof(S));
        ei=e;
        }

        omp_set_lock(&csMK);
        memcpy(MKi,MK, sizeof(MK));
        omp_unset_lock(&csMK);
        //account
         function(ei, di, Si, MKi);

#pragma omp barrier (outputBarrier)

        //output
        if(id==0){
            vector_output(A);
        }

        printf(" Task %d finished!\n", id);
    }


    return 0;
}
