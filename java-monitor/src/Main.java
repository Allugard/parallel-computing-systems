import java.util.Arrays;
import java.util.Random;
import java.util.concurrent.ForkJoinPool;

/**
 * Created by all on 01.04.2017.
 */
public class Main {

    public static void main(String[] args) throws InterruptedException {
        int n = 12;
        int p = 6;
        int eps = 2;
        Task.init(n, p);

        Thread [] threads = new Thread[p];
        for (int i = 0; i < p; i++) {
            threads[i] = new Thread(new Task());
            threads[i].start();
        }
        for (int i = 0; i < p; i++) {
            threads[i].join();
        }
    }
}
