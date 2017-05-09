/**
 * Created by all on 01.04.2017.
 */
public class SynchronizedMonitor {
    private int f;

    public SynchronizedMonitor(int flag) {
        this.f = flag;
    }

    synchronized void waitSignal(){
        if(f!=0){
            try {
                wait();
            }catch (InterruptedException e){
                e.printStackTrace();
            }
        }
    }
    synchronized void sendSignal(){
       f--;
       if (f==0){
           notifyAll();
       }
    }

    synchronized int getFlag(){
        return f;
    }

    }
