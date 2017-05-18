import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.RecursiveTask;

/**
 * Created by allugard on 17.05.17.
 */
public class TaskMulVector extends RecursiveTask<Integer> {


    private static int eps;
    private Vector v1;
    private Vector v2;
    private int begin;
    private int end;

    public TaskMulVector(Vector v1, Vector v2, int begin, int end) {
        this.v1 = v1;
        this.v2 = v2;
        this.begin = begin;
        this.end = end;
    }

    public static void init(int eps) {
        TaskMulVector.eps = eps;
    }

    @Override
    protected Integer compute() {
        if(begin - end <= eps){
            return Vector.mul(v1, v2, begin, end);
        }
        int med = (begin-end)/2;
        TaskMulVector left = new TaskMulVector(v1, v2, begin, med);
        TaskMulVector right= new TaskMulVector(v1, v2, med, end);
        left.fork();
        int res = right.compute();
        int leftRes = left.join();
        if(res < leftRes){
            return leftRes;
        }

        return res;
    }

    public static int mulVector(Vector v1, Vector v2,  int begin, int end){
        return ForkJoinPool.commonPool().invoke(new TaskMulVector(v1, v2, begin, end));
    }
}
