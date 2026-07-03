// exemplu de utilizare Future si Callable 

import java.util.concurrent.Callable;
import java.util.concurrent.FutureTask; 

public class FutureCallable {
    public static void main(String[] args) {
        //Callable<String> task = new MyTask();
        
        Callable<String> task = () -> {
            Thread.sleep(2000);
            return "Task completed";
        };
        
        FutureTask<String> futureTask = new FutureTask<>(task);
        
        Thread thread = new Thread(futureTask);
        thread.start();
        
        try {
            System.out.println("Main...");
            String result = futureTask.get();
            System.out.println("Result: " + result);
        }
        catch (Exception ex) {
            ex.printStackTrace();
        }
        
    }
}

class MyTask implements Callable<String> {
    @Override 
    public String call() {
        try {
            Thread.sleep(2000);
            return "Task completed";
        }
        catch (InterruptedException ex) {
            ex.printStackTrace();
            return "ERROR";
        }
    }
}