import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.ForkJoinPool;

/**
 * Created by all on 01.04.2017.
 */
public class Main {
    public static Thread [] tasks;
    public static void main(String[] args) throws InterruptedException {
        Task.n = 8;
        Task.p = 4;
        Task.H = Task.n/Task.p;
        int eps = 2;
        Task.init(eps);
        tasks = new Thread[Task.p];


        ForkJoinPool forkJoinPool =new ForkJoinPool(Task.p);
        for (int i = 0; i < tasks.length ; i++) {
            tasks[i] = new Thread(new Task());
        }
        Instant start = Instant.now();
        long beg = System.currentTimeMillis();
        for (int i = 0; i < tasks.length ; i++) {
            tasks[i].start();
            }
        tasks[0].join();
        Instant end1 = Instant.now();
        long end = System.currentTimeMillis();

        System.out.println("Time in ms="+ (end - beg));
        System.out.println(Duration.between(start, end1));

    }
}
