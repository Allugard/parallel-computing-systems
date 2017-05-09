#include <stdio.h>
#include <mpi.h>
#include <stdlib.h>
#include <cmath>
#include <time.h>
#include <climits>


const int n=700;
 int p;
 int h;




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



void matrix_output(int matrix[n][n], int k) {
    if(n<10){
    for (int i = 0; i < k; ++i) {
        for (int j = 0; j < n; ++j) {
            printf("%d ", matrix[i][j]);
        }
        printf("\n");
        }
    }
}


int findMax(int v[]){
    int z=INT_MIN;
    for (int i = 0; i <h; i++) {
        if(z<v[i]){
            z=v[i];
        }
    }
    return z;
}



void sum_matrix(int m1[][n],int m2[][n], int res[][n]){
    for (int i = 0; i <h; ++i) {
        for (int j = 0; j < n; ++j) {
            res[i][j]=m1[i][j]+m2[i][j];

        }
    }
}

void mul_matrix_number(int m[][n], int z){
    for (int i = 0; i <h; ++i) {
        for (int j = 0; j < n; ++j) {
            m[i][j]=m[i][j]*z;

        }
    }
}


void matrix_multiplication(int m1[][n], int m2[n][n], int res[][n]) {
    for (int i = 0; i <h; ++i){
        for (int j = 0; j <n; ++j){
            res[i][j]=0;
            for (int k = 0; k <n; ++k){
                res[i][j]+=m1[i][k]*m2[k][j];
            }
        }
    }
}


int main(int argc, char *argv[]) {
    int Z[n];
    int MA[n][n];
    int z;
    int MB[n][n];
    int MC[n][n];
    int MD[n][n];
    int MT[n][n];
    int MP[n][n];
    int rank;

    float fTimeStart = clock()/(float)CLOCKS_PER_SEC;

    MPI_Init(&argc, &argv);

    MPI_Comm_size(MPI_COMM_WORLD, &p);
    h = n / p;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    int sendcounts [p];
    int displs [p];

    for(int i = 0; i < p; i++){
        sendcounts[i] = h;
        displs[i] = i*h;
    }

    if (rank == p - 1) {
        vector_input(Z, 1);
        matrix_input(MC);
        matrix_input(MD);
    }

    if (rank == 0) {
        matrix_input(MT);
        matrix_input(MB);
    }

    int index[p];
    int num = 0;
    for (int i = 0; i < p; i++) {
        if (i == 0 || i == p-1 || i == p/2 || i == p/2-1) {
            num += 2;
        } else {
            num += 3;
        }
        index[i] = num;
    }

    int edges[3 * p - 4];


    edges[0] = p / 2;
    edges[1] = 1;

    edges[(p/2-1)*3-1] = p-1;
    edges[(p/2-1)*3] = p/2 - 2;
    edges[(p/2-1)*3+1] = 0;
    edges[(p/2-1)*3+2] = p/2+1;


    edges[3*p-5] = p/2-1;
    edges[3*p-6] = p-2;


    for (int i = 1, j = 3; i < (p / 2) - 1; i++) {
        edges[i * j - 1] = i - 1;
        edges[i * j ] = i + p / 2;
        edges[i * j + 1] = i + 1;
    }


    for (int i = p/2+1, j = 3; i < p-1; i++) {
        edges[i * j - 3] = i - 1;
        edges[i * j - 2] = i - p / 2;
        edges[i * j - 1] = i + 1;
    }


    MPI_Comm graphComm;

    MPI_Graph_create(MPI_COMM_WORLD, p, index, edges, 0, &graphComm);

    MPI_Status status;
    int tag = 1;

    int Zh[h];

    MPI_Scatter(Z, h, MPI_INT, Zh, h, MPI_INT, p - 1, graphComm);


    z = findMax(Zh);
    int zprev;

    if(rank == 0 || rank == p/2){
        MPI_Send(&z, 1, MPI_INT, rank+1, tag, graphComm);
    } else{
        MPI_Recv(&zprev, 1, MPI_INT, rank-1, tag, graphComm, &status);
        if (zprev>z){
            z = zprev;
        }

        if(rank == p/2-1 || rank == p-1){
            if (rank == p/2-1){
               MPI_Send(&z, 1, MPI_INT, p-1, tag, graphComm);
           }
            if (rank == p-1){
                MPI_Recv(&zprev, 1, MPI_INT, p/2-1, tag, graphComm, &status);
                if (zprev>z){
                    z = zprev;
                }
            }
        } else{

            MPI_Send(&z, 1, MPI_INT, rank+1, tag, graphComm);
        }
    }


    MPI_Datatype strip;
    MPI_Type_vector(p, h*h, h*h, MPI_INT, &strip);
    MPI_Type_commit(&strip);

    int MCh[h][n];


    MPI_Scatter(MC, 1, strip, MCh, 1, strip, p-1, graphComm);
    MPI_Bcast(&MD, n*n, MPI_INT, p-1, graphComm);



    int MPh [h][n];
    matrix_multiplication(MCh, MD, MPh);




     MPI_Gather(MPh, 1, strip, MP, 1, strip, p-1, graphComm);
     MPI_Bcast(&MP, n*n, MPI_INT, p-1, graphComm);
     MPI_Bcast(&z, 1, MPI_INT, p-1, graphComm);


    int MAh[h][n];
    int MBh[h][n];
    int MTh[h][n];
    int buf[h][n];

     MPI_Scatter(MB, 1, strip, MBh, 1, strip, 0, graphComm);
     MPI_Scatter(MT, 1, strip, MTh, 1, strip, 0, graphComm);

    mul_matrix_number(MTh, z);
    matrix_multiplication(MBh, MP, buf);
    sum_matrix(MTh, buf, MAh);

    MPI_Gather(MAh, 1, strip, MA, 1, strip, 0, graphComm);






    if (rank == 0){

        matrix_output(MA, n);
        float fTimeStop = clock()/(float)CLOCKS_PER_SEC;
        printf("%f \n", fTimeStop-fTimeStart);

    }

    MPI_Finalize();


    return 0;
}
