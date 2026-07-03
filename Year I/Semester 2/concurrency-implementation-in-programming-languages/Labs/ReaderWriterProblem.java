import java.util.concurrent.Semaphore; 

// Reader-Writer 
// avem mereu un singur Writer care poate accesa zona critica in care sa scrie 
// avem oricati Readeri care pot citi din zona respectiva, in paralel 
// vom acorda prioritate threadurilor Reader 

public class ReaderWriterProblem
{
    public static void main(String[] args) {
        Semaphore wrt = new Semaphore(1);
        Semaphore mutex = new Semaphore(1);
        
        (new Thread(new Reader(wrt, mutex))).start();
        (new Thread(new Writer(wrt))).start();
        (new Thread(new Writer(wrt))).start();
        (new Thread(new Reader(wrt, mutex))).start();
        (new Thread(new Writer(wrt))).start();
        (new Thread(new Writer(wrt))).start();
        (new Thread(new Reader(wrt, mutex))).start();
        (new Thread(new Writer(wrt))).start();
        (new Thread(new Reader(wrt, mutex))).start();
        (new Thread(new Reader(wrt, mutex))).start();
        (new Thread(new Writer(wrt))).start();
        (new Thread(new Writer(wrt))).start();
        
    }
}

// de cate ori permitem unui reader sa intre, il contorizam 
// daca este primul Reader care intra (deci aveam ca ReaderCount == 0)
// atunci inseamna ca el este cel care trebuie sa ia permisiunea pe zona de memorie 
// permite altor readeri sa intre, pentru ca primul blocheaza threadurile Writer 
// pe masura ce Readerii ies, cand ajungem la ultimul
// (daca pentru el ReaderCount == 1)
// cand iese, elibereaza resursa pentru Writer 

// Writer1 scrie si elibereaza zona  
// Reader1
//  el este primul, deci blocheaza zona respectiva pentru citire 
//  Reader2 
//  Reader3 
//  Reader2 out  
//  Reader1 out 
//  Reader3 out elibereaza zona pentru Writer 

// voi avea doua semafoare 
// wrt - e cel care da permisiune intre rolurile de Reader si Writer 
// mutex - cel care imi asigura ca operatiile din Reader sunt thread-safe 

class Writer implements Runnable 
{
    private Semaphore wrt; 
    
    public Writer(Semaphore wrt) {
        this.wrt = wrt; 
    }
    
    @Override 
    public void run() {
        while (true) {
            try {
                // Writer care vrea sa scrie in zona critica 
                wrt.acquire();
                // aici se executa operatia din zona critica 
                System.out.println(Thread.currentThread().getId() + " writes"); 
                Thread.sleep(1000);
                // dupa ce a terminat scrierea in zona critica, o elibereaza 
                wrt.release();
                Thread.sleep(3000);
            }
            catch (InterruptedException ex) {
                ex.printStackTrace();
            }
        }
    }
}

class Reader implements Runnable 
{
    private Semaphore wrt; 
    private Semaphore mutex; 
    
    public Reader(Semaphore wrt, Semaphore mutex) {
        this.wrt = wrt;
        this.mutex = mutex; 
    }
    
    @Override 
    public void run() {
        while (true) {
            try {
                // Avem readeri care vor sa citeasca din zona critica 
                mutex.acquire();
                
                ReaderCounter.inc();
                
                if (ReaderCounter.get() == 1) {
                    wrt.acquire();
                }
                
                mutex.release(); 
                
                System.out.println(Thread.currentThread().getId() + " consumes"); 
                Thread.sleep(1000); 
                
                // readerii vor sa iasa din zona critica 
                mutex.acquire();
                
                ReaderCounter.dec();
                
                if (ReaderCounter.get() == 0) {
                    wrt.release();
                }

                mutex.release();
            }
            catch (InterruptedException ex) {
                ex.printStackTrace();
            }
        }
    }
}

class ReaderCounter 
{
    private static int readcnt = 0; 
    
    public static int get() {
        return readcnt; 
    }
    
    public static void inc() {
        readcnt++;
    }
    
    public static void dec() {
        readcnt--;
    }
}