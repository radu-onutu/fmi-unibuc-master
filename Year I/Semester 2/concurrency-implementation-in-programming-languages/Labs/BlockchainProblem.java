// Vrem sa simulam un Blockchain - inclusiv partea cu PoW 
// PoW - cautam un hash cu o problema grea / o constrangere dificila asupra hash-ului 
// Transaction, Block, Blockchain, Node 
 
import java.util.*;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.locks.ReentrantLock;
 
class Transaction {
    private String id; 
    
    public Transaction(String id) {
        this.id = id;
    }
    
    public String getId() {
        return id; 
    }
}
 
class Block {
    private int index; 
    private List<Transaction> transactions; 
    private String previousHash; 
    private String hash; 
    
    public Block(int index, List<Transaction> transactions, String previousHash) {
        this.index = index;
        this.transactions = transactions;
        this.previousHash = previousHash;
        this.hash = computeHash();
    }
    
    public String computeHash() {
        return Integer.toHexString(Objects.hash(index, transactions, previousHash));
    }
    
    public String getHash() {
        return hash; 
    }
    
    public String getPreviousHash() {
        return previousHash;
    }
    
    public int getIndex() {
        return index; 
    }
}
 
class Blockchain {
    private List<Block> chain = new ArrayList<>();
    private ReentrantLock lock = new ReentrantLock();
    
    public Blockchain() {
        chain.add(new Block(0, new ArrayList<>(), "0"));
    }
    
    public void addBlock(Block block) {
        lock.lock();
        try {
            if (chain.get(chain.size() - 1).getHash().equals(block.getPreviousHash())){
                chain.add(block);
                System.out.println("Block added: " + block.getIndex() + " with hash " + block.getHash());
            }
        }
        finally {
            lock.unlock();
        }
    }
    
    public Block getLastBlock() {
        return chain.get(chain.size() - 1);
    }
}
 
class Node implements Runnable {
    private BlockingQueue<Transaction> transactionPool; 
    private Blockchain blockchain; 
    private String nodeId; 
    
    public Node(String nodeId, Blockchain blockchain, BlockingQueue<Transaction> transactionPool) {
        this.nodeId = nodeId;
        this.blockchain = blockchain;
        this.transactionPool = transactionPool;
    }
    
    @Override 
    public void run() {
        while(true) {
            try {
                List<Transaction> transactions = new ArrayList<>(); 
                transactionPool.drainTo(transactions, 5);
                
                if (!transactions.isEmpty()) {
                    Block previousBlock = blockchain.getLastBlock();
                    Block newBlock = new Block(previousBlock.getIndex() + 1, transactions, previousBlock.getHash());
                    
                    // simulam ca sta pentru PoW 
                    Thread.sleep((long) (Math.random() * 600));
                    
                    blockchain.addBlock(newBlock);
                } else {
                    System.out.println(nodeId + " found no transactions, waiting...");
                    Thread.sleep(6000); 
                }
            }
            catch (InterruptedException ex) {
                ex.printStackTrace();
            }
        }
    }
}
 
public class BlockchainProblem {
    public static void main(String[] args) {
        BlockingQueue<Transaction> transactionPool = new LinkedBlockingQueue<>();
        Blockchain blockchain = new Blockchain();
        
        Thread node1 = new Thread(new Node("Node1", blockchain, transactionPool));
        Thread node2 = new Thread(new Node("Node2", blockchain, transactionPool));
        Thread node3 = new Thread(new Node("Node3", blockchain, transactionPool));
        
        node1.start();
        node2.start();
        node3.start();
        
        for (int i = 0; i < 100; ++i) {
            System.out.println("Added transaction " + i);
            transactionPool.add(new Transaction("Transaction " + i));
            try {
                Thread.sleep((long) (Math.random() * 500));
            }
            catch (InterruptedException ex) {
                ex.printStackTrace();
            }
        }
        
    }
}