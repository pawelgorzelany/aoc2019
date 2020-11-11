module Solution where

import qualified Data.Map.Strict as Map

data Vector a = Vector a a a deriving (Eq, Ord, Show)

type Position = Vector Int
type Velocity = Vector Int


-- Technically we don't need this but it is usefull for defining other stuff.
-- See instance for Num for example.
instance Functor Vector where
    fmap f (Vector x y z) = Vector x' y' z'
        where
          x' = f x
          y' = f y
          z' = f z


instance Num a => Num (Vector a) where
    (Vector x1 y1 z1) + (Vector x2 y2 z2) = Vector (x1 + x2) (y1 + y2) (z1 + z2)
    (Vector x1 y1 z1) * (Vector x2 y2 z2) = Vector (x1 * x2) (y1 * y2) (z1 * z2)
    abs = fmap abs
    negate = fmap negate
    signum = fmap signum
    fromInteger x = Vector x' x' x'
        where
          x' = fromInteger x


instance Foldable Vector where
    foldr f b (Vector x y z) = f z $ f y $ f x b


data Moon = Moon Position Velocity deriving (Eq, Ord, Show)


-- This is needed so that we can have an instance of Ord
-- instance Eq Moon where
--     (Moon (Vector3D x1 y1 z1) _) == (Moon (Vector3D x2 y2 z2) _) = (x1 y1 z1) == (x2 y2 z2)

-- We need this so that we can use Moon as a key in Map
-- instance Ord Moon where
--     (Moon (Vector3D x1 y1 z1) _) <= (Moon (Vector3D x2 y2 z2) _) = (x1, y1, z1) <= (x2, y2, z2)

-- But if derive both Eq and Ord for Vector3D we can also derive them for Moon

calculateVectors :: Moon -> Moon -> (Vector Int, Vector Int)
calculateVectors (Moon (Vector x1 y1 z1) _) (Moon (Vector x2 y2 z2) _) = (v1, -v1)
    where
      x' = if x1 == x2 then 0 else if x2 > x1 then 1 else -1
      y' = if y1 == y2 then 0 else if y2 > y1 then 1 else -1
      z' = if z1 == z2 then 0 else if z2 > z1 then 1 else -1
      v1 = Vector x' y' z'


-- This is where we had both iteration via for and local mutation on the vectors
-- dictionary in the Python version. Since Haskell doesn't have neither for
-- loops nor mutation we had to use recursion via a fold.
calculateGravity :: [Moon] -> Map.Map Moon [Vector Int]
calculateGravity ms = foldr f Map.empty $ pairs ms
    where
      pairs xs = [(x1, x2) | x1 <- xs, x2 <- xs, x1 /= x2]
      f (m1, m2) = Map.insertWith (++) m1 [fst $ calculateVectors m1 m2]



applyGravity :: [Moon] -> [Moon]
applyGravity ms = [Moon p (v + sum (vs Map.! m)) | m@(Moon p v) <- ms]
    where
      vs = calculateGravity ms


applyVelocity :: Moon -> Moon
applyVelocity (Moon p v) = Moon (p + v) v


potentialEnergy :: Moon -> Int
potentialEnergy (Moon p _) = sum $ abs p


kineticEnergy :: Moon -> Int
kineticEnergy (Moon _ v) = sum $ abs v


totalEnergy :: [Moon] -> Int
totalEnergy ms = sum [potentialEnergy m * kineticEnergy m | m <- ms]


step :: [Moon] -> [Moon]
step ms = [applyVelocity m | m <- applyGravity ms]


puzzle :: [Moon]
puzzle = [ Moon (Vector (-4) (-14) 8)   (Vector 0 0 0)
         , Moon (Vector 1 (-8) 10)      (Vector 0 0 0)
         , Moon (Vector (-15) 2 1)      (Vector 0 0 0)
         , Moon (Vector (-17) (-17) 16) (Vector 0 0 0)
         ]


main :: IO ()
main = do
  let finalState = iterate step puzzle !! 1000
  print $ totalEnergy finalState
