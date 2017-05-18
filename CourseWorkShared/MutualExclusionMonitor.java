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

    public synchronized void set(T data, int begin, int end){
        if(buf.getClass() == Matrix.class){
            for (int i = begin; i <end; i++) {
                for (int j = 0; j <((Matrix)data).getData().length; j++) {
                    ((Matrix)buf).setElement(i,j,((Matrix)data).getElement(i,j));
                }
            }
        }
    }

}
