import java.util.concurrent.ForkJoinPool;

/**
 * Created by all on 01.04.2017.
 */
public class Main {
    public static Task [] tasks;
    public static void main(String[] args) {
        Task.n = 1000;
        Task.p = 2;
        Task.H = Task.n/Task.p;
        Task.init();
        tasks = new Task[Task.p];


        ForkJoinPool forkJoinPool =new ForkJoinPool(Task.p);
        for (int i = 0; i < tasks.length ; i++) {
            tasks[i] = new Task();
//            forkJoinPool.execute(tasks[i]);
        }
        long beg = System.currentTimeMillis();
        for (int i = 0; i < tasks.length ; i++) {
//                tasks[i] = new Task();
                forkJoinPool.execute(tasks[i]);
            }
        tasks[0].join();
        long end = System.currentTimeMillis();
        System.out.println("Time in ms="+ (end - beg));

    }
}//
