import java.util.concurrent.locks.ReentrantLock;;

class AcmeSafe implements State {
    private byte[] value;
    private byte maxval;
	private ReentrantLock lok;

    AcmeSafe(byte[] v) { value = v; maxval = 127; lok = new ReentrantLock();}

    AcmeSafe(byte[] v, byte m) { value = v; maxval = m; lok = new ReentrantLock();}

    public int size() { return value.length; }

    public byte[] current() { return value; }

    public boolean swap(int i, int j) {
	lok.lock();
	if (value[i] <= 0 || value[j] >= maxval) {
		lok.unlock();
	    return false;
	}
	value[i]--;
	value[j]++;
	lok.unlock();
	return true;
    }
}
