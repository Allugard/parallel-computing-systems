/**
 * Created by all on 01.04.2017.
 */
public class MutualExclusionMonitor <T extends Data>  {
    private T buf;

    public MutualExclusionMonitor(T buf) {
        this.buf = buf;
    }

    public synchronized T get() {
         return (T) buf.copy();
    }

    public synchronized void set(T buf){
        this.buf=buf;
    }

}
