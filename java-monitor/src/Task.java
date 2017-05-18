import java.util.concurrent.atomic.AtomicInteger;

/**
 * Created by allugard on 15.05.17.
 */
public class Task implements Runnable {

    private static int n,p,H;
    private static Vector B;
    private static Vector C;
    private static Vector Z;
    private static Matrix MT;
    private static Matrix MA;
    private static Matrix MO;
//    private static Matrix MR;

    private static IntegerMonitor eMonitor;
    private static IntegerMonitor aMonitor;
    private static IntegerMonitor maxMonitor;
    private static MutualExclusionMonitor <Matrix> MRmonitor;

    private static SynchronizedMonitor inputMonitor;
    private static SynchronizedMonitor outputMonitor;
    private static SynchronizedMonitor maxSynchrMonitor;

    private int tId;
    private static AtomicInteger threadCount = new AtomicInteger(0);

    public Task(){
        tId = threadCount.incrementAndGet();
    }

    public static void init(int n1, int p1, int eps) {
        n = n1;
        p = p1;
        H = n/p;
        inputMonitor = new SynchronizedMonitor(3);
        maxSynchrMonitor = new SynchronizedMonitor(p);
        outputMonitor = new SynchronizedMonitor(p-1);
        aMonitor = new IntegerMonitor();
        maxMonitor = new IntegerMonitor(Integer.MIN_VALUE);
        MA = new Matrix(n);
        TaskFindMax.init(eps);
    }




    @Override
    public void run() {
        if(tId == 1){
            Z = new Vector(n);
            MT = new Matrix(n);
            inputMonitor.sendSignal();
        }

        if(tId == 3){
            C = new Vector(n);
            MO = new Matrix(n);
            inputMonitor.sendSignal();
        }

        if(tId == 4){
            B = new Vector(n);
            eMonitor = new IntegerMonitor(1);
            MRmonitor = new MutualExclusionMonitor<>(new Matrix(n));
            inputMonitor.sendSignal();
        }

        inputMonitor.waitSignal();

        int sum = TaskMulVector.mulVector(B, C, (tId -1)*H, tId *H);
        aMonitor.add(sum);
        int max = TaskFindMax.findMax(Z, (tId -1)*H, tId *H);
        maxMonitor.setMax(max);

        maxSynchrMonitor.sendSignal();
        maxSynchrMonitor.waitSignal();


        Matrix MRi = MRmonitor.get();

        int ei = eMonitor.get();
        int zi = maxMonitor.get();
        int ai = aMonitor.get();



        func(MRi, ei, zi, ai, (tId -1)*H, tId *H);

        if(tId == 4){
            MA.print();
        }
//        System.out.println(aMonitor.get());

    }

    private void func(Matrix MRi, int ei, int zi, int ai, int begin, int end) {
        Matrix.mulMatrNumber(MO, ai, begin, end);
        Matrix.mulMatrMatr(MT, MRi, begin, end);
        Matrix.mulMatrNumber(MT, ei* zi, begin, end);
        Matrix.addMatrix(MO, MT, MA, begin, end);
    }
}
