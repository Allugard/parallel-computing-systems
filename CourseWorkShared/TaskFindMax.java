
import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.RecursiveTask;

/**
 * Created by all on 01.04.2017.
 */
public class TaskFindMax extends RecursiveTask<Integer> {


    private static int eps;
    private Vector vector;
    private int begin;
    private int end;

    public static void init(int eps) {
        TaskFindMax.eps = eps;
    }

    public TaskFindMax(Vector vector, int begin, int end) {
        this.vector = vector;
        this.begin = begin;
        this.end = end;
    }

    @Override
    protected Integer compute() {
        if(begin - end <= eps){
            return Vector.findMax(vector, begin, end);
        }
        int med = (begin-end)/2;
        TaskFindMax left = new TaskFindMax(vector, begin, med);
        TaskFindMax right= new TaskFindMax(vector, med, end);
        left.fork();
        int res = right.compute();
        int leftRes = left.join();
        if(res < leftRes){
            return leftRes;
        }

        return res;
    }

    public static int findMax(Vector vector, int begin, int end){
        return ForkJoinPool.commonPool().invoke(new TaskFindMax(vector, begin, end));
    }

}
