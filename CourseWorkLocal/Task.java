
import java.util.concurrent.RecursiveAction;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Created by all on 01.04.2017.
 */
public class Task extends RecursiveAction {

    private int tId;
    private static AtomicInteger threadCount = new AtomicInteger(0);
    public static int n,p,H;
    private static SynchronizedMonitor inputMonitor;
    private static SynchronizedMonitor maxMonitor;
    private static MutualExclusionMonitor <Matrix> MCmonitor;
    private static MutualExclusionMonitor <Matrix> MDmonitor;

    private static Vector Z;
    private static Matrix MT;
    private static Matrix MA;
    private static Matrix MB;
    private static Matrix MC;
    private static Matrix MD;
    private static AtomicInteger atomicZ;



    public static void init() {
        inputMonitor = new SynchronizedMonitor(2);
        maxMonitor = new SynchronizedMonitor(p);
        MA=new Matrix(n);
        atomicZ =new AtomicInteger(Integer.MIN_VALUE);
    }

    public Task() {
        tId = threadCount.incrementAndGet();
    }

    private void function(Matrix MC, Matrix MD, int z,int begin, int end){

        Matrix.mulMatrMatr(MC,MD);
        Matrix.mulMatrMatr(MB, MC, begin, end);
        Matrix.mulMatrNumber(MT, z, begin, end);
        Matrix.addMatrix(MB, MT, MA, begin, end);
    }

    @Override
    protected void compute() {
        if(tId == p){
            Z = new Vector(n);
//            Z.setElement(2,5);
            MC = new Matrix(n);
            MD = new Matrix(n);
            MCmonitor = new MutualExclusionMonitor<>(MC);
            MDmonitor = new MutualExclusionMonitor<>(MD);
            inputMonitor.sendSignal();
        }
        if(tId == 1){
            MT = new Matrix(n);
            MB = new Matrix(n);
            inputMonitor.sendSignal();
        }
        inputMonitor.waitSignal();

        int z = Vector.findMax(Z, (tId -1)*H, tId *H);

        synchronized (atomicZ) {
            if (z > atomicZ.get()) {
                atomicZ.set(z);
            }
        }

        maxMonitor.sendSignal();
        maxMonitor.waitSignal();

        z = atomicZ.get();
        Matrix bufMC = MCmonitor.get();
        Matrix bufMD = MDmonitor.get();

        function(bufMC,bufMD,z,(tId -1)*H, tId *H);

        if(tId == 1){
            for (int i = 1; i <Main.tasks.length-1; i++) {
                Main.tasks[i].join();
            }
            MA.print();
        }
    }

}
