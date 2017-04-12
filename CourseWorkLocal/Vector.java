import java.util.Arrays;
import java.util.Random;

/**
 * Created by all on 01.04.2017.
 */
public class Vector implements Data {
    private int [] data;

    public Vector(int n) {
        data = new int[n];
        fill();
    }

    public Vector(int n, Random r) {
        data = new int[n];
        for (int i = 0; i <data.length; i++) {
            data[i]=r.nextInt();
        }
    }

    public Vector(int[] data) {
        this.data = data;
    }

    public void setElement(int i, int value){
        data[i] = value;
    }

    public int getElement(int i){
        return data[i];
    }

    private void fill() {
        for (int i = 0; i <data.length ; i++) {
            data[i] = 1;
        }
    }

    public static int [] sort(int [] v,int left, int right){
        int [] rv = new int [right-left];
        for (int i = left; i < right; i++) {
            for (int j = right-1; j > i; j--) {
                if (v[j] < v[j - 1]) {
                    int t = v[j];
                    v[j] = v[j - 1];
                    v[j - 1] = t;
                }
            }
        }
        for (int i = 0; i < rv.length ; i++) {
            rv[i]=v[left];
            left++;
        }
        return rv;
    }

    public static int [] mergeSort(int [] v1, int [] v2){
        int [] v = new int [v1.length+v2.length];
        int i=0, j=0;
        for (int k=0; k<v.length; k++) {
            if (i > v1.length-1) {
                int a = v2[j];
                v[k] = a;
                j++;
            }
            else if (j > v2.length-1) {
                int a = v1[i];
                v[k] = a;
                i++;
            }
            else if (v1[i] < v2[j]) {
                int a = v1[i];
                v[k] = a;
                i++;
            }
            else {
                int b = v2[j];
                v[k] = b;
                j++;
            }
        }
        return v;
    }

    public static void  mulVectorMatr(Vector v, Vector res, Matrix m, int begin, int end){
        int []buf=new int[v.getData().length];
        for (int i = begin; i <end; i++) {
            buf[i]=0;
            for (int j = 0; j <buf.length; j++) {
                buf[i]+=v.getElement(j)*m.getElement(i,j);
            }
            res.setElement(i,buf[i]);
        }
    }

    public static void addVector(Vector v1, Vector v2,Vector res, int begin, int end) {
        for (int i = begin; i <end; i++) {
            res.setElement(i,v1.getElement(i)+v2.getElement(i));
        }
    }

    public static void mulVectorNumber(Vector v, int n, int begin, int end) {
        for (int i = begin; i <end; i++) {
                v.setElement(i,v.getElement(i)*n);
        }
    }


    public static int findMax(Vector v,int begin, int end){
        int z=Integer.MIN_VALUE;
        for (int i = begin; i <end; i++) {
                if(z<v.getElement(i)){
                    z=v.getElement(i);
                }
        }
        return z;
    }


    public int[] getData() {
        return data;
    }

    @Override
    public Vector copy() {
        return new Vector(Arrays.copyOf(data,data.length));
    }

    public void print(){
        if(data.length<10){
            System.out.println(Arrays.toString(data));
        }
    }
}
