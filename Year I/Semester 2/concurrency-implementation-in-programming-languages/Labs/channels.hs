import Control.Concurrent 
import Control.Monad 
import Data.Char 

{- 
Canale de comunicare - pentru comunicare intre threaduri 
Ele sunt implementate tot prin MVar 

API de utilizare 
newChan :: IO (Chan a)
writeChan :: Chan a -> a -> IO () -- nu este niciodata un apel blocant 
readChan :: Chan a -> IO a -- este apel blocant cand canalul de comunicare este gol 

Exemplu. 
Avem doua canale, wordsIn si wordsOut 

threadul principal citeste siruri pana se intalneste sirul "exit" si pune aceste siruri in canalul wordsIn 
un thread citeste din wordsIn, sparge sirurile in cuvinte, si pune cuvintele in wordsOut 
un alt thread citeste cuvintele din wordsOut si le afiseaza la stdout cu majuscule 
-} 

load wordsIn = forever $ do 
    str <- getLine 
    if str == "exit" then return () 
    else do 
        writeChan wordsIn str 
        
move wordsIn wordsOut = do 
    str <- readChan wordsIn 
    let ls = words str 
    mapM_ (writeChan wordsOut) ls  
    
writeStdOut wordsOut = do 
    str <- readChan wordsOut 
    putStrLn $ map toUpper str 
    
main = do
    wordsIn <- newChan 
    wordsOut <- newChan 
    
    forkIO $ forever $ move wordsIn wordsOut 
    forkIO $ forever $ writeStdOut wordsOut 
    
    load wordsIn 