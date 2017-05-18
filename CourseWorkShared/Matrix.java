import java.util.Arrays;

/**
 * Created by all on 01.04.2017.
 */
public class Matrix implements Data {
    private int [][] data;

    public Matrix(int[][] data) {
        this.data = data;
    }
    public Matrix(int n) {
        data = new int[n][n];
        fill();
    }

    private void fill() {
        for (int i = 0; i <data.length ; i++) {
            for (int j = 0; j <data.length ; j++) {
                data[i][j] = 1;
            }
        }
    }

    public void setElement(int i, int j, int value){
        data[i][j] = value;
    }

    public int getElement(int i, int j){
        return data[i][j];
    }


    public static void mulMatrMatr(Matrix m1, Matrix m2, int begin, int end) {
        int [][]m=new int[m1.getData().length][m1.getData().length];
        for (int i = begin; i <end; i++) {
            for (int j = 0; j <m.length; j++) {
                m[i][j]=0;
                for (int k = 0; k <m.length; k++) {
                    m[i][j]=m[i][j]+m1.getElement(i,k)*m2.getElement(k,j);
                }
            }
            for (int l = 0; l <m.length; l++) {
                m1.setElement(i,l,m[i][l]);
            }
        }
    }

    public static void mulMatrMatr(Matrix m1, Matrix m2, Matrix res, int begin, int end) {
        int [][]m=new int[m1.getData().length][m1.getData().length];
        for (int i = begin; i <end; i++) {
            for (int j = 0; j <m.length; j++) {
                res.setElement(i,j,0);
                for (int k = 0; k <m.length; k++) {
                    res.setElement(i,j, res.getElement(i,j)+m1.getElement(i,k)*m2.getElement(k,j));
                }
            }
        }
    }

    public static void mulMatrMatr(Matrix m1, Matrix m2) {
        int [][]m=new int[m1.getData().length][m1.getData().length];
        for (int i = 0; i <m.length; i++) {
            for (int j = 0; j <m.length; j++) {
                m[i][j]=0;
                for (int k = 0; k <m.length; k++) {
                    m[i][j]=m[i][j]+m1.getElement(i,k)*m2.getElement(k,j);
                }
            }
            for (int l = 0; l <m.length; l++) {
                m1.setElement(i,l,m[i][l]);
            }
        }
    }

    public static void addMatrix(Matrix m1, Matrix m2, Matrix res, int begin, int end) {
        for (int i = begin; i <end; i++) {
            for (int j = 0; j <m1.getData().length; j++) {
                res.setElement(i,j,m1.getElement(i,j)+m2.getElement(i,j));
            }
        }
    }


    public static void mulMatrNumber(Matrix m1, int n, int begin, int end) {
        for (int i = begin; i <end; i++) {
            for (int j = 0; j <m1.getData().length; j++) {
                m1.setElement(i,j,m1.getElement(i,j)*n);
            }
        }
    }



    public int[][] getData() {
        return data;
    }

    @Override
    public Matrix copy() {
        int [][] m=new int[data.length][data.length];
        for (int i = 0; i <data.length; i++) {
            m[i]= Arrays.copyOf(data[i],data.length);
        }
        return new Matrix(m);
    }

    public void print() {
        if(data.length<10){
            for (int i = 0; i <data.length; i++) {
                System.out.println(Arrays.toString(data[i]));
            }
        }
    }
}