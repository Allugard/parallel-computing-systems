/**
 * Created by allugard on 15.05.17.
 */
public class IntegerMonitor {
    private int a;

    public IntegerMonitor() {
    }

    public IntegerMonitor(int buf) {
        this.a = buf;
    }

    public synchronized int get() {
        return a;
    }

    public synchronized void set(int buf){
        this.a=buf;
    }

    public synchronized void add(int buf){
        this.a+=buf;
    }

    public void setMax(int max){
        if(a < max){
            a = max;
        }
    }

}
