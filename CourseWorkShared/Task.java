
import java.util.concurrent.RecursiveAction;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Created by all on 01.04.2017.
 */
public class Task implements Runnable {

    private int tId;
    private static AtomicInteger threadCount = new AtomicInteger(0);
    public static int n,p,H;
    private static SynchronizedMonitor inputMonitor;
    private static SynchronizedMonitor mulMonitor;
    private static SynchronizedMonitor maxMonitor;
    private static MutualExclusionMonitor <Matrix> MPmonitor;
    private static MutualExclusionMonitor <Matrix> MDmonitor;

    private static Vector Z;
    private static Matrix MT;
    private static Matrix MA;
    private static Matrix MB;
    private static Matrix MC;
    private static Matrix MD;
    private static Matrix MP;
    private static AtomicInteger atomicZ;



    public static void init(int eps) {
        inputMonitor = new SynchronizedMonitor(2);
        mulMonitor = new SynchronizedMonitor(1);
        maxMonitor = new SynchronizedMonitor(p);
        MPmonitor = new MutualExclusionMonitor<>(new Matrix(n));
        MA=new Matrix(n);
        MP = new Matrix(n);
        atomicZ =new AtomicInteger(Integer.MIN_VALUE);
        TaskFindMax.init(eps);
    }

    public Task() {
        tId = threadCount.incrementAndGet();
    }

    private void function(Matrix MP, int z,int begin, int end){
        Matrix.mulMatrMatr(MB, MP, begin, end);
        Matrix.mulMatrNumber(MT, z, begin, end);
        Matrix.addMatrix(MB, MT, MA, begin, end);
    }

    @Override
    public void run() {
        if(tId == p){
            Z = new Vector(n);
//            Z.setElement(2,5);
            MC = new Matrix(n);
            MD = new Matrix(n);
//            MPmonitor = new MutualExclusionMonitor<>(MP);
            MDmonitor = new MutualExclusionMonitor<>(MD);
            inputMonitor.sendSignal();
        }
        if(tId == 1){
            MT = new Matrix(n);
            MB = new Matrix(n);
            inputMonitor.sendSignal();
        }
        inputMonitor.waitSignal();

//        int zi = Vector.findMax(Z, (tId -1)*H, tId *H);
        int zi = TaskFindMax.findMax(Z, (tId -1)*H, tId *H);

        synchronized (atomicZ) {
            if (zi > atomicZ.get()) {
                atomicZ.set(zi);
            }
        }

//        Matrix bufMC = MCmonitor.get();
        Matrix bufMDi = MDmonitor.get();
        Matrix.mulMatrMatr(MC, bufMDi, MP, (tId -1)*H, tId *H );
        MPmonitor.set(MP, (tId -1)*H, tId *H );


        maxMonitor.sendSignal();
        maxMonitor.waitSignal();
//        if (tId == p) {
//            MPmonitor = new MutualExclusionMonitor<>(MP);
//            mulMonitor.sendSignal();
//        }
//
//        mulMonitor.waitSignal();
        zi = atomicZ.get();
        Matrix bufMPi = MPmonitor.get();


        function(bufMPi,zi,(tId -1)*H, tId *H);


        if(tId == 1){
            for (int i = 1; i <Main.tasks.length-1; i++) {
                try {
                    Main.tasks[i].join();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
            MA.print();
        }
    }

}
