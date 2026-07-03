import Control.Concurrent 
import Control.Monad 

-- concurenta in Haskell

{-
Concurenta in Haskell. Threaduri. Memorie partajata 

- concurenta are loc in monada IO 

forkIO :: IO () -> IO ThreadId 

data MVar a 

newEmptyMVar :: IO (MVar a) -- imi permite sa creez o locatie noua de memorie, fara valoare initiala 
                            -- m <- newEmptyMVar 
                            
newMVar :: a -> IO (MVar a) -- creeza o locatie de memorie care are deja o valoare specificata initial 
                            -- m <- newMVar v 
                            
takeMVar :: MVar a -> IO a  -- v <- takeMVar m 
                            -- intoarce in v valoarea din locatia de memorie 
                            -- daca m este o locatie goala, atunci apelul este blocant 
                            
putMVar :: MVar a -> a -> IO () 
                            -- putMVar m v 
                            -- pune in m valoare v 
                            -- blocheaza threadul daca exista deja valoare
-}

type Semaphore = MVar () 
newSemaphore = newEmptyMVar 
acquire mv = takeMVar mv 
release mv = putMVar mv () 

inc :: MVar Int -> Semaphore -> IO ()  
inc counter mutex = do 
    replicateM_ 1000 $ do 
        x <- takeMVar counter 
        putMVar counter (x + 1)
    release mutex 

main = do 
    counter <- newMVar 0 
    
    mutex1 <- newSemaphore 
    mutex2 <- newSemaphore 
    
    thread1 <- forkIO $ inc counter mutex1
    thread2 <- forkIO $ inc counter mutex2
    
    acquire mutex1 
    acquire mutex2 
    
    x <- takeMVar counter 
    
    print thread1 
    print thread2 
    print x 
    