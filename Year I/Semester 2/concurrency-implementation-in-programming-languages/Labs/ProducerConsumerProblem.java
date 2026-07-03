import java.util.Random;

public class ProducerConsumerProblem
{
	public static void main(String[] args) {
		Drop drop = new Drop();
		(new Thread(new Producer(drop))).start();
		(new Thread(new Consumer(drop))).start();
		(new Thread(new Consumer(drop))).start();
	}
}

class Producer implements Runnable 
{
    private Drop drop;
    
    public Producer(Drop drop) {
        this.drop = drop; 
    }
    
    @Override 
    public void run() {
        String messages[] = { "i", "want", "to", "send", "a", "message" };
        Random random = new Random();
        
        for (int i = 0; i < messages.length; i++) {
            System.out.println(Thread.currentThread().getId() + " produced " + messages[i]);
            drop.put(messages[i]);
            try {
                Thread.sleep(random.nextInt(5000));
            }
            catch (InterruptedException ex) {
                ex.printStackTrace();
            }
        }
        
        drop.put("DONE");
    }
}

class Consumer implements Runnable 
{
    private Drop drop; 
    
    public Consumer(Drop drop) {
        this.drop = drop; 
    }
    
    @Override 
    public void run() {
        Random random = new Random(); 
        for (String message = drop.take(); !message.equals("DONE"); message = drop.take()) {
            System.out.println(Thread.currentThread().getId() + " received " + message);
            try {
                Thread.sleep(random.nextInt(5000));
            }
            catch (InterruptedException ex) {
                ex.printStackTrace();
            }
        }
    }
}

class Drop 
{
    private String message;
    private boolean isEmpty = true; 
    
    public synchronized String take() {
        while (isEmpty) {
            try {
                wait();
            }
            catch (InterruptedException ex) {
                ex.printStackTrace();
            }
        }
        isEmpty = true; 
        notifyAll();
        return message; 
    } 
    
    public synchronized void put(String message) {
        while (!isEmpty) {
            try {
                wait();
            }
            catch (InterruptedException ex) {
                ex.printStackTrace();
            }
        }
        isEmpty = false;
        this.message = message;
        notifyAll();
    }
}