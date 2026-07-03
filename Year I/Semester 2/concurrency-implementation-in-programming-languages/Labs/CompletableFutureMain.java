import java.util.concurrent.CompletableFuture; 


public class CompletableFutureMain
{
	public static void main(String[] args) {
		int n = 20;
		System.out.println("Fibonacci for n = " + n);
		
		CompletableFuture<Long> future = CompletableFuture.supplyAsync(() -> fibonacci(n));
		
		future.thenAccept(result -> {
		    System.out.println("Fibo(" + n + ") = " + result);
		});
		
		System.out.println("Main...");
		future.join();
	}
	
	private static long fibonacci(int n) {
	    if (n <= 1) {
	        return n; 
	    }
	    return fibonacci(n - 1) + fibonacci(n - 2);
	}
}